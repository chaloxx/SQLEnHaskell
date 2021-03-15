module Tables where
import AST (Args (..),Type(..),TableInfo(..),RefOption(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys)
import Avl
import COrdering
keys = ["owner","dataBase","tableName"]
upd0 = E
