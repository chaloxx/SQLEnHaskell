module Escribe where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["Id","Isbn","A\241o"]
upd0 = E
upd1 = m keys upd0 (Z (Z E (fromList [("Isbn",A1 "0004"),("Id",A3 5),("A\241o",A6 (Day {dayD = 1, monthD = 1, yearD = 1995}))]) E) (fromList [("Isbn",A1 "0001"),("Id",A3 4),("A\241o",A6 (Day {dayD = 1, monthD = 1, yearD = 2000}))]) (Z E (fromList [("Isbn",A1 "0002"),("Id",A3 5),("A\241o",A6 (Day {dayD = 1, monthD = 1, yearD = 1897}))]) E))
