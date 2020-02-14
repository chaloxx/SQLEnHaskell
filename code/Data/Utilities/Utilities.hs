module Utilities where

import AST
import qualified Data.HashMap.Strict as HM  (HashMap (..),insert,delete,empty,update,fromList,(!),mapWithKey,keys,map,lookup)
import Avl (AVL(..),mapT,pushL,join,value,left,right,emptyT)
import Data.Hashable
import System.Console.Terminal.Size  (size,width)
import Data.List.Split





-- Algunas definiciones útiles


instance (Ord a, Ord v) => Ord (HM.HashMap a v) where
     t1 <= t2 = t1 == t2 || t1 < t2



filterL = filter
insertHM :: (Eq k, Hashable k) => k -> v -> HM.HashMap k v -> HM.HashMap k v
insertHM = HM.insert
deleteHM :: (Eq k, Hashable k) => k -> HM.HashMap k v -> HM.HashMap k v
deleteHM = HM.delete
emptyHM :: HM.HashMap k v
emptyHM = HM.empty
updateHM:: (Eq k, Hashable k) => (a -> Maybe a) -> k -> HM.HashMap k a -> HM.HashMap k a
updateHM = HM.update
mapHM :: (v1 -> v2) -> HM.HashMap k v1 -> HM.HashMap k v2
mapHM = HM.map


fst' :: (a,b,c) -> a
fst' (x,_,_) = x


snd' :: (a,b,c) -> b
snd' (_,y,_) = y

trd' :: (a,b,c) -> c
trd' (x,y,z) = z


isInt :: RealFrac b => b -> Bool
isInt x = x - fromInteger(round x) == 0


fields = ["owner", "dataBase","tableName"]
fields2 = fields ++ ["scheme","types","key","fkey","refBy","haveNull"]
fields3 = fields ++ ["referencedBy"]

belong :: Eq a => [a] -> a -> Bool
belong [] _ = False
belong (x:xs) y = if x == y then True
                  else belong xs y

createRegister :: Env -> String -> HM.HashMap String TableInfo
createRegister e n =  HM.fromList $ zip fields [TO (name e), TB (dataBase e),TN n]



printTable :: Show v => (v -> String) -> [String] -> AVL (HM.HashMap String v) -> IO ()
printTable print s t =
  do r <- size
     case r of
       Nothing -> error ""
       Just w -> do putStrLn $ line $ width w
                    putStrLn  $ fold s
                    putStrLn $ line $ width w
                    sequence_ $ mapT (\ x -> putStrLn $ fold $ map (f' x) s) t
 where fold s = txt 0 s 30
       f x y = x ++ "|" ++ y
       f' x v =  print $ x HM.! v
       txt _ [] _ = ""
       txt 0 (x:xs) n  = "|" ++ x ++  txt (n - length x) xs n
       txt c v n = " " ++ txt (c-1) v n
       line 0 = ""
       line n = '-': (line (n-1))


isAgg (A2 _) = True
isAgg (As e1 _) = isAgg e1
isAgg _ = False

min3 :: Float -> Float -> Float -> Float
min3 v1 v2 v3 =  min v3 (min v1 v2)

max3 :: Float -> Float -> Float -> Float
max3 v1 v2 v3 = max v3 (max v1 v2)

toFloat :: Args -> Float
toFloat (A3 n) = fromIntegral n
toFloat (A4 n) = n


retHeadOrNull :: [AVL a] -> AVL a
retHeadOrNull [] = emptyT
retHeadOrNull tables = head tables


-- Obtener un HM con los campos de cada tabla
giveMeOnlyFields :: HM.HashMap a (HM.HashMap b c) -> HM.HashMap a [b]
giveMeOnlyFields hm = HM.mapWithKey (\k -> \v -> HM.keys v) hm

split s = case splitOn "." s of
            [a] -> Field a
            [a,b] -> Dot a b

typeOfArgs :: Args -> Type
typeOfArgs (A1 _) = String
typeOfArgs (A3 _) = Int
typeOfArgs (A4 _) = Float
typeOfArgs (A5 _) = Datetime
typeOfArgs (A6 _) = Dates
typeOfArgs (A7 _) = Tim



posInf :: Float
posInf = 1/0

negInf :: Float
negInf = - 1/0



exitToInsert :: [Args] -> Either String String
exitToInsert s = return $  (fold s) ++ " se inserto correctamente"

-- Convertir agumentos en un string
fold :: [Args] -> String
fold s = tail $ fold' $ map show2 s
fold' = foldl (\ x y -> x ++ "," ++ y) ""



-- Realiza una busqueda en g a partir de una lista de tablas y un atributo  v
lookupList ::Show b => HM.HashMap String (HM.HashMap String b) -> TableNames -> FieldName -> Either String b
lookupList _ [] v = Left $ "No se pudo encontrar " ++ v
lookupList g q@(y:ys) v = case HM.lookup y g of
                           Nothing -> error $ "No encontré " ++ v
                           Just r -> case HM.lookup v r of
                                      Nothing -> lookupList g ys v
                                      Just x' -> return x'

-- Unir 2 listas, sin elementos comunes en ambas
unionL :: Eq e => [e] -> [e] -> [e]
unionL [] l = l
unionL (x:xs) l = if x `elem` l then unionL xs l
                  else unionL xs (x:l)

-- Determina si una lista de atributos pertenece al contexto g
inContext ::Show b => HM.HashMap String (HM.HashMap String b) -> TableNames -> FieldNames -> Either String [Args]
inContext _ _ [] = True
inContext g s (x:xs) = if isNothing $ lookupList g s x then False
                       else




syspath = "DataBase/system/"
userpath = syspath++"Users"
tablepath = syspath++"Tables"
