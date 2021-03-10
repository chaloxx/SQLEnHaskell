module Limita where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["nombre_poblacion","nombre_zona","nombre_poblacion_2","nombre_zona_2"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("nombre_zona_2",A1 "Centro"),("nombre_poblacion",A1 "Rosario"),("nombre_poblacion_2",A1 "Rosario"),("nombre_zona",A1 "Oeste")]) E)
upd2 = m keys upd1 (Z E (fromList [("nombre_zona_2",A1 "Centro"),("nombre_poblacion",A1 "Rosario"),("nombre_poblacion_2",A1 "Rosario"),("nombre_zona",A1 "Sur")]) E)
upd3 = m keys upd2 (Z E (fromList [("nombre_zona_2",A1 "Centro"),("nombre_poblacion",A1 "Rosario"),("nombre_poblacion_2",A1 "Rosario"),("nombre_zona",A1 "Norte")]) E)
upd4 = m keys upd3 (Z E (fromList [("nombre_zona_2",A1 "Centro"),("nombre_poblacion",A1 "Santa Fe"),("nombre_poblacion_2",A1 "Santa Fe"),("nombre_zona",A1 "Norte")]) E)
upd5 = m keys upd4 (Z E (fromList [("nombre_zona_2",A1 "Centro"),("nombre_poblacion",A1 "Santa Fe"),("nombre_poblacion_2",A1 "Santa Fe"),("nombre_zona",A1 "Sur")]) E)
upd6 = m keys upd5 (Z E (fromList [("nombre_zona_2",A1 "Centro"),("nombre_poblacion",A1 "San Lorenzo"),("nombre_poblacion_2",A1 "San Lorenzo"),("nombre_zona",A1 "Norte")]) E)
upd7 = m keys upd6 (Z E (fromList [("nombre_zona_2",A1 "Centro"),("nombre_poblacion",A1 "San Lorenzo"),("nombre_poblacion_2",A1 "San Lorenzo"),("nombre_zona",A1 "Sur")]) E)
upd8 = m keys upd7 (Z E (fromList [("nombre_zona_2",A1 "Oeste"),("nombre_poblacion",A1 "Casilda"),("nombre_poblacion_2",A1 "Casilda"),("nombre_zona",A1 "Este")]) E)