module PoseeInmueble where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo_propietario","codigo_inmueble"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("codigo_propietario",A3 1003),("codigo_inmueble",A1 "Ros0001")]) E)
upd2 = m keys upd1 (Z E (fromList [("codigo_propietario",A3 1003),("codigo_inmueble",A1 "Ros0002")]) E)
upd3 = m keys upd2 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0003")]) E)
upd4 = m keys upd3 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0004")]) E)
upd5 = m keys upd4 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0005")]) E)
upd6 = m keys upd5 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0006")]) E)
upd7 = m keys upd6 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0007")]) E)
upd8 = m keys upd7 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0008")]) E)
upd9 = m keys upd8 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0009")]) E)
upd10 = m keys upd9 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0010")]) E)
upd11 = m keys upd10 (Z E (fromList [("codigo_propietario",A3 1002),("codigo_inmueble",A1 "Ros0011")]) E)
upd12 = m keys upd11 (Z E (fromList [("codigo_propietario",A3 1007),("codigo_inmueble",A1 "Cas0001")]) E)
upd13 = m keys upd12 (Z E (fromList [("codigo_propietario",A3 1007),("codigo_inmueble",A1 "Cas0002")]) E)
upd14 = m keys upd13 (Z E (fromList [("codigo_propietario",A3 1007),("codigo_inmueble",A1 "Stf0001")]) E)
upd15 = m keys upd14 (Z E (fromList [("codigo_propietario",A3 1007),("codigo_inmueble",A1 "Stf0002")]) E)
upd16 = m keys upd15 (Z E (fromList [("codigo_propietario",A3 1007),("codigo_inmueble",A1 "Stf0003")]) E)
upd17 = m keys upd16 (Z E (fromList [("codigo_propietario",A3 1007),("codigo_inmueble",A1 "Stf0004")]) E)
upd18 = m keys upd17 (Z E (fromList [("codigo_propietario",A3 1008),("codigo_inmueble",A1 "Stf0004")]) E)
upd19 = m keys upd18 (Z E (fromList [("codigo_propietario",A3 1007),("codigo_inmueble",A1 "Stf0005")]) E)
upd20 = m keys upd19 (Z E (fromList [("codigo_propietario",A3 1008),("codigo_inmueble",A1 "Stf0005")]) E)
upd21 = m keys upd20 (Z E (fromList [("codigo_propietario",A3 1008),("codigo_inmueble",A1 "Slr0001")]) E)