module Users where
import AST (Args (..),Type(..),UserInfo(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys)
import Avl
import COrdering
keys = ["userName"]
upd0 = E
upd1 = m keys upd0 (N E (fromList [("pass",UP "pepe"),("userName",UN "alfredo"),("dataBases",UB [])]) (Z E (fromList [("pass",UP "alonso"),("userName",UN "pablo"),("dataBases",UB ["Libreria","Inmobiliaria"])]) E))