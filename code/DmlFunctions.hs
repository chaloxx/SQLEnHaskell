{-# LANGUAGE NoMonadFailDesugaring #-}



module DmlFunctions where
import Data.Typeable
import AST
import System.IO
import Url
import System.Directory
import DynGhc
import Avl hiding (singleton,All)
import Data.Char
import Data.Maybe
import Prelude hiding (lookup,print,fail)
import Data.HashMap.Strict hiding (foldr,map,size,null)
import Control.DeepSeq
import Error
import Data.Either
import Data.List (intersect,(\\),partition,isPrefixOf)
import qualified Data.Set as S (fromList,isSubsetOf,intersection,empty,difference)
import Data.Hashable
import COrdering (COrdering (..))
import Parsing (parse,sepBy,char,identifier)
import Check
import Control.Monad (when)
import Prelude hiding (fail,lookup)

-- Modulo de funciones dml






---- Insertar en una tabla
insert :: Env -> TableName -> AVL ([Args]) ->  IO ()
insert e n entry = do let (r,u) = (url (name e) (dataBase e) ++ "/") ||| name e
                      -- Calcular metadata
                      inf <- loadInfoTable ["scheme","types","key","fkey","haveNull"] e n :: IO [TableInfo]
                      case inf of
                         [] -> tableDoesntExist
                         [TS scheme,TT types,TK k, TFK fk, HN nulls] -> do  res <- obtainTable r n :: IO (Maybe (Tab))
                                                                            case res of
                                                                             Nothing -> error r
                                                                             Just t  -> insert' e (r++"/"++n) types scheme nulls k t entry fk

-- Segundo nivel de insertar
insert' _ _ _ _ _ _ _ E _= return ()
insert' e r types scheme nulls k t entry fk =
                                  do --Nro de argumentos recibidos
                                       let l = length scheme
                                       -- Calcular todas las tablas que son referenciadas por t
                                       fk' <- sequence $ map  (\(x,xs) -> do let path = url' e x
                                                                             tree <- obtainTable path x
                                                                             return (xs,tree))
                                                                             fk
                                       -- Separar entradas válidas de las inválidas a tráves de distintos chequeos
                                       let (t1,t2) = particionT2 (checks l e types scheme nulls k t fk') (\x -> fromList $ zip scheme x) entry
                                       -- Filtrar entradas con claves repetidas
                                       let (t3,t4) = repeatKey scheme k t2
                                       -- Escribir modificaciones en archivo fuente
                                       appendLine r t4
                                       -- Mostrar que entrada son inválidas
                                       sequence_ $ mapT putStrLn  t1
                                       -- Mostrar que entradas contienen claves repetidas
                                       when (not $ isEmpty t3) (do putStrLn $ "Las siguientes entradas contienen claves repetidas"
                                                                   sequence_ $ mapT (putStrLn.showAux scheme) t3)



-- Chequeos de seguridad
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
                    let r = url' e n
                    let u = name (fst' g)
                    res <- obtainTable r n
                    case res of
                        Nothing ->  putStrLn "La tabla no existe"
                        Just t -> do [TK k,TR ref] <- loadInfoTable ["key","refBy"] e n :: IO([TableInfo])
                                     let (xs,ys,zs) =  partRefDel  ref
                                     xs' <- obtainTableList e xs -- tablas que tienen una referencia de tipo restricted sobre t'
                                     ys' <- obtainTableList e ys -- tablas que tienen una referencia de tipo cascades sobre t'
                                     zs' <- obtainTableList e zs -- tablas que tienen una referencia de tipo nullifies sobre t'
                                     a <- ioEitherFilterT (fun k g n xs xs' ys ys' zs zs') t
                                     case a of
                                       Left msg -> putStrLn msg
                                       Right t' ->  reWrite t' r

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
                                                 error "Aca llega"
                                                 resolNull (fst' g) zs zs' k reg -- Si la restricción es nullifies nulificar todos los registros que apunten a reg (si aceptan nulos)
                                                 retOk False

                     -- Filtro simple (evalúa igualdad entre registros)
               where fun2 k x y = case c k x y of
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
        where fun k x y = case c2 k x y of
                           EQ -> fun2 k y
                           _ -> y
              -- Volver Nulos los valores de los atributos k
              fun2 [] y = y
              fun2 (k:ks) y = fun2 ks (updateHM (\x -> Just $ Nulo) k y)




-- Actualizar tabla n (primer nivel)
update :: Context -> String -> ([String],[Args]) -> BoolExp -> IO ()
update g n (fields,values) exp =
   do let r = url' (fst' g) n -- obtener ruta de tabla
      [TS sch,TT typ,TR ref,TK key,HN nulls] <- loadInfoTable ["scheme","types","refBy","key","haveNull"] (fst' g) n -- cargar esquemas y tipos
      update' g (fields,values) sch typ r n exp ref key nulls

-- Actualizar tabla (segundo nivel)
update' g (fields,values) sch typ r n exp ref key nulls =
  let types = fromList $ zip sch typ
      h = singleton n types
      at = trd' $ updateContext3 g h
      types' = map (\x -> types ! x) key
      setKeys = toSet key
      setFields = toSet fields
      setScheme = toSet sch in
      -- Chequear que los atributos modificados están dentro del esquema y que ninguno es parte de la key de la tabla
      if (not $ S.isSubsetOf setFields setScheme) || S.intersection setKeys setFields /= S.empty then errorUpdateFields fields
      else case checkTyped types' values >> checkTypeBoolExp exp [n] at of -- chequear tipos de valores recibidos y expresión booleana
              Left msg -> putStrLn msg
              Right _ -> do  res <- obtainTable r n -- cargar tabla
                             case res of
                              Nothing -> putStrLn "Error al cargar tabla..."
                              Just t -> do let vals = fromList $ zip key values
                                           let (xs,ys,zs) = partRefTable ref
                                           xs' <- obtainTableList (fst' g) xs
                                           ys' <- obtainTableList (fst' g) ys
                                           zs' <- obtainTableList (fst' g) zs
                                           res' <- ioEitherMapT (change nulls key n g exp vals xs xs' ys ys' zs zs' ) t
                                           case res' of
                                              Right t' -> reWrite t' r
                                              Left msg -> putStrLn msg

                 -- Función para modificar valores en registro x
           where toSet = S.fromList
                 -- Función para modificar los valores de aquellos registros para los cuales exp es un predicado válido
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
                          fun2 nulls vals k x y = case c2 k x y of
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
conversion (Join j t exp dml) = insertCola (2,Joinner j t exp) $ conversion dml
conversion (Where boolExp dml) = insertCola (3,Sigma boolExp) $ conversion dml
conversion (GroupBy args dml) = insertCola (4,Group args) $ conversion dml
conversion (Having boolExp dml) = insertCola (5,Hav boolExp) $ conversion dml
conversion (OrderBy args ord dml) = insertCola (6,Order args ord) $ conversion dml
conversion (Limit n dml) = insertCola (7,Top n) $ conversion dml
conversion (End) = []



