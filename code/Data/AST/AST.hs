module AST where

import qualified Data.HashMap.Strict as HM
import Avl (AVL(..))

data Date = Date {dayD::Int,monthD::Int,yearD::Int} deriving (Ord,Eq,Show)
data Time = Time {tHour::Int,tMinute::Int,tSecond::Int} deriving (Ord,Eq,Show)
data DateTime = DateTime {year::Int,month::Int,day::Int,hour::Int,minute::Int,second::Int} deriving (Ord,Eq,Show)


-- Definimos el entorno como el usuario actual, la BD que se está usando y la fuente usada
data Env = Env {name :: String, dataBase :: String, source :: String} deriving Show
type Types = HM.HashMap String Type
type TabTypes = HM.HashMap String Types
type Vals = HM.HashMap String Args
-- Definimos el contexto de una consulta
-- Esto nos permite hacer consultas recursivas o subconsultas
-- pues en cualquier momento podemos chequear el tipo de una expresión
-- o el valor de una variable de tupla
-- El contexto contiene 3 componentes :
--  Env (Entorno) : Usuario, base de datos, fuente de entrada
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
type BaseName = String
type HaveNull = Bool

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

-- Representamos información sobre una tabla
type TableDescript = ([String],[Type],[String],[String],ForeignKey)

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
data ManUsers = CUser UserName
              | SUser UserName
              | DUser UserName
              deriving Show

data UserInfo = UN UserName -- Nombre de usuario
              | UB [String] -- Bases de datos que pertenecen al usuario
              deriving (Show,Ord,Eq)

-- Operadores de álgebra relacional (Operan sobre las BD)
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


instance Show BoolExp where
  show (Not e) = "NOT " ++ (show e)
  show (And e1 e2) = (show e1) ++ " AND " ++ (show e2)
  show (Or e1 e2) = (show e1) ++ " OR " ++ (show e2)
  show (Equal e1 e2) = (show e1) ++ " = " ++ (show e2)
  show (Less e1 e2) = (show e1) ++ " < " ++ (show e2)
  show (Great e1 e2) = (show e1) ++ " > " ++ (show e2)
  show (InVals f dml) = (show f) ++ " IN " ++ (show dml)
  show (InQuery f ls) = (show f) ++ " IN " ++ (show ls)
  show (GrOrEq e1 e2) = (show e1) ++ " >= " ++ (show e2)
  show (LsOrEq e1 e2) = (show e1) ++ " <= " ++ (show e2)
  show (NotEq e1 e2) = (show e1) ++ " <> " ++ (show e2)


instance Show Aggregate where
  show (Min _ s) = "Min " ++ (show2 s)
  show (Max _ s) = "Max " ++ (show2 s)
  show (Sum _ s) = "Sum " ++ (show2 s)
  show (Count _ s) = "Count " ++ (show2 s)
  show (Avg _ s) = "Avg " ++ (show2 s)



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
show2 (As _ s) = s
show2 (Dot s1 s2) = s1 ++ "." ++ s2
show2 (Plus exp1 exp2) = (show2 exp1) ++ "+" ++ (show2 exp2)
show2 (Minus exp1 exp2) = (show2 exp1) ++ "-" ++ (show2 exp2)
show2 (Times exp1 exp2) = (show2 exp1) ++ "*" ++ (show2 exp2)
show2 (Div exp1 exp2) = (show2 exp1) ++ "/" ++ (show2 exp2)
show2 (Negate exp1) = "-" ++ (show2 exp1)
show2 (Brack exp1) = "(" ++ (show2 exp1) ++ ")"
show2 (All) = "All"
show2 (Nulo) = "Null"



show3 :: TableInfo -> String
show3 (TN n) = n


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


-- Argumentos de claúsulas (constantes y operaciones)
data Args = A1 String
          | A2 Aggregate
          | A3 Int
          | A4 Float
          | A5 DateTime  -- (fecha y hora )
          | A6 Date  --(solo fecha)
          | A7 Time -- (solo hora)
          | All
          | Subquery DML -- Tiene que devolver
          | As Args TableName -- Renombrar tabla
          | Nulo
          | Field FieldName
          | Dot TableName FieldName
          | Plus Args Args
          | Minus Args Args
          | Times Args Args
          | Div Args Args
          | Negate Args
          | Brack Args
          | Join JOINS Args Args BoolExp  --Relaciona 2 tablas
          | ColAs Args FieldNames FieldNames -- Renombrar columnas
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
              | GrOrEq Args Args
              | LsOrEq Args Args
              | NotEq Args Args
              deriving (Eq,Ord)







-- Orden (ascendente o descendente)
data O = A | D deriving (Show,Eq,Ord)






-- DDL Language (Diseñan la BD)

data DDL =   CBase BaseName
           | DBase BaseName
           | CTable Table [CArgs]
           | DTable FieldName
           | Use BaseName
           | ShowB
           | ShowT
           deriving (Show,Eq,Ord)


-- Argumentos para crear una tabla
data CArgs =  Col String Type HaveNull -- Descripción de columna
            | PKey [FieldName] -- Descripción de clave primaria
            | FKey [FieldName] Table [FieldName] RefOption RefOption -- Descripción de clave foránea
            deriving (Show,Eq,Ord)

-- Opciones de referencia
data RefOption = Restricted | Cascades | Nullifies  deriving (Show,Eq,Ord)


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
