module Users where
import AST (Args (..),Type(..),UserInfo(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys)
import Avl
import COrdering
keys = ["userName"]
upd0 = E
