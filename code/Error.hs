module Error where

import Data.HashMap.Strict hiding (foldr,map)
import AST (Env(..),Args(..),ParseResult(..),show2)
import Prelude hiding (lookup,fail)
import Patterns ((|||))
import Avl (isMember)
import Data.Either
import Utilities (fold,fold')

-- Módulo para errores y otras utilidades

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

errorIndFields = fail "La búsqueda debe ser sobre una columna"

typeError e = fail $ "Error de tipo en la expresion " ++ e ++ "\n"

divisionError = fail $ "División por cero"

errorKey x = fail $ "La clave de " ++ (fold x) ++ " ya existe"

errorSource = "Error en la extensión del archivo"

errorOpen p err =  "Warning: Couldn't open " ++ p ++ ": " ++ err

errorSelUser = "Primero debe seleccionar un usuario..."

errorSelBase = "Primero debe seleccionar una base de datos..."

welcome u = putStrLn $  "Bienvenido " ++ u ++ "!"

logError u = put $ "No existe el usuario " ++ u


baseExist b = put $ "Ya existe la base " ++ b
baseNotExist b = put $ "No existe la base " ++ b

notLog = put "No estás logueado"

invalidData = put "Los datos son incorrectos"

userAlreadyExist u = put $ "El usuario " ++ u ++ " ya existe"

errorComClose = Failed $ "Error de clausura de comentario"

errorComOpen =  Failed $ "Error de apertura de comentario"

--errorForeignKey s = fail $ "El valor referenciado " ++ (show s) ++ " no existe"

errorForeignKey v s = fail $ "(" ++ fold v ++ ")" ++ " no existe en " ++ s


errorCreateTableKeyOrFK = put "El esquema no posee una clave o la clave foránea no es parte del esquema"

tableDoesntExist = put "La tabla no existe"

errorCreateTableNulls = put "Error al designar nulls"

errorCheckReference = put $ "Error chequeando las referencias"

succesCreateReference n s = put $ "Referencia creada entre " ++ n ++ " y " ++ s ++ " con éxito.."

errorCreateReference = put  "La clave foránea no coincide con la clave de la tabla referenciada"

errorDropTable s = "La tabla " ++ s ++ " no existe.."

imposibleDelete n l = put $ "Imposible borrar, " ++ n ++ "es referenciada por " ++ (tail (fold' l))

succesDropTable s = put $ "La tabla " ++ s ++ " fue eliminada con éxito"

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

errorJoin ls = retFail $ "Ambigüedad en los atributos " ++ (foldl (\ x y -> x ++ "," ++ y) "" ls)

errorColAs = retFail "Error en los argumentos de COL AS"

-- Indicar error
fail = Left

retFail :: String ->  IO(Either String b)
retFail = return.fail



-- Imprimir
put = putStrLn


-- Indicar que todo anduvo bien
ok = Right
retOk :: a -> IO(Either String a)
retOk = return.ok
