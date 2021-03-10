module Inmueble where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("codigo",A1 "Ros0001"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Centro"),("precio",A3 200000),("superficie",A3 80),("direccion",A1 "Sarmiento 234")]) E)
upd2 = m keys upd1 (Z E (fromList [("codigo",A1 "Ros0002"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Centro"),("precio",A3 3000000),("superficie",A3 90),("direccion",A1 "Mitre 134")]) E)
upd3 = m keys upd2 (Z E (fromList [("codigo",A1 "Ros0003"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Centro"),("precio",A3 600000),("superficie",A3 60),("direccion",A1 "Rioja 344")]) E)
upd4 = m keys upd3 (Z E (fromList [("codigo",A1 "Ros0004"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Sur"),("precio",A3 900000),("superficie",A3 92),("direccion",A1 "Cordoba 344")]) E)
upd5 = m keys upd4 (Z E (fromList [("codigo",A1 "Ros0005"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Sur"),("precio",A3 110000),("superficie",A3 102),("direccion",A1 "Santa Fe 344")]) E)
upd6 = m keys upd5 (Z E (fromList [("codigo",A1 "Ros0006"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Sur"),("precio",A3 700000),("superficie",A3 52),("direccion",A1 "San Lorenzo 344")]) E)
upd7 = m keys upd6 (Z E (fromList [("codigo",A1 "Ros0007"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Norte"),("precio",A3 820000),("superficie",A3 93),("direccion",A1 "Alberdi 3344")]) E)
upd8 = m keys upd7 (Z E (fromList [("codigo",A1 "Ros0008"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Norte"),("precio",A3 830000),("superficie",A3 44),("direccion",A1 "Rondeau 4044")]) E)
upd9 = m keys upd8 (Z E (fromList [("codigo",A1 "Ros0009"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Oeste"),("precio",A3 640000),("superficie",A3 92),("direccion",A1 "Mendoza 5344")]) E)
upd10 = m keys upd9 (Z E (fromList [("codigo",A1 "Ros0010"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Oeste"),("precio",A3 650000),("superficie",A3 110),("direccion",A1 "Rioja 2344")]) E)
upd11 = m keys upd10 (Z E (fromList [("codigo",A1 "Ros0011"),("nombre_poblacion",A1 "Rosario"),("nombre_zona",A1 "Oeste"),("precio",A3 660000),("superficie",A3 64),("direccion",A1 "Mendoza 2344")]) E)
upd12 = m keys upd11 (Z E (fromList [("codigo",A1 "Cas0001"),("nombre_poblacion",A1 "Casilda"),("nombre_zona",A1 "Este"),("precio",A3 670000),("superficie",A3 250),("direccion",A1 "Mitre 111")]) E)
upd13 = m keys upd12 (Z E (fromList [("codigo",A1 "Cas0002"),("nombre_poblacion",A1 "Casilda"),("nombre_zona",A1 "Oeste"),("precio",A3 680000),("superficie",A3 90),("direccion",A1 "San Martin 222")]) E)
upd14 = m keys upd13 (Z E (fromList [("codigo",A1 "Stf0001"),("nombre_poblacion",A1 "Santa Fe"),("nombre_zona",A1 "Centro"),("precio",A3 690000),("superficie",A3 89),("direccion",A1 "San Martin 1234")]) E)
upd15 = m keys upd14 (Z E (fromList [("codigo",A1 "Stf0002"),("nombre_poblacion",A1 "Santa Fe"),("nombre_zona",A1 "Centro"),("precio",A3 710000),("superficie",A3 91),("direccion",A1 "San Martin 1345")]) E)
upd16 = m keys upd15 (Z E (fromList [("codigo",A1 "Stf0003"),("nombre_poblacion",A1 "Santa Fe"),("nombre_zona",A1 "Centro"),("precio",A3 810000),("superficie",A3 99),("direccion",A1 "San Martin 1456")]) E)
upd17 = m keys upd16 (Z E (fromList [("codigo",A1 "Stf0004"),("nombre_poblacion",A1 "Santa Fe"),("nombre_zona",A1 "Norte"),("precio",A3 611000),("superficie",A3 99),("direccion",A1 "Mitre 46")]) E)
upd18 = m keys upd17 (Z E (fromList [("codigo",A1 "Stf0005"),("nombre_poblacion",A1 "Santa Fe"),("nombre_zona",A1 "Sur"),("precio",A3 1000000),("superficie",A3 99),("direccion",A1 "Mitre 4446")]) E)
upd19 = m keys upd18 (Z E (fromList [("codigo",A1 "Slr0001"),("nombre_poblacion",A1 "San Lorenzo"),("nombre_zona",A1 "Sur"),("precio",A3 1000000),("superficie",A3 109),("direccion",A1 "Maipu 46")]) E)