module Tables where
import AST (Args (..),Type(..),TableInfo(..),RefOption(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys)
import Avl
import COrdering
keys = ["owner","dataBase","tableName"]
upd0 = E
upd1 = m keys upd0 (N E (fromList [("types",TT [String,Int]),("fkey",TFK []),("refBy",TR [("Zona",Cascades,Cascades)]),("key",TK ["nombrePoblacion"]),("dataBase",TB "Inmobiliaria"),("tableName",TN "Poblacion"),("haveNull",HN ["nHabitantes"]),("scheme",TS ["nombrePoblacion","nHabitantes"]),("owner",TO "pablo")]) (Z E (fromList [("types",TT [String,String]),("fkey",TFK [("Poblacion",[("nombrePoblacion","nombrePoblacion")])]),("refBy",TR [("Inmueble",Cascades,Cascades)]),("key",TK ["nombreZona","nombrePoblacion"]),("dataBase",TB "Inmobiliaria"),("tableName",TN "Zona"),("haveNull",HN []),("scheme",TS ["nombrePoblacion","nombreZona"]),("owner",TO "pablo")]) E))

upd2 = m keys upd1 (Z E (fromList [("types",TT [String,Int,String,Int,String,String]),("fkey",TFK [("Zona",[("nombreP","nombrePoblacion"),("nombreZ","nombreZona")])]),("refBy",TR []),("key",TK ["codigo"]),("dataBase",TB "Inmobiliaria"),("tableName",TN "Inmueble"),("haveNull",HN []),("scheme",TS ["codigo","precio","direccion","superficie","nombreP","nombreZ"]),("owner",TO "pablo")]) E)