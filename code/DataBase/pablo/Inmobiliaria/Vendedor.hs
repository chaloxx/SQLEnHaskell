module Vendedor where 
import AST (Args (..),Type(..),TableDescript(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo"]

upd0 = E
upd1 = m keys upd0 (Z E (fromList [("codigo",A3 1004),("sueldo",A3 10000),("cuil",A1 "21-12777999-2")]) E)
upd2 = m keys upd1 (Z E (fromList [("codigo",A3 1005),("sueldo",A3 10000),("cuil",A1 "21-13777999-2")]) E)
upd3 = m keys upd2 (Z E (fromList [("codigo",A3 1006),("sueldo",A3 10000),("cuil",A1 "21-14777999-2")]) E)