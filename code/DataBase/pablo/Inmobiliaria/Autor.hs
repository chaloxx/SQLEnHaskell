module Autor where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["Id"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("Residencia",A1 "Rosario"),("Id",A3 1),("Apellido",A1 "Ariel"),("Nacionalidad",A1 "Argentina"),("Nombre",A1 "Damian")]) E)
upd2 = m keys upd1 (Z E (fromList [("Residencia",A1 "Venado"),("Id",A3 2),("Apellido",A1 "Luis"),("Nacionalidad",A1 "Argentina"),("Nombre",A1 "Pablo")]) E)
upd3 = m keys upd2 (Z E (fromList [("Residencia",A1 "Rosario"),("Id",A3 3),("Apellido",A1 "Castillo"),("Nacionalidad",A1 "Argentina"),("Nombre",A1 "Abelardo")]) E)
upd4 = m keys upd3 (Z E (fromList [("Residencia",A1 "Lisboa"),("Id",A3 4),("Apellido",A1 "Saramago"),("Nacionalidad",A1 "Portugal"),("Nombre",A1 "Jose")]) E)
upd5 = m keys upd4 (Z E (fromList [("Residencia",A1 "Londres"),("Id",A3 5),("Apellido",A1 "Stoker"),("Nacionalidad",A1 "Inglaterra"),("Nombre",A1 "Bram")]) E)
upd6 = m keys upd5 (Z E (fromList [("Residencia",A1 "San Pablo"),("Id",A3 6),("Apellido",A1 "Lopes"),("Nacionalidad",A1 "Brasil"),("Nombre",A1 "Pepito")]) E)