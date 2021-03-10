-- Modulo para chequeo de tipos, claves, campos nulos, claves foráneasa



module Check where

import AST (Args(..),Type(..),Tab,BoolExp(.. ),Types,Reg,ContextFun,ForeignKey,Env,RefOption(..),(////),Types
            ,show2,TableInfo(..),Key,Query(..),TableName,ErrorMsg,TableNames,lookupList)
import Error (exitToInsert,fold,typeOfArgs,errorKey,typeError,errorForeignKey,errorCheckTyped,errorCheckLength,retOk,
              ok,errorCheckNull,errorCheckForeignKey)
import Data.HashMap.Strict hiding (map)
import Avl (isMember)
import System.IO.Unsafe (unsafePerformIO)
import DynGhc (obtainTable,loadInfoTable)
import Data.Maybe (isJust,fromJust)
import Url (url')
import Data.List (sort,intersect)



-- Chequea que la cantidad de args pasados sea correcta
checkLength :: Int -> [Args] -> Either ErrorMsg ()
checkLength l types = if l == length types then return ()
                      else errorCheckLength $   (fold types)




-- Chequea que el tipo de los args pasados sea correcto
checkTyped ::  [Type] -> [Args] -> Either ErrorMsg ()
checkTyped [] (x:xs) = errorCheckTyped x
checkTyped _ [] = return ()
checkTyped ys ((Nulo):xs) = checkTyped ys xs
checkTyped (y:ys) (x:xs) = if y == (typeOfArgs x) then checkTyped ys xs
                           else errorCheckTyped x


-- Chequea si la clave del registro  ya existe en la tabla t
checkKey :: Tab -> [String] -> Reg -> [Args] -> Either ErrorMsg ()
checkKey t k r x = if isMember k r t then errorKey x
                   else return ()

--- Chequear que las referencias sean válidas
checkReference :: Env ->  ForeignKey -> HashMap String Type ->  Query Bool
checkReference _  [] _  =  return True
checkReference e  ((x,xs,o1,o2):ys) t1 = do res <- loadInfoTable ["key","types","scheme"] e x
                                            case res of
                                              [] -> return False -- Tabla no existe
                                              [TK k,TT typ,TS sch] -> let k' = map (\(_,y) -> y) xs
                                                                          t2 = fromList $ zip sch typ
                                                                      in   if checkAux1 k' k && checkAux2 t1 t2 xs then checkReference e ys t1
                                                                      else  return False

   where  -- k' debe ser subconjunto de k
         checkAux1 k' k =  (\x -> x `elem` k) `all`  k'
         -- Los tipos deben coincidir
         checkAux2 _ _ [] = True
         checkAux2 t1 t2 ((x1,x2):xs) = if (t1 ! x1) == (t2 ! x2) then checkAux2 t1 t2 xs
                                        else error "Aca entra 3"




-- Chequea que no se aplique la restricción nullifies sobre campos que no permiten nulos
checkNullifies :: [String] -> ForeignKey -> Bool
checkNullifies _ [] = error "Por aca sale"
checkNullifies nulls ((_,l,Nullifies,_):xs) = checkNullifies' nulls [x | (x,_) <- l] xs
checkNullifies nulls ((_,l,_,Nullifies):xs) = checkNullifies' nulls [x | (x,_) <- l] xs
checkNullifies nulls (x:xs) = checkNullifies nulls xs

checkNullifies' nulls l xs  = if intersect nulls l == [] then checkNullifies nulls xs
                              else False


-- Chequea que expresión sea segura comprobando los tipos de las subexpresiones
checkTypeBoolExp :: BoolExp -> [String] -> ContextFun Type -> Either String Type
checkTypeBoolExp e@(Not exp) s types = case checkTypeBoolExp exp s types of
                                        Right Bool -> return Bool
                                        _ -> typeError (show e)

checkTypeBoolExp e@(And exp1 exp2) s types = checkTypeBoolExp'' exp1 exp2 s types e
checkTypeBoolExp e@(Or exp1 exp2) s types = checkTypeBoolExp'' exp1 exp2 s types e
checkTypeBoolExp e@(Less exp1 exp2) s types = checkTypeBoolExp' exp1 exp2 s types e
checkTypeBoolExp e@(Great exp1 exp2) s types = checkTypeBoolExp' exp1 exp2 s types e
checkTypeBoolExp e@(Equal exp1 exp2) s types = checkTypeBoolExp' exp1 exp2 s types e
checkTypeBoolExp e@(NEqual exp1 exp2) s types = checkTypeBoolExp' exp1 exp2 s types e
checkTypeBoolExp e@(GEqual exp1 exp2) s types = checkTypeBoolExp' exp1 exp2 s types e
checkTypeBoolExp e@(LEqual exp1 exp2) s types = checkTypeBoolExp' exp1 exp2 s types e
checkTypeBoolExp _ _ _ = return Bool

checkTypeBoolExp'' exp1 exp2 s types e  = do (t1,t2) <- checkTypeBoolExp exp1 s types //// checkTypeBoolExp exp2 s types
                                             case t2 == Bool && t1 == Bool  of
                                              True -> return Bool
                                              False -> typeError (show e)

checkTypeBoolExp' exp1 exp2 s types e =
   do (t1,t2) <- checkTypeExp s types exp1 //// checkTypeExp s types exp2
      case t1 == t2 || (intOrFloat t1 && intOrFloat t2) of
         True -> return Bool
         False -> typeError (show e)

  where intOrFloat Int = True
        intOrFloat Float = True
        intOrFloat _ = False


checkTypedExpList :: [TableName] -> ContextFun Type -> [Args] -> Either ErrorMsg ()
checkTypedExpList _ _ [] = return ()
checkTypedExpList names types (All:xs) = checkTypedExpList names types xs
checkTypedExpList names types (arg:xs) = checkTypeExp names types arg >> checkTypedExpList names types xs

-- Chequea el tipo de un argumento (primer nivel)
checkTypeExp :: TableNames -> ContextFun Type -> Args -> Either String Type
checkTypeExp s g e@(Plus exp1 exp2) = checkTypeExp' s False g exp1 exp2 e
checkTypeExp s g e@(Minus exp1 exp2) = checkTypeExp' s False g exp1 exp2 e
checkTypeExp s g e@(Times exp1 exp2) = checkTypeExp' s False g exp1 exp2 e
checkTypeExp s g e@(Div exp1 exp2) = checkTypeExp' s True g exp1 exp2 e
checkTypeExp s g (A1 _) = return String
checkTypeExp s g (A2 _) = return Float
checkTypeExp s g (A3 _) = return Int
checkTypeExp s g (A4 _) = return Float
checkTypeExp s g (A5 _) = return Datetime
checkTypeExp s g (A6 _) = return Date
checkTypeExp s g (A7 _) = return Time
checkTypeExp s g (Field v) = lookupList g s v

checkTypeExp s g (Dot s1 s2) = lookupList g [s1] s2
checkTypeExp s g (Negate exp) = checkTypeExp s g exp
checkTypeExp s g (Brack exp) = checkTypeExp s g exp
checkTypeExp s g (As exp _) = checkTypeExp s g exp

-- (segundo nivel)
checkTypeExp' s b g exp1 exp2 e =
  do (t1,t2) <- checkTypeExp s g exp1 //// checkTypeExp s g exp2
     checkTypeExp'' t1 e >> checkTypeExp'' t2 e
     if b then return Float
     else if t1 == Float || t2 == Float then  return Float
          else return Int

-- (tercer nivel)
checkTypeExp'' Float e = ok Float
checkTypeExp'' Int e = ok Int
checkTypeExp'' _ e = typeError $ (show2 e)



-- Chequear que la clave foránea apunta a una clave existente
checkForeignKey :: Reg -> [([(String,String)],Tab,Key)] -> Either String ()
checkForeignKey _ []  = return ()
checkForeignKey r ((xs,t,key):ys)  = let k' = map (\(_,y) -> y) xs -- Obtener referencia de la clave foránea
                                         k = [w | w <- key, w `elem` k']
                                        -- Calcular un registro con los valores de la clave foránea
                                        -- Fijarse que la clave exista
                                         r' = fromList $ map (\(x,y) -> (y,r ! x)) xs
                                     in if isMember k r' t then checkForeignKey r ys
                                        else errorCheckForeignKey




-- Chequear que valores pueden ser nulos
checkNulls :: [String] -> [String] -> [Args] -> Either String ()
checkNulls [] _ _ = return ()
checkNulls (x:xs) l ((Nulo):rs) = if belong x l then checkNulls xs l rs
                                  else Left $  "No se permite que el valor de " ++ x ++ "sea nulo"
  where  belong _ [] = False
         belong s (x:xs) = if s == x then True
                           else belong s xs

checkNulls (x:xs) l (r:rs) = checkNulls xs l rs
