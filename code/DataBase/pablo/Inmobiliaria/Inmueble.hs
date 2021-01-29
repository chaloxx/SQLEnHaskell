module Inmueble where 
import AST (Args (..),Type(..),TableInfo(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo"]
upd0 = E