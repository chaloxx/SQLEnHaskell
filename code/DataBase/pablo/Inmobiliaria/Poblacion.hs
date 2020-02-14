module Poblacion where 
import AST (Args (..),Type(..),TableDescript(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["nombrePoblacion"]

upd0 = E
upd1 = m keys upd0 (Z E (fromList [("nHabitantes",A3 1500000),("nombrePoblacion",A1 "Rosario")]) E)
upd2 = m keys upd1 (Z E (fromList [("nHabitantes",A3 14000),("nombrePoblacion",A1 "Casilda")]) E)
upd3 = m keys upd2 (Z E (fromList [("nHabitantes",A3 500000),("nombrePoblacion",A1 "Santa Fe")]) E)
upd4 = m keys upd3 (Z E (fromList [("nHabitantes",A3 400000),("nombrePoblacion",A1 "San Lorenzo")]) E)