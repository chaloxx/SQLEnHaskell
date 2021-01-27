module AST where
import Avl (AVL(..),mapT,pushL,join,value,left,right,emptyT)
import qualified Data.HashMap.Strict as HM  (HashMap (..),insert,delete,empty,update,fromList,(!),mapWithKey,keys,map)
import qualified Data.Set as S
import Data.Hashable
import Data.Typeable (TypeRep)
import System.Console.Terminal.Size  (size,width)
import Data.List.Split


-- Modulo con árboles de sintaxis abstractas y otras definiciones útiles

data Date = Date {dayD::Int,monthD::Int,yearD::Int} deriving (Ord,Eq,Show)
data Time = Time {tHour::Int,tMinute::Int,tSecond::Int} deriving (Ord,Eq,Show)
data DateTime = DateTime {year::Int,month::Int,day::Int,hour::Int,minute::Int,second::Int} deriving (Ord,Eq,Show)



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



ioEitherFilterT ::Show e => (e -> IO(Either a Bool)) -> AVL e -> IO(Either a (AVL e))
ioEitherFilterT _ E = return $ Right E
ioEitherFilterT f t = pattern  ((ioEitherFilterT f (left t) |||| ioEitherFilterT f (right t)) |||| f (value t))
                               (\((l,r),b) -> let t' = join l r
                                              in if b then pushL (value t) t'
                                                 else t')




-- Definimos el entorno como el usuario actual, la BD que se está usando y la fuente usada
data Env = Env {name :: String, dataBase :: String, source :: String} deriving Show
type Types = HM.HashMap String Type
type TabTypes = HM.HashMap String Types
type Vals = HM.HashMap String Args
-- Definimos el contexto de una consulta
-- Esto nos permite llevar el estado de una consulta
-- pues en cualquier momento podemos chequear el tipo de una expresión
-- o el valor de una variable de tupla
-- El contexto contiene 3 componentes :
--  Env (Entorno) : Usuario, base de datos, fuente de datos
-- Types : Campos de cada tabla y los tipos de cada campo
-- Vals : Campos de cada tabla y los valores de cada campo
type Context = (Env,HM.HashMap String Vals,HM.HashMap String Types )

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
-- Consta de 5 componentes:
-- Un contexto en el cual se ejecuta la consulta
-- Un booleano para diferenciar si la consulta incluye una claúsula group by (requiere un tratamiento especial)
-- Un par ordenado entre alias de tablas y su nombre
-- Una lista de atributos actuales
-- Una lista de tablas
type Answer =  (Context,Bool,TableNames,FieldNames,[Tab])
-- Con un tabReg almacenamos el valor de los registros de las tablas
-- cuando los almacenamos dentro de un contexto
type TabReg = HM.HashMap String Reg

-- Representamos los registros de una tabla
type Reg = HM.HashMap String Args

-- Representamos una Tala
type Tab = AVL (Reg)

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


--
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
              | Great Args Args
              | Less Args Args
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


-- instance (Ord a, Ord v) => Ord (HM.HashMap a v) where
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
  show (Not e) = "NOT " ++ (show e)
  show (And e1 e2) = (show e1) ++ " AND " ++ (show e2)
  show (Or e1 e2) = (show e1) ++ " OR " ++ (show e2)
  show (Equal e1 e2) = (show e1) ++ " = " ++ (show e2)
  show (Less e1 e2) = (show e1) ++ " < " ++ (show e2)
  show (Great e1 e2) = (show e1) ++ " > " ++ (show e2)
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


fields = ["owner", "dataBase","tableName"]
fields2 = fields ++ ["scheme","types","key","fkey","refBy","haveNull"]
fields3 = fields ++ ["referencedBy"]

belong :: Eq a => [a] -> a -> Bool
belong [] _ = False
belong (x:xs) y = if x == y then True
                  else belong xs y

createInfoRegister :: Env -> String -> HM.HashMap String TableInfo
createInfoRegister e n =  HM.fromList $ zip fields [TO (name e), TB (dataBase e),TN n]





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


-- Obtener un HM con los campos de cada tabla
giveMeOnlyFields :: HM.HashMap a (HM.HashMap b c) -> HM.HashMap a [b]
giveMeOnlyFields hm = HM.mapWithKey (\k -> \v -> HM.keys v) hm
