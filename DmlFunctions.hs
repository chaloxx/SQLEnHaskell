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
import Prelude hiding (fail,lookup,filter,lookup,print)
import Data.HashMap.Strict hiding (foldr,map,size,null)
import Control.DeepSeq
import Error
import Data.Either
import Data.List (intersect,(\\),partition,isPrefixOf,intercalate)
import Data.List.Unique (uniq,repeated)
import qualified Data.Set as S (fromList,isSubsetOf,intersection,empty,difference)
import Data.Hashable
import COrdering (COrdering (..))
import Parsing (parse,sepBy,char,identifier)
import Check
import Control.Monad (when)


-- Modulo de funciones dml






---- Insertar en una tabla
insert :: TableName -> AVL ([Args]) ->  Query ()
insert n entry = do e <- askEnv
                    let (r,u) = (url e)||| name e
                    -- Calcular metadata
                    [TS scheme,TT types,TK k, TFK fk, HN nulls] <- loadInfoTable ["scheme","types","key","fkey","haveNull"] e n :: Query [TableInfo]
                    t <- obtainTable r n :: Query Tab
                    insert' e (r++"/"++n) types scheme nulls k t entry fk

-- Segundo nivel de insertar
insert' _ _ _ _ _ _ _ E _= return ()
insert' e r types scheme nulls k t entry fk =
                                  do --Nro de argumentos recibidos
                                       let l = length scheme
                                       let dbPath = url e
                                       -- Calcular todas las tablas y sus keys que son referenciadas por t
                                       fkInfo <- sequence $ map  (\(tabName,refs) -> do table <- obtainTable dbPath tabName
                                                                                        [TK key] <- loadInfoTable ["key"] e tabName
                                                                                        return (refs,table,key))
                                                                                        fk
                                       -- Separar entradas válidas de las inválidas a tráves de distintos chequeos
                                       let (t1,t2) = particionT2 (checks l e types scheme nulls k t fkInfo) (\x -> fromList $ zip scheme x) entry
                                       -- Filtrar entradas con claves repetidas
                                       let (t3,t4) = repeatKey scheme k t2
                                       Q(\c -> do -- Escribir modificaciones en archivo fuente
                                                  appendLine r t4
                                                  -- Mostrar que entrada son inválidas
                                                  sequence_ $ mapT putStrLn  t1
                                                  -- Mostrar que entradas contienen claves repetidas
                                                  when (not $ isEmpty t3) (do putStrLn $ "Las siguientes entradas contienen claves existentes"
                                                                              sequence_ $ mapT (putStrLn.showAux scheme) t3)
                                                  return $ Right (c,()))





-- Chequeos para mantener la consistencia de la BD
 where checks l e types scheme nulls k t' fkInfo x = do checkLength l x -- Cantidad de argumentos
                                                        checkTyped types x -- Tipos
                                                        let reg = (fromList $ zip scheme x)
                                                        checkKey t' k reg x -- ya existe un registro con la clave k?
                                                        checkNulls scheme nulls x -- puede haber valores nulos?
                                                        checkForeignKey reg fkInfo -- la clave foránea apunta a un registro existente?
       showAux k x = fold $ map (\entry -> x ! entry ) k


toText :: [Args] -> String
toText [] = ""
toText (x:[]) = (show x)
toText (x:xs) = (show x) ++ " , " ++ (toText xs)





-- Borrar aquellos registros de una tabla para los cuales exp es verdadero
delete :: String ->  BoolExp -> Query ()
delete n exp = do e <- askEnv
                  let r = url  e
                  let u = name e
                  t <- obtainTable r n
                  [TK k,TR ref, TT types ,TS scheme] <- loadInfoTable ["key","refBy","types","scheme"] e n :: Query [TableInfo]
                  let tabTypes = singleton n $ fromList $ zip scheme types
                  let tabVals = singleton n $ fromList $ map (\f -> (f,Nulo)) scheme
                  updateTypes tabTypes
                  updateVals tabVals
                  let (xs,ys,zs) =  partRefDel  ref
                  xs' <- obtainTableList xs -- tablas que tienen una referencia de tipo restricted sobre t'
                  ys' <- obtainTableList ys -- tablas que tienen una referencia de tipo cascades sobre t'
                  zs' <- obtainTableList zs -- tablas que tienen una referencia de tipo nullifies sobre t'
                  t' <- ioEitherFilterT (predic k n xs xs' ys ys' zs zs') t
                  Q(\c -> do reWrite t' $ r ++ n
                             return $ Right (c,()))

         -- Filtro complicado (evalua expresión booleana y chequea restricciones para cada registro)
  where  predic k n xs xs' ys ys' zs zs' reg =
           do let r = singleton n reg
              -- Actualizar contexto
              updateVals r
              -- Evaluar expresión booleana
              b <- evalBoolExp [n] exp
              if not b then retOk True -- Devuelve true si la expr dio falso
              else do resolRestricted xs xs' k reg
                      resolCascades ys ys' k  (filterT (predic2 k reg))  reg -- Si la restricción es cascades borrar todos los registros que apunten a reg
                      resolNull zs zs' k reg -- Si la restricción es nullifies nulificar todos los registros que apunten a reg (si aceptan nulos)
                      retOk False

                     -- Filtro simple (evalúa igualdad entre registros)
               where predic2 k x y = case comp k x y of
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
resolRestricted :: [String] -> [Tab] -> [String] -> Reg -> Query ()
resolRestricted _ [] _ _ = return ()
resolRestricted (n:ns) (t:ts) k x = if isMember k x t then errorRestricted x n
                                    else resolRestricted ns ts k x


