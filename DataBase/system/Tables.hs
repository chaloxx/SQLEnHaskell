module Tables where
import AST (Args (..),Type(..),TableInfo(..),RefOption(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys)
import Avl
import COrdering
keys = ["owner","dataBase","tableName"]
upd0 = E
upd1 = m keys upd0 (P (Z E (fromList [("types",TT [String,String,String,String,Int]),("fkey",TFK []),("refBy",TR [("Escribe",Restricted,Restricted)]),("key",TK ["Id"]),("dataBase",TB "Libreria"),("tableName",TN "Autor"),("haveNull",HN []),("scheme",TS ["Nombre","Apellido","Nacionalidad","Residencia","Id"]),("owner",TO "pablo")]) E) (fromList [("types",TT [String,String,String,Int]),("fkey",TFK []),("refBy",TR [("Escribe",Cascades,Cascades)]),("key",TK ["Isbn"]),("dataBase",TB "Libreria"),("tableName",TN "Libro"),("haveNull",HN []),("scheme",TS ["Isbn","Titulo","Editorial","Precio"]),("owner",TO "pablo")]) E)

upd2 = m keys upd1 (Z E (fromList [("types",TT [Date,Int,String]),("fkey",TFK [("Autor",[("Id","Id")]),("Libro",[("Isbn","Isbn")])]),("refBy",TR []),("key",TK ["Id","Isbn","A\241o"]),("dataBase",TB "Libreria"),("tableName",TN "Escribe"),("haveNull",HN []),("scheme",TS ["A\241o","Id","Isbn"]),("owner",TO "pablo")]) E)