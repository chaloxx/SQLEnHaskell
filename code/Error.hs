module Error where
import Data.HashMap.Strict hiding (foldr,map)
import AST
import Prelude hiding (lookup,fail)
import Data.Typeable
import Avl ((|||),isMember)
import Data.Either

printError :: String -> IO ()
printError msg = error msg


errorMsg = "Nombre de usuario inválido"
errorMsg2 = "No existe el usuario"


combineEither :: Monoid a => (b -> c -> e) -> Either a b -> Either a c -> Either a e
combineEither op a b = case a of
                        Right x -> case b of
                                     Right y -> return $ op x y
                                     Left y -> Left y
                        Left x -> Left x



errorField1 x = Left (x ++ " no es un atributo válido\n")
errorField2 x t1 t2 = x ++ " tiene tipo " ++ (show t1) ++ " ,se esperaba tipo " ++ (show t2) ++ "\n"



typeOfArgs :: Args -> Type
typeOfArgs (A1 _) = String
typeOfArgs (A3 _) = Int
typeOfArgs (A4 _) = Float
typeOfArgs (A5 _) = Datetime
typeOfArgs (A6 _) = Dates
typeOfArgs (A7 _) = Tim




errorPi s = retFail  ("Atributos " ++ show s ++
                   " inválidos en SELECT" )

errorPi2 = retFail ("No pueden mezclarse funciones de agregado y selecciones " ++
                 "sin haber usado la claúsula GROUP BY")

errorPi3 = retFail $ "Inválido uso de ALL en SELECT"

errorPi4 = retFail $ "Error en subconsulta..."

errorPi5 s = fail $ "La tabla " ++ s ++ " no existe"

errorSigma = retFail "No se puede usar una claúsula WHERE junto con una cláusula GROUP BY"

errorSigma2 = fail $ "El orden de los atributos es inválido.."

errorSigma3 = fail $ "Demasiados atributos en operador IN"

errorGroup s =  fail $ "Atributos " ++ show s ++ " inválidos en GROUP BY"

errorOrder s = fail $ "Atributos " ++ show s ++ " inválidos en ORDER BY"

errorProd s = retFail $ "La tabla " ++ s ++ " no existe"

errorProd2 = retFail "Prohibido usar subconsultas con claúsulas GROUP BY en FROM"

errorAs = fail $ "Error en sentencia AS"

errorEvalBool s = fail $ "Atributo " ++ s " inválido"

errorFind s = fail $ "No se pudo encontrar el atributo " ++ s

typeError e = fail $ "Error de tipo en la expresion " ++ e ++ "\n"

divisionError = fail $ "División por cero"

errorKey x = fail $ "La clave de " ++ (fold x) ++ " ya existe"

errorSource = "Error en la extensión del archivo"

errorOpen p err =  "Warning: Couldn't open " ++ p ++ ": " ++ err

errorSelUser = "Primero debe seleccionar un usuario..."

errorSelBase = "Primero debe seleccionar una base de datos..."

welcome u s = do putStrLn $  "Bienvenido " ++ u ++ "!"
                 return (Env u "" s)

logError u s = do put $ "No existe el usuario " ++ u  ++ " o la contraseña es incorrecta "
                  return (Env "" "" s)

baseExist b = put $ "Ya existe la base " ++ b
baseNotExist b = put $ "No existe la base " ++ b

notLog = put "No estás logueado"

invalidData = put "Los datos son incorrectos"

nameAlreadyExist u = put $ "El nombre " ++ u ++ " ya está en uso"

errorComClose = Failed $ "Error de clausura de comentario"

errorComOpen =  Failed $ "Error de apertura de comentario"

errorForeignKey s = fail $ "El valor referenciado " ++ (show s) ++ " no existe"

errorCreateTableKeyOrFK = put "El esquema no posee una clave o la clave foránea no es parte del esquema"

tableDoesntExist = put "La tabla no existe"

errorCreateTableNulls = put "Error al designar nulls"

errorCheckReference = put $ "Error chequeando las referencias"

succesCreateReference n s = put $ "Referencia creada entre " ++ n ++ " y " ++ s ++ " con éxito.."

errorCreateReference = put  "La clave foránea no coincide con la clave de la tabla referenciada"

errorDropTable s = "La tabla " ++ s ++ " no existe.."

errorDropAllTable = "Error al eliminar todas las tablas"

imposibleDelete n l = put $ "Imposible borrar, " ++ n ++ " es referenciada por " ++ (tail (fold' l))

succesDropTable s = put $ "La tabla " ++ s ++ " fue eliminada con éxito"

succesDropAllTables b  = put $ "Todas las tablas de la base " ++ b ++ " fueron eliminadas con éxito"

succesCreateTable s = put $ "La tabla " ++ s ++ " fue creada con éxito"

tableExists n = put $ "Ya existe la tabla " ++ n

errorUpdateFields l = put $ "Los atributos " ++ (tail $ foldl (\x y -> x ++ "," ++ y) "" l) ++ " están fuera del esquema o alguno es parte de la clave primaria"

errorHav = retFail "No puede haber una claúsula HAVING sin una claúsula GROUP BY"
errorRestricted x n =  let k = keys x
                           l = map (\s -> x ! s) k
                       in retFail $ "No se puede modificar o eliminar (" ++ fold l  ++ ") pues es un elemento referenciado por la tabla " ++ n

errorTop = retFail "La claúsula LIMIT solo se puede aplicar a una tabla"
errorTop2 = retFail "La claúsula LIMIT solo se puede usar con números no negativos"


errorSet = fail "Error en unión"
errorSet2 = fail "Relaciones con distinto número de atributos"
errorSet3 = fail "Atributos con tipos incompatibles"

errorLike = fail "Los argumentos de Like deben ser strings"

fail = Left
retFail :: String ->  IO(Either String b)
retFail = return.fail

put = putStrLn


ok = Right
retOk :: a -> IO(Either String a)
retOk = return.ok

exitToInsert :: [Args] -> Either String String
exitToInsert s = return $  (fold s) ++ " se inserto correctamente"


fold :: [Args] -> String
fold s = tail $ fold' $ map show2 s
fold' = foldl (\ x y -> x ++ "," ++ y) ""

msg = "Error buscando el objeto"

-- Realiza una busqueda en g a partir de una lista y:ys y  v
lookupList ::Show b => HashMap String (HashMap String b) -> [String] -> String -> Either String b
lookupList _ [] v = errorFind v
lookupList g q@(y:ys) v = case lookup y g of
                           Nothing -> error $ show g
                           Just r -> case lookup v r of
                                      Nothing -> lookupList g ys v
                                      Just x' -> return x'

-- Unir 2 listas, sin elementos repetidos en ambas
unionL :: Eq e => [e] -> [e] -> [e]
unionL [] l = l
unionL (x:xs) l = if x `elem` l then unionL xs l
                  else unionL xs (x:l)




syspath = "DataBase/system/"
userpath = syspath++"Users"
tablepath = syspath++"Tables"
