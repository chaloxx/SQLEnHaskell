module PrefiereZona where 
import AST (Args (..),Type(..),TableInfo(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigoCliente","nombreP","nombreZ"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("nombreP",A1 "Rosario"),("nombreZ",A1 "Centro"),("codigoCliente",A3 1012)]) E)
upd2 = m keys upd1 (Z E (fromList [("nombreP",A1 "Rosario"),("nombreZ",A1 "Centro"),("codigoCliente",A3 1013)]) E)
upd3 = m keys upd2 (Z E (fromList [("nombreP",A1 "Casilda"),("nombreZ",A1 "Oeste"),("codigoCliente",A3 1014)]) E)
upd4 = m keys upd3 (Z E (fromList [("nombreP",A1 "Casilda"),("nombreZ",A1 "Este"),("codigoCliente",A3 1014)]) E)
upd5 = m keys upd4 (Z E (fromList [("nombreP",A1 "Santa Fe"),("nombreZ",A1 "Sur"),("codigoCliente",A3 1015)]) E)
upd6 = m keys upd5 (Z E (fromList [("nombreP",A1 "Santa Fe"),("nombreZ",A1 "Norte"),("codigoCliente",A3 1015)]) E)
upd7 = m keys upd6 (Z E (fromList [("nombreP",A1 "Santa Fe"),("nombreZ",A1 "Norte"),("codigoCliente",A3 1016)]) E)
upd8 = m keys upd7 (Z E (fromList [("nombreP",A1 "Rosario"),("nombreZ",A1 "Centro"),("codigoCliente",A3 1017)]) E)
upd9 = m keys upd8 (Z E (fromList [("nombreP",A1 "Rosario"),("nombreZ",A1 "Sur"),("codigoCliente",A3 1017)]) E)
upd10 = m keys upd9 (Z E (fromList [("nombreP",A1 "Rosario"),("nombreZ",A1 "Norte"),("codigoCliente",A3 1017)]) E)
upd11 = m keys upd10 (Z E (fromList [("nombreP",A1 "Rosario"),("nombreZ",A1 "Oeste"),("codigoCliente",A3 1017)]) E)
upd12 = m keys upd11 (Z E (fromList [("nombreP",A1 "Rosario"),("nombreZ",A1 "Centro"),("codigoCliente",A3 1018)]) E)
upd13 = m keys upd12 (Z E (fromList [("nombreP",A1 "San Lorenzo"),("nombreZ",A1 "Sur"),("codigoCliente",A3 1005)]) E)
upd14 = m keys upd13 (Z E (fromList [("nombreP",A1 "Casilda"),("nombreZ",A1 "Oeste"),("codigoCliente",A3 1001)]) E)