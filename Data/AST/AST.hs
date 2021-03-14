module AST where
import Avl (AVL(..),mapT,pushL,join,value,left,right,emptyT)
import qualified Data.HashMap.Strict as HM  (HashMap (..),insert,delete,empty,update,fromList,(!),mapWithKey,keys,map,union,singleton,filterWithKey,member,lookup)
import qualified Data.Set as S
import Data.Hashable
import Data.Typeable (TypeRep)
import System.Console.Terminal.Size  (size,width)
import Data.List.Split
import qualified Data.List as DL (lookup,elemIndex,intersect,filter)
import Control.Applicative
import Data.Time
import Data.Fixed

-- Modulo con árboles de sintaxis abstractas y otras definiciones útiles


-- Representación de la hora y el día

data Dates = Day {dayD::Int,monthD::Int,yearD::Int} deriving (Eq,Show)

instance Ord Dates where
  (<) d1 d2 = compareDate d1 d2 (<)
  (<=) d1 d2 = compareDate d1 d2 (<=)
  (>) d1 d2 = compareDate d1 d2 (>)
  (>=) d1 d2 = compareDate d1 d2 (>=)
  max d1 d2 = if compareDate d1 d2 (>) then d1
              else d2
  min d1 d2 = if compareDate d1 d2 (<) then d1
              else d2

compareDate d1 d2 op = op (fromGregorian (fromIntegral $ yearD d1) (monthD d1) (dayD d1))  (fromGregorian (fromIntegral $ yearD d2) (monthD d2) (dayD d2))



data Times = T {tHour::Int,tMinute::Int,tSecond::Int} deriving (Eq,Show)

instance Ord Times where
  (<) t1 t2 = compareTime t1 t2 (<)
  (<=) t1 t2 = compareTime t1 t2 (<=)
  (>) t1 t2 = compareTime t1 t2 (>)
  (>=) t1 t2 = compareTime t1 t2 (>=)
  max t1 t2 = if compareTime t1 t2 (>) then t1
              else t2
  min t1 t2 = if compareTime t1 t2 (<) then t1
              else t2



compareTime t1 t2 op = op (TimeOfDay (tHour t1) (tMinute t1) (fromIntegral $ tSecond t1))  (TimeOfDay (tHour t2) (tMinute t2) (fromIntegral $ tSecond t2))

data DateTime = DateTime {year::Int,month::Int,day::Int,hour::Int,minute::Int,second::Int} deriving (Eq,Show)


instance Ord DateTime where
  (<) dt1 dt2 = compareDateTime dt1 dt2 (<)
  (<=) dt1 dt2 = compareDateTime dt1 dt2 (<=)
  (>) dt1 dt2 = compareDateTime dt1 dt2 (>)
  (>=) dt1 dt2 = compareDateTime dt1 dt2 (>=)
  max dt1 dt2 = if compareDateTime dt1 dt2 (>) then dt1
              else dt2
  min dt1 dt2 = if compareDateTime dt1 dt2 (<) then dt1
              else dt2


compareDateTime dt1 dt2 op = op (LocalTime (fromGregorian (fromIntegral $ year dt1) (month dt1) (day dt1)) (TimeOfDay (hour dt1) (minute dt1) (fromIntegral $ second dt1)))
                                (LocalTime (fromGregorian (fromIntegral $ year dt2) (month dt2) (day dt2)) (TimeOfDay (hour dt2) (minute dt2) (fromIntegral $ second dt2)))



newtype Query a = Q {runState::Context -> IO(Either ErrorMsg (Context,a))}



instance Functor (Query) where
     fmap f (Q x) =  Q (\c -> do x' <- x c
                                 return $ case x'  of
                                            Right (c',x'') -> Right (c',f x'')
                                            Left m -> Left m)


instance Applicative Query where
     pure = return
     g  <*> x = do func <- g
                   val <- x
                   return $ func val