-- Proyectar valores de las variables y agregarlas al contexto (sirve para subconsultas y para evitar ambiguedad con atributos del mismo nombre)
proy :: TableNames -> Context -> [Args] -> Reg -> IO(Either String Reg)
proy names g ls x = pattern2 (return $ divideRegister names (giveMeOnlyFields $ trd' g) x)
                                          -- mapear cada proyección y juntar valores
                             (\r -> do lr <- sequence $ map (proy' (updateContext2 g r) names) ls
                                       return $ tryJoin union emptyHM lr)


proy' :: Context -> TableNames -> Args -> IO (Either String Reg)
-- Proyectar (segundo nivel)
proy' g s (Field v)  = return $ do res <- lookupList (snd' g) s v
                                   ok $ singleton v res



--Subconsulta en selección
proy' g s (As (Subquery dml) (Field n)) = pattern2 (let c = conversion dml in runQuery' g c )
                                                   (\(_,_,_,l,[t]) -> if isSingletonT t && length l == 1 then let (k,r) = l !! 0 ||| value t
                                                                                                                  v = fromJust (lookup k r)
                                                                                                               in retOk $ singleton n v
                                                                       else errorPi4)


--Renombre de selección
proy' g s (As exp (Field f)) =  do res <- proy' g s exp
                                   return $ do reg <- res
                                               case elems reg of
                                                [value] -> ok $ singleton f value
                                                _ -> errorAs

-- Operador '.'
proy' g _ e@(Dot t v) =  return $ do  x <- lookupList (snd' g) [t] v
                                      return $ singleton (show2 e)  x


