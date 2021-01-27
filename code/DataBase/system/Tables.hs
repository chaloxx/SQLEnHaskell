module Tables where
import AST (Args (..),Type(..),TableInfo(..),RefOption(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys)
import Avl
import COrdering
keys = ["owner","dataBase","tableName"]
upd0 = E

upd1 = m keys upd0 (Z E (fromList [("types",TT [String,Int]),("fkey",TFK []),("refBy",TR []),("key",TK ["nombrePoblacion"]),("dataBase",TB "Inmobiliaria"),("tableName",TN "Poblacion"),("haveNull",HN ["nHabitantes"]),("scheme",TS ["nombrePoblacion","nHabitantes"]),("owner",TO "pablo")]) E)