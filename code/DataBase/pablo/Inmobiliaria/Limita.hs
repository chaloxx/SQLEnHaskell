module Limita where 
import AST (Args (..),Type(..),TableDescript(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["nombreP","nombreZ","nombreP2","nombreZ2"]

upd0 = E
upd1 = m keys upd0 (Z E (fromList [("nombreP2",A1 "Rosario"),("nombreZ2",A1 "Centro"),("nombreP",A1 "Rosario"),("nombreZ",A1 "Oeste")]) E)
upd2 = m keys upd1 (Z E (fromList [("nombreP2",A1 "Rosario"),("nombreZ2",A1 "Centro"),("nombreP",A1 "Rosario"),("nombreZ",A1 "Sur")]) E)
upd3 = m keys upd2 (Z E (fromList [("nombreP2",A1 "Rosario"),("nombreZ2",A1 "Centro"),("nombreP",A1 "Rosario"),("nombreZ",A1 "Norte")]) E)
upd4 = m keys upd3 (Z E (fromList [("nombreP2",A1 "Santa Fe"),("nombreZ2",A1 "Centro"),("nombreP",A1 "Santa Fe"),("nombreZ",A1 "Norte")]) E)
upd5 = m keys upd4 (Z E (fromList [("nombreP2",A1 "Santa Fe"),("nombreZ2",A1 "Centro"),("nombreP",A1 "Santa Fe"),("nombreZ",A1 "Sur")]) E)
upd6 = m keys upd5 (Z E (fromList [("nombreP2",A1 "San Lorenzo"),("nombreZ2",A1 "Centro"),("nombreP",A1 "San Lorenzo"),("nombreZ",A1 "Norte")]) E)
upd7 = m keys upd6 (Z E (fromList [("nombreP2",A1 "San Lorenzo"),("nombreZ2",A1 "Centro"),("nombreP",A1 "San Lorenzo"),("nombreZ",A1 "Sur")]) E)
upd8 = m keys upd7 (Z E (fromList [("nombreP2",A1 "Casilda"),("nombreZ2",A1 "Oeste"),("nombreP",A1 "Casilda"),("nombreZ",A1 "Este")]) E)