module Zona where 
import AST (Args (..),Type(..),TableDescript(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["nombrePob","nombreZ"]

upd0 = E
upd1 = m keys upd0 (Z E (fromList [("nombrePob",A1 "Rosario"),("nombreZ",A1 "Norte")]) E)
upd2 = m keys upd1 (Z E (fromList [("nombrePob",A1 "Rosario"),("nombreZ",A1 "Sur")]) E)
upd3 = m keys upd2 (Z E (fromList [("nombrePob",A1 "Rosario"),("nombreZ",A1 "Centro")]) E)
upd4 = m keys upd3 (Z E (fromList [("nombrePob",A1 "Rosario"),("nombreZ",A1 "Oeste")]) E)
upd5 = m keys upd4 (Z E (fromList [("nombrePob",A1 "Santa Fe"),("nombreZ",A1 "Norte")]) E)
upd6 = m keys upd5 (Z E (fromList [("nombrePob",A1 "Santa Fe"),("nombreZ",A1 "Sur")]) E)
upd7 = m keys upd6 (Z E (fromList [("nombrePob",A1 "Santa Fe"),("nombreZ",A1 "Centro")]) E)
upd8 = m keys upd7 (Z E (fromList [("nombrePob",A1 "Casilda"),("nombreZ",A1 "Este")]) E)
upd9 = m keys upd8 (Z E (fromList [("nombrePob",A1 "Casilda"),("nombreZ",A1 "Oeste")]) E)
upd10 = m keys upd9 (Z E (fromList [("nombrePob",A1 "San Lorenzo"),("nombreZ",A1 "Norte")]) E)
upd11 = m keys upd10 (Z E (fromList [("nombrePob",A1 "San Lorenzo"),("nombreZ",A1 "Sur")]) E)
upd12 = m keys upd11 (Z E (fromList [("nombrePob",A1 "San Lorenzo"),("nombreZ",A1 "Centro")]) E)