-- Clausula ALL mapea todos los atributos disponibles a valores
proy' g s (All) = retOk $ unions $ elems $ snd' g


-- -- Expresiones enteras
proy' g s q = return $ do  v@(A4 n) <- evalIntExp (snd' g) s q
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
                                                        (\m -> updateKey (show2 s1) (show2 s2) m)


-- Ejecuta la consulta dml en el estado g, imprimiendo los resultados
runQuery :: Context -> DML -> IO ()
runQuery g dml = do -- Convertir dml en una secuencia de operadores de álgebra relacional
                    let c = conversion dml
                    --Ejecutar
                    v <- runQuery' g c
                    case v of
                     Left msg -> putStrLn msg
                     Right (_,_,_,ys,[t]) -> printTable show2 ys t


-- Ejecución de consultas en un contexto g
runQuery' :: Context -> Cola AR -> IO(Either String Answer)

runQuery' g [] = retOk (g,False,[],[],[])


runQuery' g ((_,Uni a1 a2):xs) = runQuery'' g a1 a2 xs unionT
runQuery' g ((_,Inters a1 a2):xs) = runQuery'' g a1 a2 xs intersectionT
runQuery' g ((_,Dif a1 a2):xs) = runQuery'' g a1 a2 xs differenceT


-- Hacer JOINS

