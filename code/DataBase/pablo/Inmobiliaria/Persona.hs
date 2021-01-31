module Persona where 
import AST (Args (..),Type(..),TableInfo(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("telefono",A3 4304931),("codigo",A3 1001),("apellido",A1 "Planta"),("domicilio",A1 "Sarmiento 236, Rosario"),("nombre",A1 "Roberto")]) E)
upd2 = m keys upd1 (Z E (fromList [("telefono",A3 4304932),("codigo",A3 1002),("apellido",A1 "Aguas"),("domicilio",A1 "Avellaneda 2436, Rosario"),("nombre",A1 "Rogelio")]) E)
upd3 = m keys upd2 (Z E (fromList [("telefono",A3 4304933),("codigo",A3 1003),("apellido",A1 "Rodriguez"),("domicilio",A1 "Mitre 45, Rosario"),("nombre",A1 "Juan")]) E)
upd4 = m keys upd3 (Z E (fromList [("telefono",A3 4304934),("codigo",A3 1004),("apellido",A1 "Lopez"),("domicilio",A1 "San Martin 246, Rosario"),("nombre",A1 "Juana")]) E)
upd5 = m keys upd4 (Z E (fromList [("telefono",A3 4304935),("codigo",A3 1005),("apellido",A1 "Gonzalez"),("domicilio",A1 "Sarmiento 4236, Rosario"),("nombre",A1 "Mirta")]) E)
upd6 = m keys upd5 (Z E (fromList [("telefono",A3 445935),("codigo",A3 1006),("apellido",A1 "Perez"),("domicilio",A1 "Corrientes 4236, Santa Fe"),("nombre",A1 "Laura")]) E)
upd7 = m keys upd6 (Z E (fromList [("telefono",A3 455935),("codigo",A3 1007),("apellido",A1 "Salazar"),("domicilio",A1 "Moreno 236, Casilda"),("nombre",A1 "Luis")]) E)
upd8 = m keys upd7 (Z E (fromList [("telefono",A3 455935),("codigo",A3 1008),("apellido",A1 "Salazar"),("domicilio",A1 "Moreno 236, Casilda"),("nombre",A1 "Maria")]) E)
upd9 = m keys upd8 (Z E (fromList [("telefono",A3 4555001),("codigo",A3 1011),("apellido",A1 "Zarantonelli"),("domicilio",A1 "Sarmiento 123, Rosario"),("nombre",A1 "Ana")]) E)
upd10 = m keys upd9 (Z E (fromList [("telefono",A3 4555002),("codigo",A3 1012),("apellido",A1 "Yani"),("domicilio",A1 "Avellaneda 234, Rosario"),("nombre",A1 "Belen")]) E)
upd11 = m keys upd10 (Z E (fromList [("telefono",A3 4555003),("codigo",A3 1013),("apellido",A1 "Xuan"),("domicilio",A1 "Roca 345, San Lorenzo"),("nombre",A1 "Carlos")]) E)
upd12 = m keys upd11 (Z E (fromList [("telefono",A3 4555004),("codigo",A3 1014),("apellido",A1 "Watson"),("domicilio",A1 "Mitre 456, Casilda"),("nombre",A1 "Dario")]) E)
upd13 = m keys upd12 (Z E (fromList [("telefono",A3 4555005),("codigo",A3 1015),("apellido",A1 "Visconti"),("domicilio",A1 "Urquiza 567, Rosario"),("nombre",A1 "Emilio")]) E)
upd14 = m keys upd13 (Z E (fromList [("telefono",A3 4555006),("codigo",A3 1016),("apellido",A1 "Uriarte"),("domicilio",A1 "Alvear 678, Rosario"),("nombre",A1 "Facundo")]) E)
upd15 = m keys upd14 (Z E (fromList [("telefono",A3 4555007),("codigo",A3 1017),("apellido",A1 "Troncoso"),("domicilio",A1 "Belgrano 789, Santa Fe"),("nombre",A1 "Gabriela")]) E)
upd16 = m keys upd15 (Z E (fromList [("telefono",A3 4555008),("codigo",A3 1018),("apellido",A1 "Sosa"),("domicilio",A1 "Saavedra 890, Rosario"),("nombre",A1 "Hugo")]) E)