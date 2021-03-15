module Libro where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["Isbn"]
upd0 = E
upd1 = m keys upd0 (Z E (fromList [("Isbn",A1 "0001"),("Editorial",A1 "EMPA"),("Titulo",A1 "Ensayo Sobre la Ceguera"),("Precio",A3 800)]) E)
upd2 = m keys upd1 (Z E (fromList [("Isbn",A1 "0002"),("Editorial",A1 "EMPA"),("Titulo",A1 "Dracula"),("Precio",A3 800)]) E)
upd3 = m keys upd2 (Z E (fromList [("Isbn",A1 "0003"),("Editorial",A1 "UNR"),("Titulo",A1 "Calculo I"),("Precio",A3 300)]) E)
upd4 = m keys upd3 (Z E (fromList [("Isbn",A1 "0004"),("Editorial",A1 "UNR"),("Titulo",A1 "Sistemas"),("Precio",A3 100)]) E)
upd5 = m keys upd4 (Z E (fromList [("Isbn",A1 "0005"),("Editorial",A1 "UNR"),("Titulo",A1 "Aventuras"),("Precio",A3 100)]) E)