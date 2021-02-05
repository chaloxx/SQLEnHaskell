module AST where
import Avl (AVL(..),mapT,pushL,join,value,left,right,emptyT)
import qualified Data.HashMap.Strict as HM  (HashMap (..),insert,delete,empty,update,fromList,(!),mapWithKey,keys,map,union,singleton)
import qualified Data.Set as S
import Data.Hashable
import Data.Typeable (TypeRep)
import System.Console.Terminal.Size  (size,width)
import Data.List.Split
import Control.Applicative


-- Modulo con árboles de sintaxis abstractas y otras definiciones útiles

data Date = Date {dayD::Int,monthD::Int,yearD::Int} deriving (Ord,Eq,Show)
data Time = Time {tHour::Int,tMinute::Int,tSecond::Int} deriving (Ord,Eq,Show)
data DateTime = DateTime {year::Int,month::Int,day::Int,hour::Int,minute::Int,second::Int} deriving (Ord,Eq,Show)

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
updateContext :: Env -> TabReg -> TabTypes -> Query ()
updateContext e t tp = do updateEnv e
                          updateVals t
                          updateTypes tp

-- Actualiza el entorno en el contexto g
updateEnv ::  Env -> Query ()
updateEnv e = Q(\c -> (return $ Right  ((e,snd' c,trd' c),())))


-- Actualiza los valores de las variables de tupla en el contexto
updateVals :: TabReg -> Query ()
updateVals x =  Q(\c -> return $ Right ((fst' c,HM.union x (snd' c),trd' c),()))

-- Actualiza los tipos de las variables de tupla en el contexto
updateTypes :: TabTypes -> Query ()
updateTypes y =  Q(\c -> return $ Right ((fst' c,snd' c,HM.union y (trd' c)),()))


askContext :: Query Context
askContext = Q(\c -> return $ Right(c,c))

askEnv :: Query Env
askEnv = Q(\c -> return $ Right (c,fst' c))

askVals :: Query TabReg
askVals = Q(\c -> return $ Right (c,snd' c))

askTypes :: Query TabTypes
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





-- Patrones de cómputo (ahorran código)
(||||):: (Monad m, Monad n) => m (n a) -> m (n b) -> m (n (a,b))
a |||| b = do (a', b') <- a //// b
              return $ do (a'',b'') <- a' //// b'
                          return (a'',b'')

(////) :: Monad m => m a -> m b -> m (a,b)
a //// b = do a' <- a
              b' <- b
              return (a',b')


pattern :: (Monad m, Functor n) => m (n a) -> (a -> b) -> m (n b)
pattern r f = do r' <- r
                 return $ fmap f r'

pattern2 :: IO (Either String a) -> (a -> IO (Either String b)) -> IO (Either String b)
pattern2 res f = do res' <- res
                    case res' of
                      Right v -> f v
                      Left msg -> return (Left msg)



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




-- Definimos el entorno como el usuario actual, la BD que se está usando y la fuente usada
data Env = Env {name :: String, dataBase :: String, source :: String} deriving Show
-- Tipos de una tabla
type Types = HM.HashMap FieldName Type
-- Tipos de varias tablas
type TabTypes = HM.HashMap TableName Types

-- Representamos los registros de una tabla
type Reg = HM.HashMap String Args
-- Registros de varias tablas
type TabReg = HM.HashMap String Reg



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
type Context = (Env,TabReg,TabTypes)

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
data Type = String | Int | Float | Bool | Datetime | Dates | Tim deriving (Show,Eq,Ord)


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
            | Joinner JOINS [Args] BoolExp
            deriving Show




-- Lenguaje DML (Describen la información solicitada sobre la BD)
data DML =     Select Distinct [Args] DML
              | From [Args] DML
              | Join JOINS [Args] BoolExp DML
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


-- Argumentos de claúsulas (constantes y operaciones)
data Args = A1 String
          | A2 Aggregate
          | A3 Int
          | A4 Float
          | A5 DateTime  -- (fecha y hora )
          | A6 Date  --(solo fecha)
          | A7 Time -- (solo hora)
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
          deriving (Eq,Ord,Show)




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


--instance (Ord a, Ord v) => Ord (HM.HashMap a v) where
--   t1 <= t2 = t1 == t2 || t1 < t2



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
show2 (A5 dt) = (show2 $ A6 $ Date (day dt) (month dt) (year dt)) ++ " " ++ (show2 $ A7 $ Time (hour dt) (minute dt) (second dt))
show2 (A6 d) = (sh $ yearD d) ++ "-" ++ (sh $ monthD d) ++ "-" ++ (sh $ dayD d)
    where sh = show
show2 (A7 t) = (sh $ tHour t) ++ ":" ++ (sh $ tMinute t) ++ ":" ++ (sh $ tSecond t)
   where sh 0 = "00"
         sh t = show t
show2 (Field e) = e
show2 (As _ s) = show2 s
show2 (Dot s1 s2) = s1 ++ "." ++ s2
show2 (Plus exp1 exp2) = (show2 exp1) ++ "+" ++ (show2 exp2)
show2 (Minus exp1 exp2) = (show2 exp1) ++ "-" ++ (show2 exp2)
show2 (Times exp1 exp2) = (show2 exp1) ++ "*" ++ (show2 exp2)
show2 (Div exp1 exp2) = (show2 exp1) ++ "/" ++ (show2 exp2)
show2 (Negate exp1) = "-" ++ (show2 exp1)
show2 (Brack exp1) = "(" ++ (show2 exp1) ++ ")"
show2 (All) = "All"
show2 (Nulo) = "Null"


instance Show Aggregate where
  show (Min _ s) = "Min " ++ (show2 s)
  show (Max _ s) = "Max " ++ (show2 s)
  show (Sum _ s) = "Sum " ++ (show2 s)
  show (Count _ s) = "Count " ++ (show2 s)
  show (Avg _ s) = "Avg " ++ (show2 s)


instance Show BoolExp where
  show (Not e) = "NOT (" ++ (show e) ++ ")"
  show (And e1 e2) = (show e1) ++ " AND " ++ (show e2)
  show (Or e1 e2) = (show e1) ++ " OR " ++ (show e2)
  show (Equal e1 e2) = (show e1) ++ " = " ++ (show e2)
  show (Less e1 e2) = (show e1) ++ " < " ++ (show e2)
  show (Great e1 e2) = (show e1) ++ " > " ++ (show e2)
  show (GEqual e1 e2) = (show e1) ++ " >= " ++ (show e2)
  show (LEqual e1 e2) = (show e1) ++ " <= " ++ (show e2)
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




printTable :: Show v => (v -> String) -> [String] -> AVL (HM.HashMap String v) -> IO ()
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
       f' x v =  print $ x HM.! v
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


retHeadOrNull :: [AVL a] -> AVL a
retHeadOrNull [] = emptyT
retHeadOrNull tables = head tables


-- Obtener los campos de cada tabla
giveMeOnlyFields :: Query(HM.HashMap TableName FieldNames)
giveMeOnlyFields = Q(\c -> return $ Right (c,HM.mapWithKey (\k -> \v -> HM.keys v) $ trd' c))