instance Monad Query where
   return a = Q (\c -> return $ Right (c,a))
   (Q a) >>= f = Q (\c ->  a c >>= \r ->
                           case r of
                              Right (c',x) -> runState (f x) c'
                              Left m -> return $ Left m)




-- Actualizar contexto
updateContext :: Env -> ContextFun Args -> ContextFun Type-> Query ()
updateContext e t tp = do updateEnv e
                          updateVals t
                          updateTypes tp

-- Actualiza el entorno en el contexto g
updateEnv ::  Env -> Query ()
updateEnv e = Q(\c -> (return $ Right  ((e,snd' c,trd' c),())))


-- Actualiza los valores de las variables de tupla en el contexto
updateVals :: ContextFun Args -> Query ()
updateVals x =  Q(\c -> return $ Right ((fst' c,HM.union x (snd' c),trd' c),()))

-- Actualiza los tipos de las variables de tupla en el contexto
updateTypes :: ContextFun Type -> Query ()
updateTypes y =  Q(\c -> return $ Right ((fst' c,snd' c,HM.union y (trd' c)),()))

updateKeyContext :: TableName -> TableName -> Query ()
updateKeyContext oldKey newKey = Q(\c -> let newVals = updateKey oldKey newKey $ snd' c
                                             newTypes = updateKey oldKey newKey $ trd' c
                                         in return $ Right ((fst' c,newVals,newTypes),()))
-- Renombrar en el contexto atributos con AS
updateFieldsInContext :: TableName -> [Args] -> Query FieldName
updateFieldsInContext _  [] = return ""

updateFieldsInContext n  (All : xs) = updateFieldsInContext n xs

updateFieldsInContext n  ((As arg (Field v)) : xs) = do  k <- updateFieldsInContext n [arg]
                                                         updateFieldsInContext' n k v
                                                         updateFieldsInContext n xs
                                                         return v



updateFieldsInContext  n  ((Field v):xs) = do updateFieldsInContext n xs
                                              return v

updateFieldsInContext n  ((Dot t v):xs) =   do updateFieldsInContext n xs
                                               return $ t//v

-- Agregar campo con función de agregado
updateFieldsInContext n (arg:xs) = let field =  n //  show2 arg in
                                       do  Q(\c -> do let tabVals = snd' c
                                                      let tabTypes = trd' c
                                                      let newVals = HM.singleton field  Nulo `HM.union` ( tabVals !!!  n)
                                                      let newTypes = HM.singleton field Float `HM.union` (tabTypes !!! n)
                                                      let tabVals' =  HM.singleton n newVals  `HM.union` tabVals
                                                      let tabTypes' = HM.singleton n newTypes `HM.union` tabTypes
                                                      let c' = (fst' c,tabVals', tabTypes')
                                                      return $ Right (c',field))
                                           updateFieldsInContext n xs
                                           return field



updateFieldsInContext n (arg : xs) = updateFieldsInContext n xs









updateFieldsInContext' :: TableName -> FieldName -> FieldName -> Query ()
updateFieldsInContext' n v1 v2 = Q(\c -> let vals = updateKey v1 v2 $ snd' c !!! n
                                             types = updateKey v1 v2 $ trd' c !!! n
                                             tabVals =  HM.singleton n vals `HM.union` snd' c
                                             tabTypes = HM.singleton n types `HM.union` trd' c
                                         in return $ Right ((fst' c, tabVals,tabTypes),()))


-- Actualiza el valor de la llave en m
updateKey  :: FieldName -> FieldName -> HM.HashMap FieldName v -> HM.HashMap FieldName v
updateKey oldKey newKey m = deleteHM oldKey $ insertHM newKey (m !!! oldKey) m


-- Unificar los valores del contexto de las tablas ts
collapseContext :: TableName -> TableNames -> FieldNames -> Query ()
collapseContext t ts fs = do  tabTypes <- askTypes
                              types <- fromEither $ recoverFromContext ts fs tabTypes
                              let newTypes = HM.singleton t types
                              let newVals = HM.singleton t $ HM.fromList $ map (\f -> (f,Nulo)) fs
                              Q(\c -> let c' = (fst' c,newVals `HM.union` (snd' c),newTypes `HM.union` (trd' c))
                                      in return $ Right (c',()))
                              if ts == [t] then return ()
                              else deleteFromContext ts




recoverFromContext :: TableNames -> FieldNames -> ContextFun a -> Either ErrorMsg (HM.HashMap String a)
recoverFromContext _ [] _  = return $ HM.empty
recoverFromContext ts (f:fs) c = do x <- lookupList c ts f
                                    xs <- recoverFromContext ts fs c
                                    return $ HM.singleton f x `HM.union` xs

 where funFilter t fs k _ = if k  `elem`  fs || k `elem` map (\f -> t//f) fs then True
                            else False




-- Pasar datos del registro al contexto
fromRegisterToContext :: TableNames -> Reg -> Query ()
fromRegisterToContext ts reg = Q(\c -> let tabVals = snd' c
                                           tabVals' = HM.mapWithKey (mapFun  ts reg) tabVals
                                           c' = (fst' c,tabVals', trd' c)
                                       in return $ Right (c',()))
   where mapFun ts reg t vals = if t `elem` ts then  HM.mapWithKey (mapFun' reg) vals
                                else vals
         mapFun' reg k v  = if k `HM.member` reg then reg !!! k
                            else v




deleteFromContext :: TableNames  -> Query ()
deleteFromContext ts  = Q(\c ->  let newVals = deleteFromContext' ts $ snd' c
                                     newTypes = deleteFromContext' ts $ trd' c
                                     c' = (fst' c,newVals,newTypes)

                                 in return $ Right (c',()))

deleteFromContext' :: TableNames -> ContextFun a -> ContextFun a
deleteFromContext' ts cf = HM.filterWithKey (funFilter ts) cf
 where funFilter ts k _ = if k `elem` ts then False
                          else True


fieldsOfTable :: TableName -> Query FieldNames
fieldsOfTable n = Q(\c -> let keys = HM.keys $  (snd' c) HM.! n
                          in return $ Right (c,keys))




askContext :: Query Context
askContext = Q(\c -> return $ Right(c,c))

askEnv :: Query Env
askEnv = Q(\c -> return $ Right (c,fst' c))

askVals :: Query (ContextFun Args)
askVals = Q(\c -> return $ Right (c,snd' c))

askTypes :: Query (ContextFun Type)
askTypes = Q(\c -> return $ Right (c,trd' c))


fromEither :: Either ErrorMsg b -> Query b
fromEither (Left msgError) = Q(\c -> return $ Left msgError)
fromEither (Right b) = return b


fromIO :: IO a -> Query a
fromIO io = Q(\c -> do a <- io
                       return $ Right (c,a))


unWrapperQuery :: Env -> Query a -> IO(Either ErrorMsg a)
unWrapperQuery e q = do  let c = (e,emptyHM,emptyHM)
                         res <- (runState q ) c
                         return $ fmap (\(_,x)-> x) res




ioEitherFilterT ::Show e => (e -> Query Bool) -> AVL e -> Query(AVL e)
ioEitherFilterT _ E = return E
ioEitherFilterT f t = do b <- f (value t)
                         l <- ioEitherFilterT f (left t)
                         r <- ioEitherFilterT f (right t)
                         return $ let t' = join l r in
                                  if b then pushL (value t) t'
                                  else t'


-- Mapea un árbol
ioEitherMapT :: (e -> Query b) -> AVL e -> Query (AVL b)
ioEitherMapT f E = return E
ioEitherMapT f t = do l' <- ioEitherMapT f (left t)
                      r' <- ioEitherMapT f (right t)
                      v <- f $ value t
                      return $ case t of
                               (N _ _ _) -> N l' v r'
                               (Z _ _ _) -> Z l' v r'
                               (P _ _ _) -> P l' v r'


-- Partir un árbol en 2  con transformaciones
particionT2 :: (a -> Either c ()) -> (a -> b) -> AVL a -> (AVL c,AVL b)
particionT2 p f E = (E,E)
particionT2 p f t =  let  (l1,l2) = particionT2 p f (left t)
                          (r1,r2) = particionT2 p f (right t)
                          l = join l1 r1
                          r = join l2 r2
                          x = value t
                      in  case p x of
                            Left errorMsg  -> (pushL errorMsg l,r)
                            _  -> ( l, pushL (f x) r)



(////) :: Monad m => m a -> m b -> m (a,b)
a //// b = do a' <- a
              b' <- b
              return (a',b')

-- Definimos el entorno como el usuario actual, la BD que se está usando y la fuente usada
data Env = Env {name :: String, dataBase :: String, source :: String} deriving Show
-- Tipos de una tabla
type Types = HM.HashMap FieldName Type
-- Tipos de varias tablas


-- Representamos los registros de una tabla
type Reg = HM.HashMap String Args
-- Registros de varias tablas



type Key = [String]
-- Errores
type ErrorMsg = String
-- Definimos el contexto de una consulta
-- Esto nos permite llevar el estado de una consulta
-- pues en cualquier momento podemos chequear el tipo de una expresión
-- o el valor de una variable de tupla
-- El contexto contiene 3 componentes :
--  Env (Entorno) : Usuario, base de datos, fuente de datos
-- TabReg : TableName -> FieldName -> Args
-- TabTypes : TableName -> FieldName -> Type
type ContextFun a = HM.HashMap TableName (HM.HashMap FieldName a)
type Context = (Env,ContextFun Args,ContextFun Type)

-- Sinonimos
type TableName = String
type TableNames = [TableName]
type FieldNames = [String]
type Table = String
type FieldName = String
type Symbol = String
type Cola a = [(Int,a)]
type Distinct = Bool
type UserName = String

-- Definimos una answer como una respuesta a una consulta
-- Consta de 4 componentes:
-- Un booleano para diferenciar si la consulta incluye una claúsula group by (requiere un tratamiento especial)
-- Una lista de nombres de tablas
-- Una lista de atributos actuales
-- Una lista de tablas
type Answer =  (Bool,TableNames,FieldNames,[Tab])
-- Con un tabReg almacenamos el valor de los registros de las tablas
-- cuando los almacenamos dentro de un contexto

-- Representamos una Tala
type Tab = AVL (Reg)
-- Representamos tablas con metadatos
type TabsInfo = AVL (HM.HashMap FieldName TableInfo)
type TabsUserInfo = AVL (HM.HashMap FieldName UserInfo)

-- Descripción de la tabla (columnas,tipos,keys,foreing keys)
type TableDescript = ([String],[Type],[String],[String],ForeignKey)



-- Tipo de dato para representar la información de la tabla
-- TB : base
-- TO : propietario
-- TN : nombre
-- TS : esquema
-- TT : Tipo de cada columna
-- TK : clave primaria
-- Env : Tabla referenciada, clave foránea
-- TR : Tabla por la que es referenciada, opción de delete, opción de update
-- HN : Lista de campos que admiten valores nulos
data TableInfo = TO String | TN String | TS [String] | TT [Type]|  TK [String]
                   | TFK [(String,[(String,String)])] | TR [Reference] | HN [String]
                   | TB String deriving (Show,Eq,Ord)


-- Clave foránea
type ForeignKey = [(String,[(String,String)],RefOption,RefOption)]
type Reference = (String,RefOption,RefOption)

-- Tipos de datos
data Type = String | Int | Float | Bool | Datetime | Date | Time | TNulo  deriving (Show,Eq,Ord)


-- Resultado del parseo
data ParseResult a = Ok a | Failed String deriving Show
type Info = (Int,Int)
-- Monada para el parseo
type P a = String -> Info -> ParseResult a




-- AST de SQL
data SQL = Seq SQL SQL
         | S1 DML
         | S2 DDL
         | S3 ManUsers
         | Source FilePath
        deriving Show


--Aministración de usuarios
data ManUsers = CUser String String
              | SUser String String
              | DUser String String
              deriving Show


-- Metadatos de usuarios
data UserInfo = UN String -- Nombre de usuario
              | UP String -- Pass
              | UB [String] -- Bases de datos que pertenecen al usuario
              deriving (Show,Ord,Eq)

-- Operadores de álgebra relacional (Operan sobre las tablas)
-- Operadores (argumentos) :
-- Pi proyeccion (booleano para eliminar registros duplicados y lista de cosas a proyectar)
-- Prod producto cartesiano (lista de tablas)
-- Sigma selección (expresión booleana)
-- Dif diferencia entre tablas (consultas)
-- Uni union entre tablas (consultas)
-- Inters intersección entre tablas (consultas)
-- Hav selección entre grupos (expresión booleana)
-- Order ordenar (argumentos por los cuales se ordena)
-- Group agrupamiento (argumentos por los cuales agrupar)
-- Top limitar la cantidad de registros en los resultados (limite)
data AR =     Pi Distinct [Args]
            | Prod [Args]
            | Sigma BoolExp
            | Dif (Cola AR) (Cola AR)
            | Uni (Cola AR) (Cola AR)
            | Inters (Cola AR) (Cola AR)
            | Hav BoolExp
            | Order [Args] O
            | Group [Args]
            | Top Int
            deriving Show




-- Lenguaje DML (Describen la información solicitada sobre la BD)
data DML =     Select Distinct [Args] DML
              | From [Args] DML
              | Where BoolExp  DML
              | GroupBy [Args] DML
              | Having BoolExp  DML
              | OrderBy [Args] O DML
              | Insert String (AVL ([Args]))
              | Delete String BoolExp
              | Update String ([String],[Args])  BoolExp
              | Union DML DML
              | Intersect DML DML
              | Diff DML DML
              | Limit Int DML
              | End
              deriving (Show, Eq, Ord)



data JOINS = Inner | JLeft | JRight deriving (Show,Eq,Ord)


-- Expresiones
data Args = A1 String
          | A2 Aggregate
          | A3 Int
          | A4 Float
          | A5 DateTime  -- (fecha y hora )
          | A6 Dates  --(solo fecha)
          | A7 Times -- (solo hora)
          | All
          | Subquery DML
          | As Args Args
          | Nulo
          | Field String
          | Dot String String
          | Plus Args Args
          | Minus Args Args
          | Times Args Args
          | Div Args Args
          | Negate Args
          | Brack Args
          | Join JOINS Args Args BoolExp
          deriving (Eq,Show,Ord)







-- Funciones de agregado (Operan sobre columnas)
data Aggregate = Min Distinct Args
               | Max Distinct Args
               | Sum Distinct Args
               | Count Distinct Args
               | Avg Distinct Args
               deriving (Eq,Ord)


-- Expresiones booleanas
data BoolExp =  And BoolExp BoolExp
              | Or  BoolExp BoolExp
              | Equal Args Args
              | NEqual Args Args
              | Great Args Args
              | Less Args Args
              | GEqual Args Args
              | LEqual Args Args
              | Not BoolExp
              | Exist DML
              | InVals Args [Args]
              | InQuery Args DML
              | Like Args String
              deriving (Eq,Ord)







-- Orden (ascendente o descendente)
data O = A | D deriving (Show,Eq,Ord)






-- DDL Language (Diseñan la BD)

type BaseName = String
type HaveNull = Bool

data DDL =
             CBase BaseName
           | DBase BaseName
           | CTable Table [CArgs]
           | DTable FieldName
           | DAllTable
           | Use BaseName
           | ShowB
           | ShowT
           deriving (Show,Eq,Ord)


-- Argumentos para crear una tabla
data CArgs =  Col String Type HaveNull
            | PKey [FieldName]
            | FKey [FieldName] Table [FieldName] RefOption RefOption
            deriving (Show,Eq,Ord)

-- Opciones de referencia
data RefOption = Restricted | Cascades | Nullifies  deriving (Show,Eq,Ord)





show3 :: TableInfo -> String
show3 (TN n) = n


-- Algunas definiciones útiles




filterL = filter
insertHM :: (Eq k, Hashable k) => k -> v -> HM.HashMap k v -> HM.HashMap k v
insertHM = HM.insert
deleteHM :: (Eq k, Hashable k) => k -> HM.HashMap k v -> HM.HashMap k v
deleteHM = HM.delete
emptyHM :: HM.HashMap k v
emptyHM = HM.empty
updateHM:: (Eq k, Hashable k) => (a -> Maybe a) -> k -> HM.HashMap k a -> HM.HashMap k a
updateHM = HM.update
mapHM :: (v1 -> v2) -> HM.HashMap k v1 -> HM.HashMap k v2
mapHM = HM.map



show2 (A1 s) = s
show2 (A2 f) = show f
show2 (A3 n) = show n
show2 (A4 f) = show f
show2 (A5 dt) = (show2 $ A6 $ Day (year dt)  (month dt) (day dt) ) ++ " " ++ (show2 $ A7 $ T (hour dt) (minute dt) (second dt))
show2 (A6 d) = (sh $ yearD d) ++ "-" ++ (sh $ monthD d) ++ "-" ++ (sh $ dayD d)
     where sh = show
show2 (A7 t) = (sh $ tHour t) ++ ":" ++ (sh $ tMinute t) ++ ":" ++ (sh $ tSecond t)
    where sh 0 = "00"
          sh t = show t
show2 (Field e) = e
show2 (As _ s) = show2 s
show2 (Dot s1 s2) = s1 //s2
show2 (Plus exp1 exp2) = (show2 exp1) ++ "+" ++ (show2 exp2)
show2 (Minus exp1 exp2) = (show2 exp1) ++ "-" ++ (show2 exp2)
show2 (Times exp1 exp2) = (show2 exp1) ++ "*" ++ (show2 exp2)
show2 (Div exp1 exp2) = (show2 exp1) ++ "/" ++ (show2 exp2)
show2 (Negate exp1) = "-" ++ (show2 exp1)
show2 (Brack exp1) = "(" ++ (show2 exp1) ++ ")"
show2 (All) = "All"
show2 (Nulo) = "Null"


instance Show Aggregate where
  show (Min _ s) = "Min("++ (show2 s) ++ ")"
  show (Max _ s) = "Max(" ++ (show2 s) ++ ")"
  show (Sum _ s) = "Sum(" ++ (show2 s) ++")"
  show (Count _ s) = "Count(" ++ (show2 s) ++")"
  show (Avg _ s) = "Avg(" ++ (show2 s) ++")"


instance Show BoolExp where
  show (Not e) = "NOT (" ++ (show e) ++ ")"
  show (And e1 e2) = (show e1) ++ " AND " ++ (show e2)
  show (Or e1 e2) = (show e1) ++ " OR " ++ (show e2)
  show (Equal e1 e2) = (show2 e1) ++ " = " ++ (show2 e2)
  show (Less e1 e2) = (show2 e1) ++ " < " ++ (show2 e2)
  show (Great e1 e2) = (show2 e1) ++ " > " ++ (show2 e2)
  show (GEqual e1 e2) = (show2 e1) ++ " >= " ++ (show2 e2)
  show (LEqual e1 e2) = (show2 e1) ++ " <= " ++ (show2 e2)
  show (Exist dml) =      "EXISTS (" ++ show dml ++ ")"
  show (NEqual exp1 exp2) =      show exp1 ++ " <> " ++ show exp2
  show (InVals f dml) = (show f) ++ " IN " ++ (show dml)
  show (InQuery f ls) = (show f) ++ " IN " ++ (show ls)



fst' :: (a,b,c) -> a
fst' (x,_,_) = x


snd' :: (a,b,c) -> b
snd' (_,y,_) = y

trd' :: (a,b,c) -> c
trd' (x,y,z) = z


isInt :: RealFrac b => b -> Bool
isInt x = x - fromInteger(round x) == 0

fields0 = ["owner", "dataBase"]
fields =   fields0 ++ ["tableName"]
fields2 = fields ++ ["scheme","types","key","fkey","refBy","haveNull"]
fields3 = fields ++ ["referencedBy"]

belong :: Eq a => [a] -> a -> Bool
belong [] _ = False
belong (x:xs) y = if x == y then True
                  else belong xs y

createInfoRegister :: Env -> HM.HashMap String TableInfo
createInfoRegister e =  HM.fromList $ zip fields0 [TO (name e), TB (dataBase e)]


createInfoRegister2 :: Env -> String -> HM.HashMap String TableInfo
createInfoRegister2 e n =  (createInfoRegister e) `HM.union` (HM.singleton "tableName" (TN n))




printTable :: Show b =>  (b -> String) -> FieldNames -> AVL (HM.HashMap String b) -> IO ()
printTable print s t =
  do r <- size
     case r of
       Nothing -> error ""
       Just w -> do putStrLn $ line $ width w
                    putStrLn  $ fold s
                    putStrLn $ line $ width w
                    sequence_ $ mapT (\ x -> putStrLn $ fold $ map (f' x) s) t
 where fold s = txt 0 s 30
       f x y = x ++ "|" ++ y
       f' reg y =  print $ case  y `HM.lookup` reg of
                            Just v -> v
                            Nothing -> error $ "Error fatal buscando " ++  y
       txt _ [] _ = ""
       txt 0 (x:xs) n  = "|" ++ x ++  txt (n - length x) xs n
       txt c v n = " " ++ txt (c-1) v n
       line 0 = ""
       line n = '-': (line (n-1))


isAgg (A2 _) = True
isAgg (As e1 _) = isAgg e1
isAgg _ = False

min3 :: Float -> Float -> Float -> Float
min3 v1 v2 v3 =  min v3 (min v1 v2)

max3 :: Float -> Float -> Float -> Float
max3 v1 v2 v3 = max v3 (max v1 v2)

toFloat :: Args -> Float
toFloat (A3 n) = fromIntegral n
toFloat (A4 n) = n
toFloat arg = error $ show arg


retHeadOrNull :: [AVL a] -> AVL a
retHeadOrNull [] = emptyT
retHeadOrNull tables = head tables


-- Obtener los campos en el contexto actual
giveMeOnlyFields :: Query(HM.HashMap TableName FieldNames)
giveMeOnlyFields = Q(\c -> return $ Right (c,HM.mapWithKey (\k -> \v -> HM.keys v) $ trd' c))

-- Obtener las tablas en el contexto actual
giveMeTableNames :: Query TableNames
giveMeTableNames = Q(\c -> return $ Right (c,HM.keys $ trd' c))

-- Unir los contextos de 2 tablas  en una sola
-- joinContext:: TableName -> TableName -> TableName -> Query ()
-- joinContext nk k1 k2 = Q(\c -> return $ Right ((fst' c,joinContext' nk k1 k2 $ snd' c,joinContext' nk k1 k2 $ trd' c),()))
--
-- joinContext' :: TableName -> TableName -> TableName -> HM.HashMap TableName (HM.HashMap FieldName a) -> HM.HashMap TableName (HM.HashMap FieldName a)
-- joinContext' nk k1 k2 vals = let newV = (vals HM.! k1) `HM.union` (vals HM.! k2)
--                                  vals' = HM.delete k1  $ HM.delete k2 vals
--                              in vals' `HM.union` HM.singleton nk newV

-- Realiza una busqueda  para encontrar el valor de un atributo a partir de una lista de tablas y
lookupList ::ContextFun b -> TableNames -> FieldName -> Either ErrorMsg b
lookupList _ [] v = errorFind v
lookupList g q@(y:ys) v = case HM.lookup y g of
                          Nothing -> errorFind2 y
                          Just r -> case HM.lookup v r of  -- Buscar primero solo el atributo
                                       Just x' -> return x'
                                       Nothing ->  case HM.lookup (y//v) r of -- sino buscar tabla.atributo
                                                      Nothing -> lookupList g ys v
                                                      Just x' -> return x'



-- Lo mismo que lookupList para devuelve la clave con la que encuentra el atributo
lookupList' ::Show b => ContextFun b -> TableNames -> FieldName -> Either ErrorMsg (FieldName,b)
lookupList' _ [] v = errorFind v
lookupList' g q@(y:ys) v = case HM.lookup y g of
                           Nothing -> errorFind2 y
                           Just r -> case HM.lookup v r of
                                      Just x' -> return (v,x')
                                      Nothing ->  let field = y//v in
                                                    case HM.lookup field r of
                                                      Just x -> return (field,x)
                                                      Nothing -> lookupList' g ys v


-- Devuelve que tablas tienen alguno de los atributos fs
filterTables ::Show b => ContextFun b -> TableNames -> FieldNames -> Either ErrorMsg TableNames
filterTables _ [] _ = return []
filterTables g (y:ys) fs = case HM.lookup y g of
                             Nothing -> errorFind2 y
                             Just r -> do xs <- filterTables g ys fs
                                          let keys = HM.keys r
                                          return $ case DL.intersect keys fs of
                                                     [] -> xs
                                                     _ -> y:xs

emptyContext :: Query ()
emptyContext = Q(\c -> let c'= (fst' c, emptyHM,emptyHM)
                       in return $ Right (c',()))


errorFind s = Left $ "No se pudo encontrar el atributo " ++ s
errorFind2 s = Left $ "La tabla " ++ s  ++ " es desconocida "



(//):: TableName -> FieldName -> FieldName
(//) t f = t ++ "." ++ f

(!!!) :: HM.HashMap String a -> String -> a
(!!!) tab k = case  k `HM.lookup` tab of
                Just v -> v
                Nothing -> error $ "Error fatal buscando " ++ k

dlLookup :: Int -> [(Int,a)] -> a
dlLookup i ls = case DL.lookup i ls of
                 Just x -> x
                 Nothing -> error "Error fatal"
dlElemIndex ::Eq a => a -> [a] -> Int
dlElemIndex x ls = case DL.elemIndex x ls of
                     Just i -> i
                     Nothing -> error "Error fatal"

dlFilter = DL.filter
