module Poblacion where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["nombre_poblacion"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("nombre_poblacion",A1 "Rosario"),("n_habitantes",A3 1500000)]) E)
upd2 = m keys upd1 (Z E (fromList [("nombre_poblacion",A1 "Casilda"),("n_habitantes",A3 14000)]) E)
upd3 = m keys upd2 (Z E (fromList [("nombre_poblacion",A1 "Santa Fe"),("n_habitantes",A3 500000)]) E)
upd4 = m keys upd3 (Z E (fromList [("nombre_poblacion",A1 "San Lorenzo"),("n_habitantes",A3 400000)]) E)