-- Esparce borrado o modificación sobre los registros cuya clave foránea es k de una lista de tablas
resolCascades :: [String] -> [Tab] -> [String] -> (Tab -> Tab) -> Reg -> Query ()
resolCascades  _ [] _ _  _ = return ()
resolCascades (n:ns) (t:ts) k f x = do  e <- askEnv
                                        let (t',r) =  f t ||| url' e n
                                        fromIO $  reWrite t' r
                                        resolCascades ns ts k f x



-- Convierte a Nulo los valores de las claves foráneas k de una lista de tablas
resolNull :: [String] -> [Tab] -> [String] -> Reg -> Query ()
resolNull _ [] _ _ = return ()
resolNull (n:ns) (t:ts) k x = do e <- askEnv
                                 let (t',r) = mapT (fun k x) t ||| url' e n
                                 fromIO $ reWrite t' r
                                 resolNull ns ts k x

              -- Comparar igualdad entre los valores de los atributos k
        where fun k x y = case comp2 k x y of
                           EQ -> fun2 k y
                           _ -> y
              -- Volver Nulos los valores de los atributos k
              fun2 [] y = y
              fun2 (k:ks) y = fun2 ks (updateHM (\x -> Just $ Nulo) k y)




-- Actualizar tabla n (primer nivel)
update :: String -> ([String],[Args]) -> BoolExp -> Query ()
update n (fields,numExps) exp = do e <- askEnv
                                   [TS sch,TT typ,TR ref,TK key,HN nulls] <- loadInfoTable ["scheme","types","refBy","key","haveNull"] e n -- cargar esquemas y tipos
                                   let tabTypes = singleton n $ fromList $ zip sch typ
                                   let tabVals = singleton n $ fromList $   map (\f -> (f,Nulo)) sch
                                   updateVals tabVals
                                   updateTypes tabTypes
                                   update'  fields numExps sch n exp ref key nulls

-- Actualizar tabla (segundo nivel)
update' fields numExps sch n boolExp ref key nulls =
  let setKeys = toSet key
      setFields = toSet fields
      setScheme = toSet sch in
      -- Chequear que los atributos modificados están dentro del esquema y que ninguno es parte de la key de la tabla
      if (not $ S.isSubsetOf setFields setScheme) || S.intersection setKeys setFields /= S.empty then errorUpdateFields fields
      else do  tabTypes <- askTypes
               Q (\c -> return $ do-- -- chequear tipos de expresiones numéricas y expresión booleana
                                    sequence $ map  (\e -> checkTypeExp [n] tabTypes e) numExps
                                    checkTypeBoolExp boolExp [n] tabTypes
                                    return (c,()))
               e <- askEnv
               let r = url e
               t <- obtainTable r n -- cargar tabla
               let (xs,ys,zs) = partRefTable ref
               xs' <- obtainTableList xs
               ys' <- obtainTableList ys
               zs' <- obtainTableList zs
               t' <- ioEitherMapT (updateValue nulls key n boolExp fields numExps xs xs' ys ys' zs zs' ) t
               Q(\c -> do reWrite t' $ r ++ n
                          return $ Right (c,()))

                 -- Función para modificar valores en registro x
           where toSet = S.fromList
                 -- Función para modificar los valores de aquellos registros para los cuales exp es un predicado válido
                 updateValue nulls k n boolExp fields numExps xs xs' ys ys' zs zs' reg =
                    do let r = singleton n reg
                       -- Evaluar expresion booleana
                       updateVals $ singleton n reg
                       b <- evalBoolExp [n] boolExp
                       if b then do
                                    -- Evaluar
                                    vals <- sequence $ map (\e -> evalIntExp [n] e) numExps
                                    let vals' = fromList $  zip fields vals
                                    -- Chequear inconsistencias con referencias
                                    resolRestricted xs xs' k reg
                                    resolCascades ys ys' k (mapT (funMap2 nulls vals' k reg)) reg
                                    resolNull zs zs' k reg
                                    -- Mapear
                                    return $ mapWithKey (funMap nulls vals') reg
                       else retOk reg

                          -- Actualiza el valor del atributo k
                    where funMap nulls vals k v = case lookup k vals of
                                                Nothing -> v
                                                Just Nulo -> if belong nulls k then Nulo
                                                             else v
                                                Just v' -> v'
                          funMap2 nulls vals k x y = case comp2 k x y of
                                                    EQ -> mapWithKey (funMap nulls vals) y
                                                    _ -> y


-- Separa una lista de tablas, clasificandolas segun sus opciones de referencia
partRefTable [] = ([],[],[])
partRefTable ((x,_,v):r) =   let (xs,ys,zs) = partRefTable r in
                           case  v of
                            Restricted -> (x:xs,ys,zs)
                            Cascades -> (xs, x:ys, zs)
                            Nullifies -> (xs,ys,x:zs)

-- Toma una lista de nombres de tabla y devuelve una lista de tablas
obtainTableList :: [TableName] -> Query [Tab]
obtainTableList [] = return []
obtainTableList (x:xs) = do e <- askEnv
                            let r = url e
                            t <- obtainTable r x
                            ts <- obtainTableList xs
                            return (t:ts)






-- Función para obtener valor de variables de tupla
obtainValue :: [String] -> Args -> ContextFun Args -> Args
obtainValue s (Field v) r = case lookupList r s v of
                              Right x -> x
                              _ -> error "ObtainValue error"
obtainValue _ (Dot s2 v) r = case lookupList r [s2] v of
                               Right x -> x
                               _ -> error "ObtainValue error"







--- Encolar acciones
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
conversion (Select dist args dml) = insertCola (6,Pi dist args) $ conversion dml
conversion (From args dml) = insertCola (1,Prod args) $ conversion dml
conversion (Where boolExp dml) = insertCola (3,Sigma boolExp) $ conversion dml
conversion (GroupBy args dml) = insertCola (4,Group args) $ conversion dml
conversion (Having boolExp dml) = insertCola (5,Hav boolExp) $ conversion dml
conversion (OrderBy args ord dml) = insertCola (7,Order args ord) $ conversion dml
conversion (Limit n dml) = insertCola (8,Top n) $ conversion dml
conversion (End) = []



-- Mapear valores de las variables
proy :: TableNames -> [Args] -> Reg -> Query Reg
proy names ls reg = do -- Actualizar valores en el
                       fromRegisterToContext names reg
                       proys <- sequence $ map (proy' names) ls
                       -- Unir proyecciones individuales para formar un registro
                       return $  foldl (\x y -> union x y) emptyHM proys




proy' :: TableNames -> Args -> Query Reg
-- Proyectar (segundo nivel)
proy' s (Field f)  = do vals <- askVals
                        a <- fromEither $ lookupList vals s f
                        return $ singleton f a







--Subconsulta en selección
proy' s (As (Subquery dml) (Field n)) = do let comms = conversion dml
                                           (_,_,l,[t]) <-  runQuery' comms
                                           if isSingletonT t && length l == 1 then let (k,r) = l !! 0 ||| value t
                                                                                       v = fromJust (lookup k r)
                                                                                       in retOk $ singleton n v
                                           else errorPi4


--Renombrar selección
proy' s (As exp (Field f)) =  do reg <- proy' s exp
                                 case elems reg of
                                        [value] -> return $ singleton f value
                                        _ -> errorAs

-- Operador '.'
proy' s e@(Dot t v) =  do vals <- askVals
                          x <- fromEither $ lookupList vals [t] v
                          return $ singleton (show2 e)  x


-- Clausula ALL mapea todos los atributos disponibles a valores
proy' s (All) = do tabVals <- askVals
                   return $ unions $ elems $ tabVals


-- -- Expresiones enteras
proy' s q = do  vals <- askVals
                v@(A4 n) <- evalIntExp s q
                if isInt n then return $ singleton (show2 q) (A3 (round n))
                else return $ singleton (show2 q) v




-- Procesamiento de selecciones para el caso con funciones de agregado
-- Reduce una lista de tablas a una  sola tabla
processAgg  :: [Args] -> TableNames -> [Tab] -> Query ([String],Tab)
processAgg ls names ts = do  res <- sequence $ map (processAgg' names ls) ts
                             let ls' = map show2 ls
                             return (ls',toTree res)


processAgg' :: TableNames -> [Args] -> Tab -> Query Reg
processAgg'  _ [] _ = return empty


processAgg' ns (All:xs) t = errorPi3

processAgg' ns ((As arg (Field k) ):xs) t   = do reg <- processAgg' ns (arg:xs) t
                                                 let oldK = show2 arg
                                                 return $ updateKey oldK k reg


processAgg' ns (arg:xs) t   = do fromRegisterToContext ns $ value t
                                 arg' <- evalAgg ns arg t
                                 v <- evalIntExp ns arg'
                                 let m = singleton (show2 arg) v
                                 reg <- processAgg' ns xs t
                                 return $  union m reg



-- Ejecuta la consulta dml
runQuery :: DML -> Query (FieldNames,Tab)
runQuery dml = do -- Convertir dml en una secuencia de operadores de álgebra relacional
                  let ops = conversion dml
                  --Ejecutar
                  (_,ns,fs,[t]) <- runQuery' ops
                  return (fs,t)

-- Ejecución de consultas
runQuery' :: Cola AR -> Query Answer

runQuery' ((_,Uni a1 a2):xs) = error "No implementado"
runQuery' ((_,Inters a1 a2):xs) = error "No implementado"
runQuery' ((_,Dif a1 a2):xs) = error "No implementado"


runQuery' [] = return (False,[],[],[emptyT])

-- Realiza proyecciones
runQuery'  ((_,Pi unique args):rs) =
 do (groupBy,names,fields,tables) <- runQuery' rs
    if not $ groupBy then case partition isAgg args of -- Separar funciones de agregado de selecciones comunes
                            -- (_,[]) -> applyWithAgg unique names args tables   -- Caso con funciones de agregado
                            ([],_) ->   do -- Caso sin funciones de agregado
                                            tabTypes <- askTypes
                                            Q(\c -> return $ fmap (\x -> (c,x)) $ checkTypedExpList names tabTypes args)
                                            t <- ioEitherMapT (proy names args) (isNull tables) -- Aplicar proyecciones
                                            let newFields = toFieldName fields args    -- Obtener strings para imprimir de atributos solicitados
                                            let newTabName = foldl (++) "" names
                                            tabVals <- askVals
                                            updateFieldsInContext newTabName args
                                            if All `elem` args then do collapseContext newTabName names fields
                                                                       distinct unique [newTabName] newFields t
                                            else  do -- Obtener que atributos deben mantenerse en el contexto
                                                     let fieldInContext = toFieldName2 args
                                                     collapseContext newTabName names fieldInContext
                                                     distinct unique  [newTabName] newFields t -- Borrar atributos innecesarios




                            _ -> errorPi2   -- Error al mezclar las operaciones

    -- En este caso se uso la claúsula group by
    else   do -- Aplica función processAgg para ejecutar funciones de agregado
               (fields,t) <- processAgg args names tables
               let newTabName = foldl (++) "" names
               let fieldInContext = toFieldName2 args
               updateFieldsInContext newTabName args
               collapseContext newTabName names fieldInContext
               distinct unique [newTabName] fields t



  where toFieldName _ [] = []
        toFieldName fields (All:xs) = fields ++ (toFieldName fields xs)
        toFieldName fields (arg:xs) = (show2 arg) : (toFieldName fields xs)

        toFieldName2 [] = []
        toFieldName2 (Field v : xs) = v : toFieldName2 xs
        toFieldName2 ((Dot _ v): xs) = v : toFieldName2 xs
        toFieldName2 ((As _ (Field v)):xs) =  v : toFieldName2 xs
        toFieldName2 (arg:xs) =  show2 arg : toFieldName2 xs


        -- Eliminar registros duplicados si se solicita
        distinct unique names fields table = return $ if unique then let table' = mergeT (comp fields) E table in
                                                                     (True,names,fields,[table'])
                                                      else  (False,names,fields,[table])
         -- Chequear el tipo de una lista de expresiones

        isNull [] = emptyT
        isNull tables = head tables

-- Ejecuta producto cartesiano
runQuery' ((_,Prod args):xs) =
     do     (names,fields,ts) <-  prod args
            -- Que atributos tienen mismo nombre
            let commonFields = repeated fields
            -- Que tablas tienen mismos atributos
            tabVals <- askVals
            tablesToChange <- fromEither $ filterTables tabVals names commonFields
            let index = map  (\n -> dlElemIndex n names) tablesToChange
            -- Cambiar nombre de atributos en tablas y contexto
            tsAndFs <- sequence $ map (\i -> changeTable (names!!i) (ts!!i) commonFields) index
            let (ts',fs) = unzip tsAndFs
            let tsWithIndex = zip index ts'
            -- Tablas finales
            let funMap2 n  = let i = dlElemIndex n names
                             in if i `elem` index then dlLookup i tsWithIndex
                                else ts !! i
            let ts'' = map funMap2 names
            -- Producto entre todas las tablas
            (fs',t) <- cartesianProd $ zip names ts''
            return (False,names,fs',[t])


      where changeTable n t cf = do fs <- fieldsOfTable n
                                    let cf' = dlFilter (\c -> c `elem` fs) cf
                                    let t' =  mapT (funMap n cf') t
                                    sequence $ map (\f -> updateFieldsInContext' n f (n//f)) cf'
                                    let newFields = map (n//) cf'
                                    return (t',newFields)

            funMap n fs reg = let newReg = unions $ map (\f -> singleton (n//f) (reg!f)) fs
                                  oldReg = filterWithKey (\k v -> not $ elem k fs) reg
                              in union newReg oldReg





-- Ejecuta selección
runQuery' ((_,Sigma exp):xs) =
     do  (b,localNames,fields,[t]) <- runQuery' xs
         tabTypes <- askTypes
         tabNames <- giveMeTableNames
         let tabNames' = localNames ++ [x | x<-tabNames, not $ x `elem` localNames]
         fromEither $  checkTypeBoolExp exp tabNames' tabTypes
         t' <- ioEitherFilterT (\reg-> do -- Actualizar contexto
                                          fromRegisterToContext localNames reg
                                          -- Evaluar expresión booleana
                                          evalBoolExp tabNames'  exp) t
         return (b,localNames,fields,[t'])





-- Agrupa por atributos
runQuery' ((_,Group args):xs) = do (_,ns,fields,[t]) <- runQuery' xs
                                   let ls = map show2 args
                                   ts <- group ns ls t
                                   tabVals <- askVals
                                   --(ls',) <- fromEither $ sequence $ map (\x -> lookupList' tabVals ns x) ls
                                   return (True,ns,ls ,ts)



runQuery' ((_,Hav exp):xs) = do (groupBy,names,fields,tables) <- runQuery' xs
                                if not groupBy then errorHav
                                else do  tabTypes <- askTypes
                                         fromEither $ checkTypeBoolExp exp names tabTypes
                                         tables' <- ioEitherFilterList (mapFun names exp) tables
                                         return (True,names,fields,tables')

                               -- Reemplazar valores en expresion
 where mapFun names e t = do exp <- replaceAgg names e t
                             fromRegisterToContext names $ value t
                             evalBoolExp names exp
       ioEitherFilterList f [] = retOk []
       ioEitherFilterList f (x:xs) = do res <- ioEitherFilterList f xs
                                        b <- f x
                                        if b then return (x:res)
                                        else return res




runQuery' ((_,Order ls ord):xs) =
  do (b,l1,l2,[s]) <- runQuery' xs
     let ls' = map show2 ls
     case partition (\x -> x `elem` l2) ls'  of
                  (_,[]) -> case ord of
                             A -> order l1 l2 s (compareAsc ls')
                             D -> order l1 l2 s (compareDesc ls')
                  (_,s) -> error $ show ls' ++ " " ++ show l2--error errorOrder s


  where order  l1 l2 t f = do let t' = sortedT f t
                              return $ (False,l1,l2,[t'])
        compareAsc xs m1 m2 = comp xs m1 m2
        compareDesc xs m1 m2 = comp xs m2 m1

runQuery' ((_,Top n):xs) =
   do q@(b,l1,l2,s) <- runQuery' xs
      if length s /= 1  then errorTop
      else if n < 0 then errorTop2
           else case splitAtL n (head s) of
                    Left _ -> return q
                    Right (t',_) -> return (b,l1,l2,[t'])

-- Segundo nivel (operaciones de conjuntos)
--
-- runQuery'' g a1 a2 xs op =
--  do let (r1',r2') = runQuery' g a1 ||| runQuery' g a2
--     r1 <- r1'
--     r2 <- r2'
--     return $ do
--     (g1,_,l11,l12,s1) <- r1
--     (g2,_,l21,l22,s2) <- r2
--     if notUnique s1 || notUnique s2 then errorSet
--     else if notEqualLen l12 l22 then errorSet2
--          else if not $ equalType (trd' g1) (trd' g2) l11 l21 l12 l22  then errorSet3
--               else do let ls =  unionL l11 l21 -- unir tablas relacionadas
--                       let g12 =  updateContext2 g1 (snd' g2) -- unir valor de variables de tupla
--                       let g13 =  updateContext3 g12 (trd' g2)    -- unir tipo de variables de tupla
--                       let (t1,t2) = sortedT (c l12) (head s1) ||| sortedT (c l12) (replaceAllKeys l22 l12 (head s2)) -- Ordenar árboles para hacer una unión ordenada (mejor eficiencia)
--                       -- ambos entornos son iguales, tomamos el primero
--                       ok (g13,False,ls,l12,[op (c l12) t1 t2])
--
--  where notUnique s = not $ length s == 1
--
--        notEqualLen l1 l2 = not $ length l1 == length l2
--
--        equalType _ _ _ _ [] [] = True
--        equalType e1 e2 l11 l21 (x:xs) (y:ys) = if lookupList e1 l11 x == lookupList e2 l21 y then equalType e1 e2 l11 l21 xs ys
--        else False
--        equalType _ _ _ _ _ _ = False
--
--        replaceAllKeys  [] _ t = t
--        replaceAllKeys (x:xs) (y:ys) t = if x /= y then replaceAllKeys xs ys (mapT (updateKey x y) t)
--                                         else replaceAllKeys xs ys t
--
--





-- Recupera tablas (primer nivel)
prod :: [Args] -> Query (TableNames,FieldNames,[Tab])
prod [] = return ([],[],[])

prod (s:xs) = do  (n,fs,t) <- prod' s
                  (ns,fs2,ts) <- prod xs
                  return (n:ns,fs++fs2,t:ts)









-- Obtiene tablas
-- Producto cartesiano (segundo nivel)
-- Primer caso : Subconsulta con renombre
prod' :: Args -> Query (TableName,FieldNames,Tab)
prod' (Subquery s) = let c = conversion s
                     in do (b,names,fields,table)  <- runQuery' c
                           if b || length names /= 1 then errorProd2
                           else let ([n],[t]) = (names,table) in return (n,fields,t)


prod' (Join j arg1 arg2 exp) = do let ts = [arg1,arg2]
                                  (_,ns,fs,[t]) <- runQuery' [(1,Prod ts)]
                                  if length ns /= 2 then retFail "Error en join"
                                  else do tabTypes <- askTypes
                                          tabNames <- giveMeTableNames
                                          let tabNames' = ns ++ [x | x<-tabNames, not $ x `elem` ns]
                                          fromEither $ checkTypeBoolExp exp tabNames' tabTypes
                                          let eval = \reg -> do fromRegisterToContext ns reg
                                                                evalBoolExp tabNames' exp
                                          let [n1,n2] = ns
                                          let nn = n1++"Join"++n2
                                          case j of
                                           Inner -> do  t' <- ioEitherFilterT eval t
                                                        collapseContext nn ns fs
                                                        return (nn,fs,t')
                                           JLeft -> do (n2,fs2,_) <- prod' arg2

                                                       let fs2' = map (\f -> if f `elem` fs then f
                                                                             else f//n2) fs2
                                                       t' <- ioEitherMapT (mapFun eval fs2') t
                                                       collapseContext nn ns fs
                                                       return (nn,fs,t')
                                           JRight -> do (n1,fs1,_) <- prod' arg1
                                                        let fs1' = map (\f -> if f `elem` fs then f
                                                                              else f//n2) fs1
                                                        t' <- ioEitherMapT (mapFun eval fs1') t
                                                        collapseContext nn ns fs
                                                        return (nn,fs,t')

         where mapFun eval fs reg  = do b <- eval reg
                                        if b then return reg
                                        else return $ mapReg fs reg
               mapReg fs reg = mapWithKey (\k v -> if k `elem` fs then Nulo
                                                   else v) reg



-- Segundo caso : Tabla con renombre
prod' (As arg (Field n)) = do (n2,scheme,t) <- prod' arg
                              tabVals <- askVals
                              updateKeyContext n2 n
                              tabVals <- askVals
                              return (n,scheme,t)

-- Tercer caso : Tabla comun
prod' (Field n) = do e <- askEnv
                     let (path,user) = (url  e) ||| name e in
                      do [TS scheme, TT types] <- loadInfoTable ["scheme","types"] e n-- Obtener esquema y tipos
                         t <- obtainTable path n
                         let tabTypes = singleton n $ fromList $ zip scheme types
                         let tabVals = singleton n $ fromList $ map (\f -> (f,Nulo)) scheme
                         updateContext e tabVals tabTypes
                         return (n,scheme,t)


cartesianProd :: [(TableName,Tab)] -> Query (FieldNames,Tab)
cartesianProd [] = return ([],emptyT)
cartesianProd ((n,t):xs) = do   (fs,t2) <- cartesianProd xs
                                fields <- fieldsOfTable n
                                let fs' = fields ++ fs
                                return (fs',cartesianProd' fs' t t2)

-- Producto cartesiano (segundo nivel)
cartesianProd' :: FieldNames -> Tab -> Tab -> Tab
cartesianProd' _ E _ = E
cartesianProd' _ t E = t
cartesianProd' fields t1 t2 = let (tl,tr) = cartesianProd' fields (left t1) t2 ||| cartesianProd' fields (right t1) t2
                                  t = mergeT (comp fields) tl tr
                              in mergeT (comp fields) t (cartesianProd'' (value t1) t2)
  where cartesianProd'' x t = mapT (union x) t


-- Remplaza funciones de agregado por los valores correspondientes en una expresión boleana (primer nivel)
replaceAgg ::TableNames -> BoolExp -> AVL (HashMap String Args) -> Query BoolExp
replaceAgg  ts (And e1 e2) t = replaceAgg'  ts e1 e2 t And
replaceAgg  ts (Or e1 e2) t = replaceAgg'  ts  e1 e2 t Or
replaceAgg  ts (Less e1 e2) t = replaceAgg''  ts e1 e2 t Less
replaceAgg  ts (Great e1 e2) t = replaceAgg''  ts e1 e2 t Great
replaceAgg  ts (Equal e1 e2) t = replaceAgg''  ts e1 e2 t Equal
replaceAgg _ exp _ = retOk exp


-- replace (sedundo nivel)
replaceAgg'  ts e1 e2 t f  =  do e1'<- replaceAgg  ts e1 t
                                 e2' <- replaceAgg  ts e2 t
                                 return $ f e1' e2'


-- replace (tercer nivel)
replaceAgg''  ts e1 e2 t f  = do e1' <- evalAgg  ts e1 t
                                 e2' <- evalAgg  ts e2 t
                                 return $  f e1' e2'




-- Evaluar solo funciones de agregado
evalAgg :: TableNames -> Args -> Tab -> Query Args
evalAgg  ns (A2 f) t = do v <-  evalAgg'  ns f t
                          return $  A4 v
evalAgg  ns (Plus exp1 exp2) t = applyAggregate  ns exp1 exp2 Plus t
evalAgg  ns (Times exp1 exp2) t = applyAggregate  ns exp1 exp2 Times t
evalAgg  ns (Div exp1 exp2) t = applyAggregate  ns exp1 exp2 Div t
evalAgg  ns (Minus exp1 exp2) t = applyAggregate  ns exp1 exp2 Minus t
evalAgg  ns (Negate exp) t = applyAggregate'  ns exp Negate t
evalAgg  ns (Brack exp) t = applyAggregate'  ns exp Brack t
evalAgg  _ e _ = retOk e

applyAggregate ns exp1 exp2 op t= do n1 <- evalAgg  ns exp1 t
                                     n2 <-  evalAgg  ns exp2 t
                                     return $  op n1 n2
applyAggregate' ns exp op t = do n <- evalAgg  ns exp t
                                 return $ op n


evalAgg':: FieldNames -> Aggregate -> Tab -> Query Float
-- Evaluar funciones de agregado (segundo nivel)
evalAgg' ns  (Count d arg) t = evalAgg'' arg d t (return 0) $ makeFun arg ns   $ \ v1 v2 _  -> 1 + v1 + v2

evalAgg' ns  (Min d arg) t = evalAgg'' arg d t (return posInf) $ makeFun arg ns   (\ v1 v2 v3  -> min3 v1 v2 (toFloat v3))

evalAgg' ns  (Max d arg) t = evalAgg'' arg d t (return negInf) $ makeFun arg ns   (\ v1 v2 v3  -> max3 v1 v2 (toFloat v3))

evalAgg' ns (Sum d arg) t = evalAgg'' arg d t (return 0) $ makeFun arg ns  (\ v1 v2 v3  -> v1 + v2 + (toFloat v3))

evalAgg' ns (Avg d arg) t =  do  n1 <- evalAgg' ns   (Sum d arg) t
                                 n2 <- evalAgg' ns  (Count d arg) t
                                 return $ n1/n2


-- Evaluar funciones de agregado (segundo nivel)
evalAgg'' (Field s) d t e f  =  evalAgg''' d s t e f

evalAgg'' (Dot n s) d t e f  = evalAgg''' d (n//s) t e f


-- Evaluar funciones de agregado (tercer nivel)
evalAgg''' d s t e f = if d then let t' = mergeT (comp [s]) E t
                                 in foldT f e t'
                       else foldT f e t




-- Construye una función para mapear el árbol
makeFun:: Args -> FieldNames -> (Float -> Float -> Args -> Float) -> (Reg -> Query Float -> Query Float -> Query Float)
makeFun arg  names f  = \ reg y z -> do fromRegisterToContext names reg
                                        vals <- askVals
                                        v1 <- y
                                        v2  <- z
                                        let (ts,field) = case arg of
                                                          (Field v) -> (names,v)
                                                          (Dot t v) -> ([t],v)
                                        v3 <- fromEither $ lookupList vals ts field
                                        return $ f v1 v2 v3


posInf :: Float
posInf = 1/0

negInf :: Float
negInf = - 1/0



-- Construye una lista de tablas que agrupan registros con el
-- mismo valor para los atributos xs
group :: TableNames ->FieldNames -> Tab -> Query [Tab]
group _ _ E = return []
group ts  xs t = do  let reg = value t
                     fromRegisterToContext ts reg
                     tabVals <- askVals
                     vs <- fromEither $ sequence $ map (\x -> lookupList' tabVals ts x) xs
                     let reg' = fromList vs
                     let (names,_) = unzip vs
                     let (t1,t2) = particionT (equal names reg') t
                     res <- group ts xs t1
                     return $ t2 : res

      where equal xs v x = case comp xs v x of
                            Eq _ -> True
                            _ -> False







-- Evals


-- Evaluar args
evalIntExp :: TableNames -> Args -> Query Args
evalIntExp  s (Plus exp1 exp2) = evalIntExp'  False (+) s exp1 exp2
evalIntExp s (Minus exp1 exp2) = evalIntExp' False (-) s exp1 exp2
evalIntExp  s (Times exp1 exp2) = evalIntExp' False (*)  s exp1 exp2
evalIntExp  s (Div exp1 exp2) = evalIntExp' True (/)  s exp1 exp2

evalIntExp  s (Negate exp1) = do n <- evalIntExp  s exp1
                                 return $ (A4 $ negate (toFloat n))



evalIntExp  s (Field v) = do vals <- askVals
                             fromEither $ lookupList vals  s v


evalIntExp  s (Dot s2 v) = do vals <-  askVals
                              fromEither $ lookupList vals [s2] v

-- Constante
evalIntExp  _ arg = return arg

-- Evaluar expresión numérica
-- Incluye un booleano para saber si la operación es una división
evalIntExp' :: Bool -> (Float -> Float -> Float) ->TableNames -> Args -> Args -> Query Args
evalIntExp' b o s exp1 exp2 = if b then do n2 <- evalIntExp s exp2
                                           case n2 == A4 0 of
                                             True -> divisionError
                                             False -> do n1 <- evalIntExp s exp1
                                                         return $ A4(o (toFloat n1) (toFloat n2))
                                else do n1 <- evalIntExp s exp1
                                        n2 <- evalIntExp s exp2
                                        return  $ A4  (o (toFloat n1) (toFloat n2))

-- Evaluar expresión booleana
evalBoolExp :: TableNames -> BoolExp -> Query Bool
evalBoolExp s (Not exp) = do b <- evalBoolExp s exp
                             return $ not b

evalBoolExp s (And exp1 exp2)  = applyEval s exp1 exp2 (&&)

evalBoolExp s (Or exp1 exp2)   = applyEval s exp1 exp2 (||)

evalBoolExp s (Equal exp1 exp2) = evalBoolExp' (==) exp1 exp2 s

evalBoolExp s (Great exp1 exp2) = evalBoolExp' (>)  exp1 exp2 s

evalBoolExp s (Less  exp1 exp2) = evalBoolExp' (<)  exp1 exp2 s

evalBoolExp s (LEqual  exp1 exp2) = evalBoolExp' (<=)  exp1 exp2 s

evalBoolExp s (NEqual  exp1 exp2) = evalBoolExp' (/=)  exp1 exp2 s

evalBoolExp s (GEqual  exp1 exp2) = evalBoolExp' (>=)  exp1 exp2 s



-- Determina si la consulta dml es vacía
evalBoolExp _ (Exist dml) = do let c = conversion  dml
                               tabVals <- askVals
                               (_,ts,_,ls)<- runQuery' c
                               --deleteFromContext ts
                               if length ls /= 1 then errorExist
                                 else  let [t] = ls in
                                       return $ not $ isEmpty t




-- Determina si el valor referido por el campo v pertenece a l
evalBoolExp s (InVals arg l) = do vals <- askVals
                                  let (table,name) = case arg of
                                                       (Field v) -> (s,v)
                                                       (Dot t v) -> ([t],v)
                                  x <- fromEither $ lookupList vals table name
                                  return $ elem x l


-- Evalua si el valor de la variable field está en la columna que es resultado de dml
evalBoolExp s (InQuery arg dml) = do tabTypes <- askTypes
                                     (b,ts,fs,ls) <-runQuery' $ conversion dml
                                     tabTypes <- askTypes
                                     if length fs /= 1 || b || length ls /= 1 then error "Error" -- La busqueda debe ser sobre una columna
                                     else let [f2] = fs
                                              [t] = ls
                                          in do tabTypes <- askTypes
                                                let (table,name) = case arg of
                                                                        (Field v) -> (s,v)
                                                                        (Dot t v) -> ([t],v)
                                                t1 <- fromEither $ lookupList tabTypes table name -- Buscamos los tipos
                                                t2 <- fromEither $ lookupList tabTypes ts f2
                                                if t1 /= t2 then  error "Algo anda mal" -- Deben coincidir
                                                else do vals <- askVals
                                                        v <- evalIntExp s arg
                                                        let r = fromList $ [(f2,v)]
                                                        return $ isMember [f2] r t



evalBoolExp s (Like f p) = do tabTypes <- askTypes
                              tabVals <- askVals
                              t <- fromEither $ checkTypeExp s tabTypes f
                              if t == String then let (A1 v) = obtainValue s f tabVals in
                                                  return $ findPattern v p
                              else errorLike


  where findPattern [] [] = True
        findPattern (x:xs) ('_':ys) = findPattern xs ys -- '_' representa un solo caracter
        findPattern xs ['%'] = True -- '%' representa una cantidad indefinida de caracteres
        findPattern xs ('%':y:ys) = findPattern (dropWhile (\x -> x /= y) xs) (y:ys) -- consumir una cantidad indefinida de caracteres hasta encontrar el siguiente
        findPattern (x:xs) (y:ys) = if x == y then findPattern xs ys
                                    else False
        findPattern _ _ = False


evalBoolExp _ exp = error $ show exp

applyEval:: TableNames -> BoolExp -> BoolExp -> (Bool -> Bool -> Bool) -> Query Bool
applyEval s exp1 exp2 op = do b1 <-  evalBoolExp s exp1
                              b2 <- evalBoolExp s exp2
                              return $ op b1 b2

-- Evaluar expresión booleana (2do nivel)
evalBoolExp' :: (Args -> Args -> Bool) -> Args -> Args -> TableNames  ->  Query Bool
evalBoolExp' o exp1 exp2 s   = do n1 <- evalIntExp s exp1
                                  n2 <- evalIntExp s exp2
                                  return $ o n1 n2

      where isFieldOrDot (Field _) = True
            isFieldOrDot (Dot _ _) = True
            isFieldOrDot _ = False
