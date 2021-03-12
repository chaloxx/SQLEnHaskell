module Libro where 
import AST (Args (..),Type(..),TableInfo(..),Dates(..),Times(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["Isbn"]
upd0 = E
upd1 = m keys upd0 (P (P (Z E (fromList [("Isbn",A1 "0003"),("Editorial",A1 "UNR"),("Titulo",A1 "Calculo I"),("Precio",A4 399.3)]) E) (fromList [("Isbn",A1 "0001"),("Editorial",A1 "EMPA"),("Titulo",A1 "Ensayo Sobre la Ceguera"),("Precio",A3 800)]) E) (fromList [("Isbn",A1 "0002"),("Editorial",A1 "EMPA"),("Titulo",A1 "Dracula"),("Precio",A3 800)]) (Z E (fromList [("Isbn",A1 "0004"),("Editorial",A1 "UNR"),("Titulo",A1 "Sistemas"),("Precio",A4 133.1)]) E))
