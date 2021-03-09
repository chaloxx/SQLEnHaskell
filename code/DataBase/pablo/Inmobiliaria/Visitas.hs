module Visitas where 
import AST (Args (..),Type(..),TableInfo(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo_inmueble","fecha_hora"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 29, month = 10, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1011),("codigo_inmueble",A1 "Slr0001")]) E)
upd2 = m keys upd1 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 29, month = 10, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1012),("codigo_inmueble",A1 "Ros0001")]) E)
upd3 = m keys upd2 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 28, month = 10, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1011),("codigo_inmueble",A1 "Slr0001")]) E)
upd4 = m keys upd3 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 28, month = 10, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1012),("codigo_inmueble",A1 "Ros0001")]) E)
upd5 = m keys upd4 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 15, month = 10, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1015),("codigo_inmueble",A1 "Ros0001")]) E)
upd6 = m keys upd5 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 15, month = 10, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1016),("codigo_inmueble",A1 "Ros0002")]) E)
upd7 = m keys upd6 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 1, month = 2, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1013),("codigo_inmueble",A1 "Ros0001")]) E)
upd8 = m keys upd7 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 2, month = 2, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1013),("codigo_inmueble",A1 "Ros0002")]) E)
upd9 = m keys upd8 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 3, month = 2, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1013),("codigo_inmueble",A1 "Ros0003")]) E)
upd10 = m keys upd9 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 1, month = 3, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1001),("codigo_inmueble",A1 "Cas0002")]) E)
upd11 = m keys upd10 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 6, month = 11, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1018),("codigo_inmueble",A1 "Stf0001")]) E)
upd12 = m keys upd11 (Z E (fromList [("fecha_hora",A5 (DateTime {year = 8, month = 11, day = 2014, hour = 10, minute = 0, second = 0})),("codigo_cliente",A3 1018),("codigo_inmueble",A1 "Stf0001")]) E)