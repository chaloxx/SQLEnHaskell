module DmlFunctions where
import Data.Typeable
import AST (Env(..),Args(..),DML(..),Aggregate(..),BoolExp(..),Context,TabReg,TableNames,TableName,Reg,FieldName,FieldNames,Tab,
            TabTypes,AR(..),Cola,TableInfo(..),JOINS(..),Answer,O(..),RefOption(..),show2,Type(..))
import Url
import DynGhc
import Avl (AVL(..),isEmpty,isMember,foldT,particionT,particionT2,value,repeatKey,mapT,ioEitherFilterT,ioEitherMapT,compareCOrd,compareOrd,mergeT,filterT,
            isSingletonT,toTree,unionT,intersectionT,differenceT,emptyT,sortedT,splitAtL,left,right)
import Utilities (fst',snd',trd',updateHM,belong,giveMeOnlyFields,emptyHM,printTable,isInt,mapHM,split,isAgg,retHeadOrNull,toFloat,min3,max3,insertHM,deleteHM,
             posInf,negInf,lookupList,unionL,fold,tablepath,syspath,typeOfArgs)
import qualified Data.Set as Set (fromList,isSubsetOf,intersection,empty,difference,toList)
import Patterns ((||||),(////),(|||),pattern2,pattern)
import Data.Maybe (Maybe(..),fromJust)
import Prelude hiding (lookup,print,fail)
import Data.HashMap.Strict hiding (foldr,map,size,null)
import Control.DeepSeq (deepseq)
import Error
import Data.List (intersect,(\\),partition,isPrefixOf)
import Data.Hashable (Hashable)
import COrdering (COrdering (..))
import Check
import Control.Monad (when)
import Prelude hiding (fail,lookup)


--- Insertar en una tabla
--- Previamente a agregar a la tabla debemos ver que las filas a agregar no violan ninguna restricción de tipos o clave foránea
--- Es conveniente que el sistema guarde esta información en otras tablas que solo conoce el sistema para poder cosultar esta
--- información cada vez que la necesite.

-- Primer nivel de insertar: Obtener los metadatos
insert :: Env -> TableName -> AVL ([Args]) ->  IO ()
insert e n entry = do let r = url (name e) (dataBase e) ++  "/"
                      inf <- loadInfoTable ["scheme","types","key","fkey","haveNull"] e n :: IO [TableInfo]
                      case inf of
                         [] -> tableDoesntExist
                         [TS scheme,TT types,TK k, TFK fk, HN nulls] -> do  res <- obtainTable r n :: IO (Maybe (Tab))
                                                                            case res of
                                                                             Nothing -> put "Error fatal"
                                                                             Just t  -> insert' e r types scheme nulls k t entry fk n

-- Segundo nivel de insertar: Hacer los chequeos correspondientes y agregar a la tabla
insert' _ _ _ _ _ _ _ E _ _= return ()
insert' e r types scheme nulls k t entry fk n =
                                  do --Nro de argumentos recibidos
                                       let l = length scheme
                                       -- Calcular todas las tablas que son referenciadas por t
                                       fk' <- sequence $ map  (\(x,xs) -> do tree <- obtainTable r x
                                                                             return (xs,tree,x))
                                                                             fk
                                       -- Separar entradas válidas de las inválidas a tráves de distintos chequeos
                                       let (t1,t2) = particionT2 (checks l e types scheme nulls k t fk') (\x -> fromList $ zip scheme x) entry
                                       -- Filtrar entradas con claves repetidas
                                       let (t3,t4) = repeatKey scheme k t2
                                       -- Escribir modificaciones en archivo fuente
                                       appendLine (r++n) t4
                                       -- Mostrar que entrada son inválidas
                                       sequence_ $ mapT put  t1
                                       -- Mostrar que entradas contienen claves repetidas
                                       when (not $ isEmpty t3) (do put $ "Las siguientes entradas contienen claves repetidas"
                                                                   sequence_ $ mapT (put.showAux scheme) t3)



-- Chequeos
 where checks l e types scheme nulls k t' fk' x = do checkLength l x -- Cantidad de argumentos
                                                     checkTyped types x -- Tipos
                                                     let r = (fromList $ zip scheme x)
                                                     checkKey t' k r x -- ya existe un registro con la clave k?
                                                     checkNulls scheme nulls x -- puede haber valores nulos?
                                                     checkForeignKey e r fk' -- la clave foránea apunta a un registro existente?
       showAux k x = fold $ map (\entry -> x ! entry ) k


toText :: [Args] -> String
toText [] = ""
toText (x:[]) = (show x)
toText (x:xs) = (show x) ++ " , " ++ (toText xs)





-- Borrar aquellos registros de una tabla para los cuales exp es verdadero
delete :: Context -> String ->  BoolExp -> IO ()
delete g n exp = do let e = fst' g
                    let r = (url (name e) (dataBase e)) ++ "/"
                    let u = name (fst' g)
                    res <- obtainTable r n
                    case res of
                        Nothing ->  put "La tabla no existe"
                        Just t -> do [TK k,TR ref] <- loadInfoTable ["key","refBy"] e n :: IO([TableInfo])
                                     let (xs,ys,zs) =  partRefDel  ref
                                     xs' <- obtainTableList e xs -- tablas que tienen una referencia de tipo restricted sobre t'
                                     ys' <- obtainTableList e ys -- tablas que tienen una referencia de tipo cascades sobre t'
                                     zs' <- obtainTableList e zs -- tablas que tienen una referencia de tipo nullifies sobre t'
                                     a <- ioEitherFilterT (fun k g n xs xs' ys ys' zs zs') t
                                     case a of
                                       Left msg -> put msg
                                       Right t' -> reWrite t' (r++n)


         -- Filtro complicado (evalua expresión booleana y chequea restricciones para cada registro)
  where  fun k g n xs xs' ys ys' zs zs' reg =
           do let r = singleton n reg
              -- Evaluar expresión booleana de acuerdo a los valores de reg
              res <- evalBoolExp [n] (updateContext2 g r) exp
              case res of
                Left msg -> retFail msg -- Algo salio mal
                Right b -> do if not b then retOk True -- Devuelve true si la expr dio falso
                              else do rt <- resolRestricted xs xs' k reg
                                      case rt of
                                        Left msg -> retFail msg -- Error si se intentan borrar registros que son referenciados
                                        _ ->  do resolCascades (fst' g) ys ys' k  (filterT (fun2 k reg))  reg -- Si la restricción es cascades borrar todos los registros que apunten a reg
                                                 resolNull (fst' g) zs zs' k reg -- Si la restricción es nullifies nulificar todos los registros que apunten a reg (si aceptan nulos)
                                                 retOk False

                     -- Filtro simple (evalúa igualdad entre registros)
               where fun2 k x y = case compareCOrd k x y of
                                    Eq _ -> False
                                    _ -> True

         -- Separar las restricciones de cada tabla
         partRefDel [] = ([],[],[])
         partRefDel ((x,v,_):r) =  let (xs,ys,zs) = partRefDel r in
                                   case  v of
                                     Restricted -> (x:xs,ys,zs)
                                     Cascades -> (xs, x:ys, zs)
                                     Nullifies -> (xs,ys,x:zs)



-- Determina si los atributos k (clave primaria) son clave foránea en una lista de tablas
resolRestricted :: [String] -> [Tab] -> [String] -> Reg -> IO (Either String () )
resolRestricted _ [] _ _ = retOk ()
resolRestricted (n:ns) (t:ts) k x = if isMember k x t then errorRestricted x n
                                    else resolRestricted ns ts k x


-- Esparce borrado o modificación sobre los registros cuya clave foránea es k de una lista de tablas
resolCascades :: Env  -> [String] -> [Tab] -> [String] -> (Tab -> Tab) -> Reg -> IO ()
resolCascades _ _ [] _ _  _ = return ()
resolCascades e (n:ns) (t:ts) k f x = do let (t',r) =  f t ||| url' e n
                                         b <- reWrite t' r
                                         b `deepseq` resolCascades e ns ts k f x



-- Convierte a Nulo los valores de las claves foráneas k de una lista de tablas
resolNull :: Env ->  [String] -> [Tab] -> [String] -> Reg -> IO ()
resolNull _ _ [] _ _ = return ()
resolNull e (n:ns) (t:ts) k x = do let (t',r) = mapT (fun k x) t ||| url' e n
                                   b <- reWrite t' r
                                   b `deepseq` resolNull e ns ts k x

              -- Comparar igualdad entre los valores de los atributos k
        where fun k x y = case compareOrd k x y of
                           EQ -> fun2 k y
                           _ -> y
              -- Volver Nulos los valores de los atributos k
              fun2 [] y = y
              fun2 (k:ks) y = fun2 ks (updateHM (\x -> Just $ Nulo) k y)




-- Actualizar (primer nivel)
update :: Context -> String -> ([String],[Args]) -> BoolExp -> IO ()
update g n (fields,values) exp =
   do let r = url' (fst' g) n -- obtener ruta de tabla
      [TS sch,TT typ,TR ref,TK key,HN nulls] <- loadInfoTable ["scheme","types","refBy","key","haveNull"] (fst' g) n -- cargar esquemas y tipos
      update' g (fields,values) sch typ r n exp ref key nulls

-- Actualizar (segundo nivel)
update' g (fields,values) sch typ r n exp ref key nulls =
  let types = fromList $ zip sch typ
      h = singleton n types
      at = trd' $ updateContext3 g h
      types' = map (\x -> types ! x) key
      setKeys = Set.fromList key
      setFields = Set.fromList fields
      setScheme = Set.fromList sch in
      -- Chequear que los atributos modificados están dentro del esquema y que ninguno es parte de la key de la tabla
      if (not $ Set.isSubsetOf setFields setScheme) || Set.intersection setKeys setFields /= Set.empty then errorUpdateFields fields
      else case checkTyped types' values >> checkTypeBoolExp exp [n] at of -- chequear tipos de valores recibidos y expresión booleana
              Left msg -> put msg
              Right _ -> do  res <- obtainTable r n -- cargar tabla
                             case res of
                              Nothing -> put "Error al cargar tabla..."
                              Just t -> do let vals = fromList $ zip key values
                                           let (xs,ys,zs) = partRefTable ref
                                           xs' <- obtainTableList (fst' g) xs
                                           ys' <- obtainTableList (fst' g) ys
                                           zs' <- obtainTableList (fst' g) zs
                                           res' <- ioEitherMapT (change nulls key n g exp vals xs xs' ys ys' zs zs' ) t
                                           case res' of
                                              Right t' -> reWrite t' r
                                              Left msg -> put msg


           where -- Función para modificar los valores de aquellos registros para los cuales exp es un predicado válido
                 change nulls k s g exp vals xs xs' ys ys' zs zs' x =
                    do let r = singleton s x
                       h <- evalBoolExp [s] (updateContext2 g r) exp
                       case h of
                         Left msg -> retFail msg
                         Right b ->  if b then do a <- resolRestricted xs xs' k x
                                                  case a of
                                                   Left msg -> retFail msg
                                                   _ -> do resolCascades (fst' g) ys ys' k (mapT (fun2 nulls vals k x)) x
                                                           resolNull (fst' g) zs zs' k x
                                                           retOk $ mapWithKey (fun nulls vals) x
                                     else retOk x

                          -- Actualiza el valor del atributo k
                    where fun nulls vals k v = case lookup k vals of
                                                Nothing -> v
                                                Just Nulo -> if belong nulls k then Nulo
                                                             else v
                                                Just v' -> v'
                          fun2 nulls vals k x y = case compareOrd k x y of
                                                    EQ -> mapWithKey (fun nulls vals) y
                                                    _ -> y


-- Separa una lista de tablas, clasificandolas segun sus opciones de referencia
partRefTable [] = ([],[],[])
partRefTable ((x,_,v):r) =   let (xs,ys,zs) = partRefTable r in
                           case  v of
                            Restricted -> (x:xs,ys,zs)
                            Cascades -> (xs, x:ys, zs)
                            Nullifies -> (xs,ys,x:zs)

-- Toma una lista de nombres de tabla y devuelve una lista de tablas
obtainTableList _ [] = return []
obtainTableList e (x:xs) = do let r = url' e x
                              t <- obtainTable r x
                              case t of
                               Nothing -> error r
                               Just t' -> do ts' <- obtainTableList e xs
                                             return (t':ts')






-- Función para obtener valor de variables de tupla
obtainValue :: [String] -> Args -> TabReg -> Args
obtainValue s (Field v) r = case lookupList r s v of
                              Right x -> x
                              _ -> error "ObtainValue error"
obtainValue _ (Dot s2 v) r = case lookupList r [s2] v of
                               Right x -> x
                               _ -> error "ObtainValue error"







--- Ejecutar consultas



insertCola (n,x) [] = [(n,x)]
insertCola (n,x) c@((n',x'):xs) = if n < n' then (n',x'): (insertCola (n,x) xs)
                                  else (n,x):c

-- Convierte un árbol de consulta en una cola para poder hacer una ejecucion secuencial
-- de los comandos en un orden dado
conversion :: DML ->  Cola AR
conversion (Union d1 d2) = let (a1,a2) = conversion d1 ||| conversion d2
                           in [(0,Uni a1 a2)]
conversion (Diff d1 d2) = let (a1,a2) = conversion d1 ||| conversion d2
                           in [(0,Dif a1 a2)]
conversion (Intersect d1 d2) = let (a1,a2) = conversion d1 ||| conversion d2
                               in [(0,Inters a1 a2)]
conversion (Select dist args dml) = insertCola (5,Pi dist args) $ conversion dml
conversion (From args dml) = insertCola (1,Prod args) $ conversion dml
conversion (Where boolExp dml) = insertCola (3,Sigma boolExp) $ conversion dml
conversion (GroupBy args dml) = insertCola (4,Group args) $ conversion dml
conversion (Having boolExp dml) = insertCola (5,Hav boolExp) $ conversion dml
conversion (OrderBy args ord dml) = insertCola (6,Order args ord) $ conversion dml
conversion (Limit n dml) = insertCola (7,Top n) $ conversion dml
conversion (End) = []



-- Proyectar valores de las variables y agregarlas al contexto (sirve para subconsultas y para evitar ambiguedad con atributos del mismo nombre)
proy :: [Args] -> TableNames -> Context -> [Args] -> Reg -> IO(Either String Reg)
proy f n g ls x = do pattern2 (return $ divideRegister n (giveMeOnlyFields $ trd' g) x)
                                          -- mapear cada proyección y juntar valores
                              (\r -> do lr <- sequence $ map (proy' f (updateContext2 g r) n) ls
                                        return $ tryJoin union emptyHM lr)


proy' :: [Args] -> Context -> TableNames -> Args -> IO (Either String Reg)
-- Proyectar (segundo nivel)
proy' _ g s (Field v)  = return $ do res <- lookupList (snd' g) s v
                                     ok $ singleton v res



--Subconsulta en selección
proy' _  g s (As (Subquery dml) n) = pattern2 (let c = conversion dml in runQuery' g c )
                                              (\(_,_,_,l,[t]) -> if isSingletonT t && length l == 1 then let (k,r) = l !! 0 ||| value t
                                                                                                             v = fromJust (lookup k r)
                                                                                                         in retOk $ singleton n v
                                                                 else errorPi4)


--Renombre de selección
proy' f  g s (As exp n) =  do res <- proy' f g s exp
                              return $ do reg <- res
                                          case elems reg of
                                            [value] -> ok $ singleton n value
                                            _ -> errorAs

-- Operador '.'
proy' f g _ e@(Dot t v) = pattern (return $ lookupList (snd' g) [t] v)
                                  (\x -> singleton (show2 e)  x)


-- Clausula ALL mapea todos los atributos disponibles a valores
proy' f g s (All) = proyAux f g s
   where proyAux [] _ _  = retOk empty
         proyAux (x:xs) g s = do Right (res,val) <- proyAux xs g s |||| proy'[] g s x
                                 retOk $ union res val

-- -- Expresiones enteras
proy' _ g s q = return $ do  v@(A4 n) <- evalIntExp (snd' g) s q
                             if isInt n then ok $ singleton (show2 q) (A3 (round n))
                             else ok $ singleton (show2 q) v




-- Procesamiento de selecciones para el caso con funciones de agregado
processAgg  :: Context -> [Args] -> [String] -> [Tab] -> IO (Either String ([String],AVL (HashMap String Args)))
processAgg g ls names ts = do  res <- sequence $ map (processAgg' g names ls) ts
                               return $ do s <- sequence res
                                           let ls' = map show2 ls
                                           ok (ls',toTree s)

  where processAgg' _ _ [] _ = retOk empty

        -- Se puede seleccionar cualquiera de los atributos que definen la clase
        processAgg' g ns ((Field s):xs) t   = let m2 = singleton s  ((value t) ! s) in
                                                  pattern (processAgg' g ns xs t)
                                                          (\m1 -> union m1 m2)

        -- Aplicar una función de agregado reduce la clase a un solo valor
        processAgg' g ns ((A2 f):xs) t  = pattern (processAgg' g ns xs t |||| evalAgg g ns (A2 f) t)
                                                  (\(m1,v) -> let m2 = singleton (show f) v in union m1 m2)


        -- El renombramiento es renombrar un atributo
        processAgg' g ns ((As s1 s2 ):xs) t   = pattern (processAgg' g ns (s1:xs) t)
                                                        (\m -> updateKey (show2 s1) s2 m)


-- Ejecuta la consulta dml en el estado g, imprimiendo los resultados
runQuery :: Context -> DML -> IO ()
runQuery g dml = do -- Convertir dml en una secuencia de operadores de álgebra relacional
                    let c = conversion dml
                    --Ejecutar
                    v <- runQuery' g c
                    case v of
                     Left msg -> put msg
                     Right (_,_,_,ys,[t]) -> printTable show2 ys t


-- Ejecución de consultas en un contexto g
runQuery' :: Context -> Cola AR -> IO(Either String Answer)

runQuery' g [] = retOk (g,False,[],[],[])


runQuery' g ((_,Uni a1 a2):xs) = runQuery'' g a1 a2 xs unionT
runQuery' g ((_,Inters a1 a2):xs) = runQuery'' g a1 a2 xs intersectionT
runQuery' g ((_,Dif a1 a2):xs) = runQuery'' g a1 a2 xs differenceT


-- Hacer JOINS




-- Realiza proyecciones
runQuery' g ((_,Pi unique args):rs) =
 do r <- runQuery' g rs
    case r of
     Right (g',groupBy,names,fields,tables) ->
              --Si no hay una claúsula group by no se pueden usar funciones de agregado
              if not $ groupBy then case partition isAgg args of -- Separar funciones de agregado de selecciones normales
                                     (_,[]) -> withAgg g unique names args tables   -- Caso con funciones de agregado
                                     ([],_) ->   -- Caso sin funciones de agregado
                                     -- Chequear tipo de  expresiones enteras si las hay
                                               case checkTypedExpList names (trd' g') args of
                                                 Right _ -> do let fields' = [split x | x <- fields]
                                                               res <- ioEitherMapT (proy fields' names g' args) (isNull tables) -- Aplicar proyecciones
                                                               case res of
                                                                Right t -> let args'= toKey fields args    -- Obtener atributos solicitados
                                                                               n = head names
                                                                               newFields = singleton n (fromList $ map (\x -> (x,Nulo)) args')
                                                                              -- La proyección nos da una nueva tabla, necesitamos almacenar sus tipos y sus atributos
                                                                               newTypes = singleton n (mapHM (\x -> typeOfArgs x) (value t))
                                                                               g'' = (fst' g', newFields,newTypes)
                                                                           in retOk $ distinct g'' unique names args' t
                                                                Left msg -> retFail msg
                                                 Left msg -> retFail msg

                                     _ -> errorPi2   -- Error al mezclar las operaciones

               -- En este caso se uso la claúsula group by
                else  if All `elem` args then errorPi3 -- No se puede usar All en este caso
                      else withAgg g' unique names args tables

     Left msg -> retFail msg

  where -- Procesar funciones de agregado
        withAgg g unique names args tables = pattern (processAgg g args names tables)
                                                     (\(fields,tables) -> distinct g unique names fields tables)
        toKey _ [] = []
        toKey fields (All:xs) = fields ++ (toKey fields xs)
        toKey fields (arg:xs) = (show2 arg) : (toKey fields xs)

        -- Eliminar registros duplicados si se solicita
        distinct g unique names fields table = if unique then let table' = mergeT (compareCOrd fields) E table
                                                              in (g,True,names,fields,[table'])
                                               else (g,False,names,fields,[table])
         -- Chequear el tipo de una lista de expresiones

        isNull [] = emptyT
        isNull tables = head tables

-- Ejecuta producto cartesiano
runQuery' g ((_,Prod args):xs) =
     pattern (processFromArgs (fst' g) args)
             (\(g1,names,fields,t) -> let g21 = updateContext2 g (snd' g1)
                                          g22 = updateContext3 g21 (trd' g1)
                                      in  (g22,False,names,fields,[t]))

-- Ejecuta selección
runQuery' g ((_,Sigma exp):xs) =
 do r <- runQuery' g xs
    case r of
      Left msg -> retFail msg
      Right (g',b,names,fields,[t]) -> case checkTypeBoolExp exp names (trd' g') of
                                        Left msg -> retFail msg
                                        _ -> do res <- ioEitherFilterT (\x-> do res <- return $ divideRegister names (giveMeOnlyFields $ trd' g') x
                                                                                case res of
                                                                                 Left msg -> retFail msg
                                                                                 Right r -> do b <- evalBoolExp names (updateContext2 g' r)  exp
                                                                                               return b) t

                                                case res of
                                                 Left msg -> retFail msg
                                                 Right t' -> retOk (g',b,names,fields,[t'])


      where fromRight _ (Right b) = b
            fromRight b (Left _) = b

-- Agrupa por atributos
runQuery' g ((_,Group args):xs) =
  do r <- runQuery' g xs
     return $ do (g',_,tables,fields,[t]) <- r
                 let ls = map show2 args
                 let (setArgs,setFields) = Set.fromList ls ||| Set.fromList fields
                 if setArgs `Set.isSubsetOf` setFields then do let trees = group ls t
                                                               return (g',True,tables,fields,trees)
                 else errorGroup (ls \\ fields)

    where
runQuery' g ((_,Hav exp):xs) = pattern2 (runQuery' g xs)
                                        (\(g,b,names,fields,tables) -> if not b then errorHav
                                                                       -- Chequear el tipo de la expresión booleana
                                                                       else case checkTypeBoolExp exp names (trd' g) of
                                                                              Left msg -> retFail msg
                                                                              _ -> pattern (ioEitherFilter (aux names g exp) tables)
                                                                                           (\tables' -> (g,b,names,fields,tables')))

                                  -- Reemplazar claúsulas de funciones de agregado por
                                  -- expresiones númericas y evaluar el valor de verdad de
                                  -- la expresión obtenida

 where aux names g e t = pattern2 (replaceAgg g names e t)
                                  (\exp -> pattern2 ( (return $ divideRegister names (giveMeOnlyFields $ trd' g) (value t)))
                                                    (\reg -> do let g' = updateContext2 g reg                                                                
                                                                evalBoolExp names g' exp))



runQuery' g ((_,Order args ord):xs) =
  do      res <- runQuery' g xs
          return $ do (g',groupBy,names,fields,[t]) <- res
                      let  stringArgs = map show2 args
                           (setFields,setArgs) = Set.fromList fields ||| Set.fromList stringArgs
                      if setArgs `Set.isSubsetOf` setFields then  let sortF = case ord of
                                                                          A -> compareCOrd
                                                                          D -> compareDesc
                                                                      t' = sortedT (sortF stringArgs) t
                                                             in ok (g',groupBy,names,fields,[t'])
                      else  errorOrder (stringArgs \\ fields)


  where  compareDesc ls m1 m2 = compareCOrd ls m2 m1


runQuery' g ((_,Top n):xs) =
   do r <- runQuery' g xs
      case r of
        Left msg -> retFail msg
        Right q@(g',b,l1,l2,s) -> if length s /= 1  then errorTop
                                  else if n < 0 then errorTop2
                                       else case splitAtL n (head s) of
                                             Left _ -> retOk q
                                             Right (t',_) -> retOk (g',b,l1,l2,[t'])

-- Segundo nivel (operaciones de conjuntos)
runQuery'' g a1 a2 xs op =
 do let (r1',r2') = runQuery' g a1 ||| runQuery' g a2
    r1 <- r1'
    r2 <- r2'
    return $ do
    (g1,_,l11,l12,s1) <- r1
    (g2,_,l21,l22,s2) <- r2
    if notUnique s1 || notUnique s2 then errorSet
    else if notEqualLen l12 l22 then errorSet2
         else if not $ equalType (trd' g1) (trd' g2) l11 l21 l12 l22  then errorSet3
              else do let ls =  unionL l11 l21 -- unir tablas relacionadas
                      let g12 =  updateContext2 g1 (snd' g2) -- unir valor de variables de tupla
                      let g13 =  updateContext3 g12 (trd' g2)    -- unir tipo de variables de tupla
                      let (t1,t2) = sortedT (compareCOrd l12) (head s1) ||| sortedT (compareCOrd l12) (replaceAllKeys l22 l12 (head s2)) -- Ordenar árboles para hacer una unión ordenada (mejor eficiencia)
                      -- ambos entornos son iguales, tomamos el primero
                      ok (g13,False,ls,l12,[op (compareCOrd l12) t1 t2])

 where notUnique s = not $ length s == 1

       notEqualLen l1 l2 = not $ length l1 == length l2

       equalType _ _ _ _ [] [] = True
       equalType e1 e2 l11 l21 (x:xs) (y:ys) = if lookupList e1 l11 x == lookupList e2 l21 y then equalType e1 e2 l11 l21 xs ys
       else False
       equalType _ _ _ _ _ _ = False

       replaceAllKeys  [] _ t = t
       replaceAllKeys (x:xs) (y:ys) t = if x /= y then replaceAllKeys xs ys (mapT (updateKey x y) t)
                                        else replaceAllKeys xs ys t







-- Procesar argumentos de from (primer nivel)
processFromArgs :: Env -> [Args] -> IO (Either String (Context,TableNames,FieldNames,Tab))
processFromArgs _ [] = retFail "Sin argumentos"


-- Caso una sola tabla
processFromArgs e ([s]) = pattern  (processFromArgs' e s)
                                   (\(g,n,f,t) ->  (g,[n],f,t))


-- Caso 2 tablas
processFromArgs e ([s1,s2]) = pattern ( processFromArgs' e s1 |||| processFromArgs' e s2)
                           (\((g1,n1,fields1,t1),(g2,n2,fields2,t2)) -> let (t1',t2') = mapT (changeKey n1 fields1) t1 ||| mapT (changeKey n2 fields2) t2
                                                                            (fields1',fields2') = map (dot n1) fields1 ||| map (dot n2) fields2
                                                                            fullFields = fields1' ++ fields2'
                                                                        in  (updateContext3 g1 (trd' g2),[n1,n2],fullFields,processFromArgs'' fullFields t1' t2'))

-- Caso 3 o más tablas
processFromArgs e (s:ls) = pattern (processFromArgs  e ls |||| processFromArgs' e s)
                                   (\((g1,n1,fields1,t1),(g2,n2,fields2,t2)) -> let t2' = mapT (changeKey n2 fields2) t2
                                                                                    allFields = (map (dot n2) fields2) ++ fields1
                                                                                in (updateContext3 g1 (trd' g2),n2:n1,allFields, processFromArgs'' allFields t1 t2'))
-- Concatenación entre 2 cadenas agregando un punto en el medio
dot s x = s ++ "." ++ x

-- Cambiar llaves de los registros
changeKey _ [] _ = emptyHM
changeKey s (x:xs) r = union ((singleton (dot s x)) (r ! x)) (changeKey s xs r)



-- Obtiene una tabla
-- Procesar argumentos de from(segundo nivel)
-- Primer caso : Subconsulta con renombre
processFromArgs' :: Env -> Args -> IO(Either String (Context,String,FieldNames,Tab))
processFromArgs' e (Subquery s) = let c = conversion s
                                  in pattern2  (runQuery' (e,emptyHM,emptyHM) c)
                                               (\(g,b,[name],fields,[t]) -> if b then errorProd2
                                                                            else retOk (g,name,fields,t))


processFromArgs' e (ColAs arg fields1 fields2) =
        pattern2 (processFromArgs' e arg)
                 (\(g,n,fields,t) ->  let (setFields1,setFields) = Set.fromList fields1 ||| Set.fromList fields
                                      in if not $ setFields1 `Set.isSubsetOf` setFields || length fields1 /= length fields2 then errorColAs
                                         else let zipFields = zip fields1 fields2
                                                  t' = mapT (mapReg fields1 fields2) t
                                                  -- Actualizar con los nuevos nombres de atributo
                                                  newFields = singleton n $ mapReg fields1 fields2 (snd' g ! n)
                                                  newTypes = singleton n $ mapReg fields1 fields2 (trd' g ! n)
                                                  newContext = (e,newFields,newTypes)
                                              in retOk (newContext,n,fields2 ++ (fields \\ fields1),t'))
           where mapReg [] _ reg = reg
                 mapReg (x:xs) (y:ys) reg = mapReg xs ys (updateKey x y reg)







-- Segundo caso : Tabla con renombre
processFromArgs' e (As arg n2) = pattern (processFromArgs' e arg)
                                         (\(g,n1,fields,t) -> let newTypes = singleton n2 ((trd' g) ! n1)
                                                                  newScheme = singleton n2 ((snd' g) ! n1)
                                                                  newG = (e,newScheme,newTypes)
                                                              in (newG,n2,fields,t))

    where aux _ [] _ = emptyHM
          aux fields (x:xs) types = let t = filterWithKey (\y -> \ _ -> y `elem` fields || (x `dot` y) `elem` fields ) (types ! x) -- Solo nos importa el contexto para los campos seleccionados
                                    in union t (aux fields xs types)

-- Caso sencillo: Una sola tabla
processFromArgs' e (Field n) = do b <- existTable e n
                                  if not b  then retFail $ n ++ " no existe!"
                                  else do res <- obtainTable ((url (name e) (dataBase e))++"/") n
                                          case res of
                                            Nothing -> errorProd n
                                            Just t -> do inf <- loadInfoTable ["scheme","types"] e n-- Obtener esquema y tipos
                                                         case inf of
                                                          [] -> errorProd n
                                                          [TS scheme, TT types] -> let types1 = singleton n (fromList $ zip scheme types)
                                                                                       fieldsTree = singleton n $ fromList $ map (\x -> (x,Nulo)) scheme
                                                                                       g = (e,fieldsTree,types1)
                                                                                   in retOk  (g ,n ,scheme,t)




processFromArgs' e (Join j arg1 arg2 exp) =
  do  res <- processFromArgs' e arg1 |||| processFromArgs' e arg2
      case res of
       Left msg -> retFail msg
       Right ((g,n1,f1,t1),(g2,n2,f2,t2))  ->
          case f1 `intersect` f2 of
                     ls@(x:xs) -> errorJoin ls
                     [] ->  let f3 = f1 ++ f2
                                n3 = [n1,n2]
                                g31 = updateContext2 g (snd' g2)
                                g32 = updateContext3 g (trd' g2)
                              -- Producto cartesiano
                                t3 = processFromArgs'' f3 t1 t2
                            in
                            case checkTypeBoolExp exp n3 (trd' g32) of
                              Left msg -> retFail msg
                                        -- Juntar campos de todas las tablas
                              Right _  ->     let (v1,v2) = giveMeOnlyFields (snd' g) |||  giveMeOnlyFields (snd' g2)
                                                  -- Evaluadores convenientemente definidos
                                                  evaluator = eval (v1 `union` v2) n3 g32 exp
                                                  evaluator2 y = pattern (evaluator y)
                                                                         (\(x,_) -> x)
                                                  n = if j == JLeft then n2
                                                      else n1
                                                -- Nueva tabla de tipos
                                                  allTypes = singleton n $(trd' g ! n1 ) `union` (trd' g2 ! n2)
                                                -- Para poder agregar al contexto, inicialmente le damos valores nulos
                                                  onlyFieldsWithNull = fromList $ map (\x -> (x,Nulo)) $ (v1 ! n1) ++ (v2 ! n2)
                                                -- Crear registro final
                                                  allFields = singleton n onlyFieldsWithNull
                                                  newContext = (e,allFields,allTypes)
                                              in
                                              case j of -- Qué tipo de Join es?
                                                 Inner ->  pattern (ioEitherFilterT evaluator2 t3)
                                                                   (\t4 -> (newContext,n,f3,t4))
                                                 JLeft -> pattern (ioEitherMapT (mapper n1 f1 f2 f3 n3 evaluator) t3)
                                                                   (\t4 -> (newContext,n,f3,t4))
                                                 JRight -> pattern (ioEitherMapT (mapper n2 f2 f1 f3 n3 evaluator) t3)
                                                                   (\t4 -> (newContext,n,f3,t4))



           where eval onlyFields n3 g32 exp x = case divideRegister n3 onlyFields x of
                                                 Left msg -> retFail msg
                                                 Right r -> let g32' = updateContext2 g32 r -- Actualizar contexto con valores del registro
                                                            in pattern (evalBoolExp n3 g32' exp)
                                                                       (\b -> (b,g32'))



                 mapper n1 f1 f2 f3 n3 evaluator x  =
                      do (Right (b,g')) <- evaluator x
                         -- Si la evaluación es verdadera proyectar todos los campos
                         if b then do let f31 = map split f3
                                      proy' f31 g' n3 All

                         else do -- Si no lo es proyectar todos los campos de la tabla n1 y proyectar con Nulo los campos de n2
                                 let f11 = map split f1
                                     reg2 = fromList $ map (\x -> (x,Nulo)) f2
                                 (Right reg) <- proy' f11 g' [n1] All
                                 retOk $ union reg reg2













-- Procesar arguments de from (tercer nivel),realiza el producto entre 2 tablas
processFromArgs'' :: [String] -> Tab -> Tab -> Tab
processFromArgs'' _ E t = E
processFromArgs'' _ t E = E
processFromArgs'' fields t1 t2 = let (tl,tr) = processFromArgs'' fields (left t1) t2 ||| processFromArgs'' fields (right t1) t2 -- Producto a izq y der
                                     t = mergeT (compareCOrd fields) tl tr -- Mezclar resultados
                                 in mergeT (compareCOrd fields) t (prod (value t1) t2) -- Agregar el processFromArgsucto con el elemento actual
   where prod x t = mapT (union x) t




-- Actualiza el entorno en el contexto g
updateContext ::  Context -> Env -> Context
updateContext g e = (e,snd' g,trd' g)


-- Actualiza los valores de las variables de tupla en el contexto g
updateContext2 :: Context -> TabReg -> Context
updateContext2 g x = (fst' g,union x (snd' g),trd' g)

-- Actualiza los tipos de las variables de tupla en el contexto g
updateContext3 :: Context -> TabTypes -> Context
updateContext3 g y =  (fst' g,snd' g,union y (trd' g))



-- Remplaza funciones de agregado por los valores correspondientes en una expresión boleana (primer nivel)
replaceAgg ::Context -> [String] -> BoolExp -> AVL (HashMap String Args) -> IO (Either String BoolExp)
replaceAgg g names (And e1 e2) t = replaceAgg' g names e1 e2 t (\x y -> And x y)
replaceAgg g names (Or e1 e2) t = replaceAgg' g names  e1 e2 t (\x y -> Or x y)
replaceAgg g names (Less e1 e2) t = replaceAgg'' g names e1 e2 t (\x y -> Less x y)
replaceAgg g names (Great e1 e2) t = replaceAgg'' g names e1 e2 t (\x y -> Great x y)
replaceAgg g names (Equal e1 e2) t = replaceAgg'' g names e1 e2 t (\x y -> Equal x y)
replaceAgg g names (GrOrEq e1 e2) t = replaceAgg'' g names e1 e2 t (\x y -> GrOrEq x y)
replaceAgg g names (LsOrEq e1 e2) t = replaceAgg'' g names e1 e2 t (\x y -> LsOrEq x y)
replaceAgg g names (NotEq e1 e2) t = replaceAgg'' g names e1 e2 t (\x y -> NotEq x y)
replaceAgg _ _ exp _ = retOk exp


-- replace (segundo nivel)
replaceAgg' g names e1 e2 t f  = pattern (replaceAgg g names e1 t |||| replaceAgg g names e2 t)
                                         (\(v1,v2) -> f v1 v2)

-- replace (tercer nivel)
replaceAgg'' g names e1 e2 t f  = pattern (evalAgg g names e1 t |||| evalAgg g names e2 t)
                                          (\(v1,v2) -> f v1 v2)




-- Evaluar funciones de agregado en el contexto g (primer nivel)
evalAgg :: Context -> [String] -> Args -> Tab -> IO (Either String Args)
evalAgg g names (A2 f) t = pattern (evalAgg' g names f t) A4
evalAgg g names (Plus exp1 exp2) t = applyAggregate g names exp1 exp2 Plus t
evalAgg g names (Times exp1 exp2) t = applyAggregate g names exp1 exp2 Times t
evalAgg g names (Div exp1 exp2) t = applyAggregate g names exp1 exp2 Div t
evalAgg g names (Minus exp1 exp2) t = applyAggregate g names exp1 exp2 Minus t
evalAgg g names (Negate exp) t = applyAggregate' g names exp Negate t
evalAgg g names (Brack exp) t = applyAggregate' g names exp Brack t
evalAgg _ _ e _ = retOk e

applyAggregate g names exp1 exp2 op t= pattern (evalAgg g names exp1 t |||| evalAgg g names exp2 t)
                                               (\(n1,n2) -> op n1 n2 )
applyAggregate' g names exp op t = pattern (evalAgg g names exp t)
                                           (\n -> op n)



-- Evaluar funciones de agregado (segundo nivel)
evalAgg' g names (Count d arg) t = evalAgg'' arg d t (retOk 0) (abstract arg g names (\ v1 v2 _  -> 1 + v1 + v2)) names

evalAgg' g names (Min d arg) t = evalAgg'' arg d t (retOk posInf) (abstract arg g names (\ v1 v2 v3  -> min3 v1 v2 (toFloat v3))) names

evalAgg' g names (Max d arg) t = evalAgg'' arg d t (retOk 0) (abstract arg g names (\ v1 v2 v3  -> max3 v1 v2 (toFloat v3))) names

evalAgg' g names (Sum d arg) t = evalAgg'' arg d t (retOk 0) (abstract arg g names (\ v1 v2 v3  -> v1 + v2 + (toFloat v3))) names

evalAgg' g names (Avg d arg) t = pattern  (evalAgg' g names (Sum d arg) t |||| evalAgg' g names (Count d arg) t)
                                          (\(n1,n2) -> n1/n2)


-- Abstracción para escribir menos código
abstract arg g names f  = \ x y z -> pattern ( (return $ divideRegister names (giveMeOnlyFields $ trd' g) x) |||| (y |||| z ))
                                             (\(reg,(v1,v2)) -> abstract' g names arg (f v1 v2) reg)

abstract' g names (Field v) op reg = abstract'' g names v op reg
abstract' g _ (Dot t v) op reg = abstract'' g [t] v op reg
abstract'' g names v op reg =  let g' = updateContext2 g reg in
                               case lookupList (snd' g') names v of
                                 Right x -> op x
                                 Left _ -> error "Error fatal"

-- Evaluar funciones de agregado (segundo nivel)
evalAgg'' (Field s) d t e f names =  evalAgg''' d s t e f

evalAgg'' (Dot n s) d t e f names = evalAgg''' d (n ++ "." ++ s) t e f


-- Evaluar funciones de agregado (tercer nivel)
evalAgg''' d s t e f = if d then let t' = mergeT (compareCOrd [s]) E t
                                 in foldT f e t'
                       else foldT f e t



-- Elimina elementos duplicados si se solicita previamente a aplicar la función de agregado


-- Toma una lista de atributos y un árbol y descompone el árbol en clases según los atributos recibidos
group :: [String] -> AVL (HashMap String Args) -> [AVL (HashMap String Args)]
group _ E = []
group xs t = let a = value t
                 v = fromList $ map (\x -> (x,a ! x)) xs
                 (t1,t2) = particionT (equal xs v) t
             in t2 : group xs t1

      where equal xs v x = case compareCOrd xs v x of
                            Eq _ -> True
                            _ -> False




-- Actualiza el valor de la llave k1 a k2 en m
updateKey  ::  (Eq k, Hashable k) => k -> k -> HashMap k v -> HashMap k v
updateKey k1 k2 m = if k1 == k2 then error "Error en cambio de key"
                    else let m' = insertHM k2 (m ! k1) m
                         in deleteHM k1 m'



-- Crear rutas de acceso hacias los datos
divideRegister :: TableNames -> HashMap TableName FieldNames -> Reg -> Either String  (HashMap String Reg)
divideRegister [] _ _ = return emptyHM
divideRegister l@(m:ms) hm r = do  x <- divideRegister' m (hm ! m) r
                                   xs <- divideRegister ms hm r
                                   return $ union x xs



divideRegister' :: TableName -> FieldNames -> Reg -> Either String TabReg
divideRegister' x [] _  = return $ singleton x emptyHM
divideRegister' x (l:ls) r = do y <- divideRegister'' x l r
                                ys <- divideRegister' x ls r
                                return $ singleton x (union y (ys ! x))

divideRegister'' :: TableName -> FieldName -> Reg -> Either String Reg
divideRegister'' x y r = case lookup y r of
                          Nothing -> let str = x ++ "." ++ y
                                     in case lookup str r of
                                         Nothing -> fail $ show r--fail $ "No se pudo encontrar el atributox " ++ str
                                         Just v -> ok $ singleton  y v
                          Just v -> ok $  singleton y v



tryJoin :: (e -> b -> b) -> b -> [Either a e] -> Either a b
tryJoin u e [] = return e
tryJoin u e ((Left x):xs) = Left x
tryJoin u e ((Right x):xs) = do xs' <- tryJoin u e xs
                                return (u x xs')


ioEitherFilter :: (e -> IO (Either String Bool)) -> [e] -> IO(Either String [e])
ioEitherFilter f [] = retOk []
ioEitherFilter f (x:xs) = pattern (ioEitherFilter f xs |||| f x)
                                  (\(res,b) -> if b then (x:res)
                                              else res)


-- Evals


-- Evaluar expresión entera (primer nivel)
evalIntExp :: TabReg -> [String] -> Args -> Either String Args
evalIntExp g s (Plus exp1 exp2) = evalIntExp' False (+) g s exp1 exp2
evalIntExp g s (Minus exp1 exp2) = evalIntExp' False (-) g s exp1 exp2
evalIntExp g s (Times exp1 exp2) = evalIntExp' False (*) g s exp1 exp2
evalIntExp g s (Div exp1 exp2) = evalIntExp' True (/) g s exp1 exp2

evalIntExp g s (Negate exp1) = do n <- evalIntExp g s exp1
                                  return $ (A4 $ negate (toFloat n))

evalIntExp g s (Brack exp1) = evalIntExp g s exp1


evalIntExp g s (Field v) = lookupList g s v


evalIntExp g s (Dot s2 v) = lookupList g [s2] v

-- Constante
evalIntExp _ _ arg = return arg

-- Evaluar expresión entera (segundo nivel)
-- Incluye un booleano para saber si la operación es una división
evalIntExp' :: Bool -> (Float -> Float -> Float) -> TabReg -> [String] -> Args -> Args -> Either String Args
evalIntExp' b o g s exp1 exp2 = if b then do n2 <- evalIntExp g s exp2
                                             case n2 == A4 0 of
                                               True -> divisionError
                                               False -> do n1 <- evalIntExp g s exp1
                                                           return $ A4(o (toFloat n1) (toFloat n2))
                                else do (n1,n2) <- evalIntExp g s exp1 //// evalIntExp g s exp2
                                        return  $ A4  (o (toFloat n1) (toFloat n2))

-- Evaluar expresión booleana
evalBoolExp :: TableNames -> Context -> BoolExp -> IO(Either String Bool)
evalBoolExp s g (Not exp) = pattern2 (evalBoolExp s g exp)
                                     (\b -> retOk $ not b)

evalBoolExp s g (And exp1 exp2)  = applyEval s g exp1 exp2 (&&)

evalBoolExp s g (Or exp1 exp2)   = applyEval s g exp1 exp2 (||)

evalBoolExp s g (NotEq exp1 exp2) = pattern (evalBoolExp s g (Equal exp1 exp2))
                                            not

evalBoolExp s g (Equal exp1 exp2) = do let t = snd' g
                                           (Right n1,Right n2) = (evalIntExp t s exp1 , evalIntExp t s exp2)
                                           b  = (==) n1 n2
                                       return $ evalBoolExp' (==) exp1 exp2 s (snd' g)

evalBoolExp s g (Great exp1 exp2) = return $ evalBoolExp' (>)  exp1 exp2 s (snd' g)

evalBoolExp s g (Less  exp1 exp2) = return $ evalBoolExp' (<)  exp1 exp2 s (snd' g)

evalBoolExp s g (GrOrEq exp1 exp2) = applyEval s g (Great exp1 exp2) (Equal exp1 exp2) (||)

evalBoolExp s g (LsOrEq exp1 exp2) = applyEval s g (Less exp1 exp2) (Equal exp1 exp2) (||)

-- Determina si la consulta dml es vacía en el contexto g
evalBoolExp s g (Exist dml) = pattern (runQuery' g (conversion  dml))
                                      (\(_,False,_,_,[t]) -> not (isEmpty t))

-- Determina si el valor referido por el campo v pertenece a l
evalBoolExp s g (InVals (Field v) l) = pattern (return $ lookupList (snd' g) s v)
                                               (\x ->  elem x l)


-- Evalua si field está en la columna que es resultado de dml
evalBoolExp s g (InQuery f dml) = pattern2  (runQuery' g (conversion dml))
                                            (\(g1,b,s2,fields,[t]) -> return $
                                                                      if length fields /= 1 || b then errorIndFields -- La busqueda debe ser sobrre una columna
                                                                      else let [f2] = fields
                                                                           in do let (f1,tts) = case f of
                                                                                                 (Field f1) ->  (f1,s)
                                                                                                 (Dot s1 f1) -> (f1,[s1])
                                                                                 t1 <- lookupList (trd' g) s f1 -- Buscamos los tipos
                                                                                 t2 <- lookupList (trd' g1) s2 f2
                                                                                 if t1 /= t2 then  error "Algo anda mal" -- Deben coincidir
                                                                                 else -- obtener el valor de f1 y buscar que existe en t
                                                                                       do v <- lookupList (snd' g) tts f1
                                                                                          let r = fromList $ [(f2,v)]
                                                                                          return $ isMember [f2] r t)



evalBoolExp s g (Like f p) = return $ do t <- checkTypeExp s (trd' g) f
                                         if t == String then let (A1 v) = obtainValue s f (snd' g) in
                                                 ok $ findPattern v p
                                         else errorLike

  where findPattern [] [] = True
        findPattern (x:xs) ('_':ys) = findPattern xs ys -- '_' representa un solo caracter
        findPattern xs ['%'] = True -- '%' representa una cantidad indefinida de caracteres
        findPattern xs ('%':y:ys) = findPattern (dropWhile (\x -> x /= y) xs) (y:ys) -- consumir una cantidad indefinida de caracteres hasta encontrar el siguiente
        findPattern (x:xs) (y:ys) = if x == y then findPattern xs ys
                                    else False
        findPattern _ _ = False




applyEval s g exp1 exp2 op = pattern (evalBoolExp s g exp1 |||| evalBoolExp s g exp2)
                                     (\(b1,b2) -> op b1 b2 )

-- Evaluar expresión booleana (2do nivel)
evalBoolExp' :: (Args -> Args -> Bool) -> Args -> Args -> [String] -> TabReg ->  Either String Bool
evalBoolExp' o exp1 exp2 s t = do (n1,n2) <- evalIntExp t s exp1 //// evalIntExp t s exp2
                                  return $  o (toA4 n1) (toA4 n2)

      where isFieldOrDot (Field _) = True
            isFieldOrDot (Dot _ _) = True
            isFieldOrDot _ = False
            toA4 a@(A3 n) = A4 (toFloat a)
            toA4 a = a
