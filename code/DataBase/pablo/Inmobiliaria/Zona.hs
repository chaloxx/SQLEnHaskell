module Zona where 
import AST (Args (..),Type(..),TableInfo(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["nombreZona","nombrePoblacion"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("nombreZona",A1 "Norte"),("nombrePoblacion",A1 "Rosario")]) E)
upd2 = m keys upd1 (Z E (fromList [("nombreZona",A1 "Sur"),("nombrePoblacion",A1 "Rosario")]) E)
upd3 = m keys upd2 (Z E (fromList [("nombreZona",A1 "Centro"),("nombrePoblacion",A1 "Rosario")]) E)
upd4 = m keys upd3 (Z E (fromList [("nombreZona",A1 "Oeste"),("nombrePoblacion",A1 "Rosario")]) E)
upd5 = m keys upd4 (Z E (fromList [("nombreZona",A1 "Norte"),("nombrePoblacion",A1 "Santa Fe")]) E)
upd6 = m keys upd5 (Z E (fromList [("nombreZona",A1 "Sur"),("nombrePoblacion",A1 "Santa Fe")]) E)
upd7 = m keys upd6 (Z E (fromList [("nombreZona",A1 "Centro"),("nombrePoblacion",A1 "Santa Fe")]) E)
upd8 = m keys upd7 (Z E (fromList [("nombreZona",A1 "Este"),("nombrePoblacion",A1 "Casilda")]) E)
upd9 = m keys upd8 (Z E (fromList [("nombreZona",A1 "Oeste"),("nombrePoblacion",A1 "Casilda")]) E)
upd10 = m keys upd9 (Z E (fromList [("nombreZona",A1 "Norte"),("nombrePoblacion",A1 "San Lorenzo")]) E)
upd11 = m keys upd10 (Z E (fromList [("nombreZona",A1 "Sur"),("nombrePoblacion",A1 "San Lorenzo")]) E)
upd12 = m keys upd11 (Z E (fromList [("nombreZona",A1 "Centro"),("nombrePoblacion",A1 "San Lorenzo")]) E)