runQuery' g ((_, Joinner j tables exp):xs) =
    do r <- runQuery' g xs
       case r of
          Right (g',groupBy,names,fields,[t1]) ->
                     do v <- prod (fst' g) tables
                        case v of
                           Left msg -> retFail msg
                           Right (g2,n2,f2,t2) -> do let (t2',f2') = case intersect fields f2 of
                                                                      [] -> (t2,f2)
                                                                      _ -> let name = head n2
                                                                           in mapT (changeKey name f2) t2 ||| map (dot name) f2

                                                         f3 = fields ++ f2'
                                                         -- Producto cartesiano de registros
                                                         t3 = prod'' f3 t1 t2'
                                                         n3 = names ++ n2
                                                         -- Actualizar tabla de tipos
                                                         g31 = updateContext3 g' (trd' g2)
                                                         -- Juntar campos de todas las tablas
                                                         onlyFields = union (giveMeOnlyFields (snd' g31)) (giveMeOnlyFields (snd' g2))
                                                         -- Para poder agregar al contexto, inicialmente le damos valores nulos
                                                         onlyFieldsWithNull = mapHM createHMWithNull onlyFields
                                                         -- Actualizar árbol de tablas y campos
                                                         g32 = updateContext2 g31 onlyFieldsWithNull
                                                     case checkTypeBoolExp exp n3 (trd' g32) of
                                                        Left msg -> retFail msg
                                                        Right _  -> case j of
                                                                     Inner -> pattern (ioEitherFilterT (eval onlyFields n3 g32 exp) t3)
                                                                                      (\t4 -> (g32,groupBy,n3,f3,[t4]))

                                            --              JRight -> retOk $ (g',groupBym,table:names,mapT f t3)
                                            --              JLeft -> retOk $ (g',groupBym,table:names,mapT f t3)

    where eval onlyFields n3 g32 exp x = case divideRegister n3 onlyFields x of
                                          Left msg -> retFail msg
                                          Right r -> let g32' = updateContext2 g32 r -- Actualizar contexto con valores del registro
                                                     in evalBoolExp n3 g32' exp




-- Realiza proyecciones
runQuery' g ((_,Pi unique args):rs) =
 do r <- runQuery' g rs
    case r of
     Right (g',groupBy,names,fields,tables) ->
              --Si no hay una claúsula group by no se pueden usar funciones de agregado
              if not $ groupBy then case partition isAgg args of -- Separar funciones de agregado de selecciones comunes
                                     (_,[]) -> aux g unique names args tables   -- Caso con funciones de agregado
                                     ([],_) ->   -- Caso sin funciones de agregado
                                     -- Chequear tipo de  expresiones enteras si las hay
                                               case checkTypedExpList names (trd' g') args of
                                                 Right _ -> do res <- ioEitherMapT (proy names g' args) (isNull tables) -- Aplicar proyecciones
                                                               case res of
                                                                Right t -> let args'= toKey fields args in   -- Obtener atributos solicitados
                                                                           retOk $ distinct g' unique names args' t
                                                                Left msg -> retFail msg
                                                 Left msg -> retFail msg

                                     _ -> errorPi2   -- Error al mezclar las operaciones

                                                 -- En este caso se uso la claúsula group by
                else  if All `elem` args then errorPi3
                      else aux g' unique names args tables

     Left msg -> retFail msg

  where -- Aplica función withAgg para ejecutar funciones de agregado
        aux g unique names args tables = pattern (processAgg g args names tables)
                                                 (\(fields,tables) -> distinct g unique names fields tables)
        toKey _ [] = []
        toKey fields (All:xs) = fields ++ (toKey fields xs)
        toKey fields (arg:xs) = (show2 arg) : (toKey fields xs)

        -- Eliminar registros duplicados si se solicita
        distinct g unique names fields table = if unique then let table' = mergeT (c fields) E table in
                                                              (g,True,names,fields,[table'])
                                               else (g,False,names,fields,[table])
         -- Chequear el tipo de una lista de expresiones

        isNull [] = emptyT
        isNull tables = head tables

-- Ejecuta producto cartesiano
runQuery' g ((_,Prod args):xs) =
     pattern (prod (fst' g) args)
             (\(g1,names,fields,t) -> let g2 = updateContext2 g (snd' g1)
                                          g3 = updateContext3 g2 (trd' g1)
                                      in  (g3,False,names,fields,[t]))

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
                 let (setArgs,setFields) = toSet ls ||| toSet fields
                 if isSubset setArgs setFields then do let t' = group ls t
                                                       return (g',True,tables,fields,t')
                 else errorGroup (diff setArgs setFields)

    where toSet = S.fromList
          isSubset = S.isSubsetOf
          diff = S.difference

runQuery' g ((_,Hav exp):xs) = pattern2 (runQuery' g xs)
                                        (\(g,b,names,fields,tables) -> if not b then errorHav
                                                                       else case checkTypeBoolExp exp names (trd' g) of
                                                                              Left msg -> retFail msg
                                                                              _ -> pattern (ioEitherFilter (aux names g exp) tables)
                                                                                           (\tables' -> (g,b,names,fields,tables')))


 where aux names g e t = pattern2 (replaceAgg g names e t)
                                  (\exp -> pattern2 ( (return $ divideRegister names (giveMeOnlyFields $ trd' g) (value t)))
                                                    (\reg -> let g' = updateContext2 g reg in
                                                             evalBoolExp names g' exp))



runQuery' g ((_,Order ls ord):xs) =
  do r <- runQuery' g xs
     return $ do (g',b,l1,l2,[s]) <- r
                 let ls' = map show ls
                 case partition (\x -> x `elem` l2) ls'  of
                  (_,[]) -> case ord of
                             A -> ret g' l1 l2 s (compareAsc ls')
                             D -> ret g' l1 l2 s (compareDesc ls')
                  (_,s) -> errorOrder s


  where ret g' l1 l2 t f = do let t' = sortedT f t
                              return $ (g',False,l1,l2,[t'])
        compareAsc (x:xs) m1 m2 = let (e1,e2) = (m1 ! x) ||| (m2 ! x) in
                                case e1 `compare` e2  of
                                 LT -> Lt
                                 GT -> Gt
                                 EQ -> if null xs then Lt
                                       else compareAsc xs m1 m2
        compareDesc (x:xs) m1 m2 = compareAsc (x:xs) m2 m1

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
                      let (t1,t2) = sortedT (c l12) (head s1) ||| sortedT (c l12) (replaceAllKeys l22 l12 (head s2)) -- Ordenar árboles para hacer una unión ordenada (mejor eficiencia)
                      -- ambos entornos son iguales, tomamos el primero
                      ok (g13,False,ls,l12,[op (c l12) t1 t2])

 where notUnique s = not $ length s == 1

       notEqualLen l1 l2 = not $ length l1 == length l2

       equalType _ _ _ _ [] [] = True
       equalType e1 e2 l11 l21 (x:xs) (y:ys) = if lookupList e1 l11 x == lookupList e2 l21 y then equalType e1 e2 l11 l21 xs ys
       else False
       equalType _ _ _ _ _ _ = False

       replaceAllKeys  [] _ t = t
       replaceAllKeys (x:xs) (y:ys) t = if x /= y then replaceAllKeys xs ys (mapT (updateKey x y) t)
                                        else replaceAllKeys xs ys t







-- Producto cartesiano (primer nivel)
prod :: Env -> [Args] -> IO (Either String (Context,TableNames,FieldNames,Tab))
prod _ [] = retFail "Sin argumentos"


-- Caso una sola tabla
prod e ([s]) = pattern  (prod' e s)
                        (\(g,n,f,t) ->  (g,[n],f,t))


-- Caso 2 tablas
prod e ([s1,s2]) = pattern ( prod' e s1 |||| prod' e s2)
                           (\((g1,n1,fields1,t1),(g2,n2,fields2,t2)) -> let (t1',t2') = mapT (changeKey n1 fields1) t1 ||| mapT (changeKey n2 fields2) t2
                                                                            (fields1',fields2') = map (dot n1) fields1 ||| map (dot n2) fields2
                                                                            fullFields = fields1' ++ fields2'
                                                                        in  (updateContext3 g1 (trd' g2),[n1,n2],fullFields,prod'' fullFields t1' t2'))

-- Caso 3 o más tablas
prod e (s:ls) = pattern (prod  e ls |||| prod' e s)
                        (\((g1,n1,fields1,t1),(g2,n2,fields2,t2)) -> let t2' = mapT (changeKey n2 fields2) t2
                                                                         allFields = (map (dot n2) fields2) ++ fields1
                                                                     in (updateContext3 g1 (trd' g2),n2:n1,allFields, prod'' allFields t1 t2'))
-- Concatenación entre 2 cadenas agregando un punto en el medio
dot s x = s ++ "." ++ x

-- Cambiar llaves de los registros
changeKey _ [] _ = emptyHM
changeKey s (x:xs) r = union ((singleton (dot s x)) (r ! x)) (changeKey s xs r)



-- Obtiene una tabla
-- Producto cartesiano (segundo nivel)
-- Primer caso : Subconsulta con renombre
prod' :: Env -> Args -> IO(Either String (Context,String,FieldNames,Tab))
prod' e (As (Subquery s) (Field n)) = let c = conversion s
                                      in pattern2  (runQuery' (e,emptyHM,emptyHM) c)
                                                   (\(g,b,names,fields,tables) -> if b then errorProd2
                                                                                  else let types1 = aux fields names (trd' g)  -- Tomamos los tipos de la consulta recursiva
                                                                                           types2 = singleton n types1 -- Los agrupamos bajo el nombre dado
                                                                                           g1 = (e, emptyHM, types2) -- Creamos un nuevo contexto
                                                                                       in retOk (g1,n,fields,retHeadOrNull tables))

 where aux _ [] _ = emptyHM
       aux fields (x:xs) types = let t = filterWithKey (\y -> \ _ -> y `elem` fields || (x `dot` y) `elem` fields ) (types ! x) -- Solo nos importa el contexto para los campos seleccionados
                                 in union t (aux fields xs types)






-- Segundo caso : Tabla con renombre
prod' e (As (Field n1) (Field n2)) = pattern (prod' e (Field n1))
                                             (\(g,_,fields,t) -> let g' = (fst' g, snd' g, updateKey n1 n2 (trd' g))
                                                                 in (g',n2,fields,t))

-- Tercer caso : Tabla comun
prod' e (Field n) = let (path,user) = (url  (name e) (dataBase e)++"/") ||| name e
                    in do res <- obtainTable path n
                          case res of
                           Nothing -> errorProd n
                           Just t -> do inf <- loadInfoTable ["scheme","types"] e n-- Obtener esquema y tipos
                                        case inf of
                                         [] -> errorProd n
                                         [TS scheme, TT types] -> let types1 = singleton n (fromList $ zip scheme types)
                                                                      fieldsTree = singleton n $ fromList $ map (\x -> (x,Nulo)) scheme
                                                                      g = (e,fieldsTree,types1)
                                                                  in retOk  (g ,n ,scheme,t)

createHMWithNull [] = emptyHM
createHMWithNull (x:xs) = union (singleton x Nulo) (createHMWithNull xs)



-- Producto cartesiano (segundo nivel),realiza el producto entre 2 tablas
prod'' :: [String] -> Tab -> Tab -> Tab
prod'' _ E t = E
prod'' _ t E = E
prod'' fields t1 t2 = let (tl,tr) = prod'' fields (left t1) t2 ||| prod'' fields (right t1) t2
                          t = mergeT (c fields) tl tr
                      in mergeT (c fields) t (prod''' (value t1) t2)
  where prod''' x t = mapT (union x) t




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
replaceAgg _ _ exp _ = retOk exp


-- replace (sedundo nivel)
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
evalAgg''' d s t e f = if d then let t' = mergeT (c [s]) E t
                                 in foldT f e t'
                       else foldT f e t


posInf :: Float
posInf = 1/0

negInf :: Float
negInf = - 1/0

-- Elimina elementos duplicados si se solicita previamente a aplicar la función de agregado


-- Toma una lista de atributos y un árbol y descompone el árbol en clases según los atributos recibidos
group :: [String] -> AVL (HashMap String Args) -> [AVL (HashMap String Args)]
group _ E = []
group xs t = let a = value t
                 v = fromList $ map (\x -> (x,a ! x)) xs
                 (t1,t2) = particionT (equal xs v) t
             in t2 : group xs t1

      where equal xs v x = case c xs v x of
                            Eq _ -> True
                            _ -> False




-- Actualiza el valor de la llave k2 a k1 en m
updateKey  ::  (Eq k, Hashable k) => k -> k -> HashMap k v -> HashMap k v
updateKey k1 k2 m = let m' = insertHM k2 (m ! k1) m
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
                                         Nothing -> error $ show r--fail $ "No se pudo encontrar el atributo " ++ str
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

evalBoolExp s g (Equal exp1 exp2) = return $ evalBoolExp' (==) exp1 exp2 s (snd' g)

evalBoolExp s g (Great exp1 exp2) = return $ evalBoolExp' (>)  exp1 exp2 s (snd' g)

evalBoolExp s g (Less  exp1 exp2) = return $ evalBoolExp' (<)  exp1 exp2 s (snd' g)


-- Determina si la consulta dml es vacía en el contexto g
evalBoolExp s g (Exist dml) = pattern (runQuery' g (conversion  dml))
                                      (\(_,False,_,_,[t]) -> not (isEmpty t))

-- Determina si el valor referido por el campo v pertenece a l
evalBoolExp s g (InVals (Field v) l) = pattern (return $ lookupList (snd' g) s v)
                                               (\x ->  elem x l)


-- Evalua si field está en la columna que es resultado de dml
evalBoolExp s g (InQuery (Field f1) dml) = pattern2  (runQuery' g (conversion dml))
                                                     (\(g1,b,_,fields,[t]) -> return $
                                                                              if length fields /= 1 || b then error "Error" -- La busqueda debe ser sobre una columna
                                                                              else let [f2] = fields
                                                                                   in do t1 <- lookupList (trd' g1) s f1 -- Buscamos los tipos
                                                                                         t2 <- lookupList (trd' g1) s f2
                                                                                         if t1 /= t2 then  error "Algo anda mal" -- Deben coincidir
                                                                                         else do v <- lookupList (snd' g1) s f1
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
                                  --error $ show n1 ++ " " ++ show n2
                                  return $ o n1 n2

      where isFieldOrDot (Field _) = True
            isFieldOrDot (Dot _ _) = True
            isFieldOrDot _ = False
