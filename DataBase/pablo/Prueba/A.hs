module A where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("codigo",A3 1),("nombre",A1 "pepe")]) E)