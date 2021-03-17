module B where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["nombreB"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("codigoB",A3 1),("nombreB",A1 "pepa")]) E)