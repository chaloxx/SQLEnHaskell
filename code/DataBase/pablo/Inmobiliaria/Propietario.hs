module Propietario where 
import AST (Args (..),Type(..),TableDescript(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigoP"]

upd0 = E
upd1 = m keys upd0 (Z E (fromList [("dni",A3 8777999),("codigoP",A3 1002)]) E)
upd2 = m keys upd1 (Z E (fromList [("dni",A3 9777999),("codigoP",A3 1003)]) E)
upd3 = m keys upd2 (Z E (fromList [("dni",A3 10777999),("codigoP",A3 1004)]) E)
upd4 = m keys upd3 (Z E (fromList [("dni",A3 20777999),("codigoP",A3 1007)]) E)
upd5 = m keys upd4 (Z E (fromList [("dni",A3 20778000),("codigoP",A3 1008)]) E)