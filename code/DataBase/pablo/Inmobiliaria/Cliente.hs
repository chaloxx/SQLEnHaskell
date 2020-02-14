module Cliente where 
import AST (Args (..),Type(..),TableDescript(..),Date(..),Time(..),DateTime(..))
import Data.Typeable
import Data.HashMap.Strict hiding (keys) 
import Avl (AVL(..),m)
import COrdering
keys = ["codigo"]

upd0 = E
upd1 = m keys upd0 (Z E (fromList [("codigo",A3 1011),("vendedor",A3 1004)]) E)
upd2 = m keys upd1 (Z E (fromList [("codigo",A3 1012),("vendedor",A3 1004)]) E)
upd3 = m keys upd2 (Z E (fromList [("codigo",A3 1013),("vendedor",A3 1004)]) E)
upd4 = m keys upd3 (Z E (fromList [("codigo",A3 1014),("vendedor",A3 1004)]) E)
upd5 = m keys upd4 (Z E (fromList [("codigo",A3 1015),("vendedor",A3 1005)]) E)
upd6 = m keys upd5 (Z E (fromList [("codigo",A3 1016),("vendedor",A3 1005)]) E)
upd7 = m keys upd6 (Z E (fromList [("codigo",A3 1017),("vendedor",A3 1006)]) E)
upd8 = m keys upd7 (Z E (fromList [("codigo",A3 1018),("vendedor",A3 1006)]) E)
upd9 = m keys upd8 (Z E (fromList [("codigo",A3 1005),("vendedor",A3 1006)]) E)
upd10 = m keys upd9 (Z E (fromList [("codigo",A3 1001),("vendedor",A3 1005)]) E)