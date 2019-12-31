module DdlFunctions where
import System.Environment
import Prelude hiding (catch,lookup)
import System.Directory
import Control.Exception
import System.IO.Error hiding (catch)
import AST (BaseName,CArgs (..),TableInf,Type,Env(..),TableDescript(..),Args,UserInfo(..),
            Reference,ForeignKey,Tab,fields,fields2,fields3,createRegister,RefOption(..),printTable,show3)
import DynGhc (compile)
import Data.HashMap.Strict (fromList,HashMap,(!),update,lookup,alter,union,adjust)
import Error (errorCreateTableKeyOrFK,tableExists,errorDropTable,succesDropTable,
              errorCreateReference,succesCreateTable,succesCreateReference,
              errorCheckReference,put,imposibleDelete,errorCreateTableNulls, tableDoesntExist,syspath,
              baseExist,baseNotExist,tablepath)
import Url
import Avl ((|||),toTree,deleteT,c2,write,c,isMember,AVL,value,filterT,search,push)
import DynGhc (appendLine,reWrite)
import Data.List (elem)
import DynGhc (obtainTable,loadInfoTable)
import Data.Maybe (isNothing,fromJust,isJust)
import COrdering  (COrdering (..),fstByCC)
import Check (checkReference, checkNullifies)
import qualified Data.Set as Set (fromList,isSubsetOf)
import Control.DeepSeq

code :: String -> TableInf -> String
code f (n,t,h,k,_) =   "module " ++ f ++ " where \n" ++
                       "import AST (Args (..),Type(..),TableDescript(..),Date(..),Time(..),DateTime(..))\n" ++
                       "import Data.Typeable\n" ++
                       "import Data.HashMap.Strict hiding (keys) \n" ++
                       "import Avl (AVL(..),m)\n" ++
                       "import COrdering\n" ++
                       "keys = " ++ (show k) ++ "\n\n" ++
                       "upd0 = E"



deleteFile :: FilePath -> IO ()
deleteFile e = removeFile e `catch` handleExists
  where handleExists e
          | isDoesNotExistError e = error "No existe el archivo"
          | otherwise = throwIO e



createDataBase :: BaseName -> Env -> IO ()
createDataBase b e = case name e of
                        "" -> put "Primero logueate"
                        n -> do res <- obtainTable syspath "Users" :: IO(Maybe (AVL (HashMap String UserInfo)))
                                case res of
                                     Nothing -> put "Error fatal"
                                     Just t -> let r = fromList [("userName",UN n)]
                                               in  case search ["userName"] r t of
                                                      Nothing -> put "Error fatal"
                                                      Just reg -> let (UB bases) = reg ! "dataBases"
                                                                     -- Si ya existe la base devolver un error
                                                                  in if elem b bases then baseExist b
                                                                     -- Sino agregar
                                                                     else let reg' = adjust (\_ -> UB $ b:bases) "dataBases" reg
                                                                              -- Reemplazar info vieja con info nueva
                                                                              t' = push (fun reg') reg' t
                                                                          in do reWrite t' (syspath ++ "/Users")
                                                                                createDirectory (url n b)






dropDataBase :: BaseName -> Env -> IO ()
dropDataBase b e = case name e of
                      "" -> put "No estás logueado"
                      n -> do res <- obtainTable syspath "Users"
                              case res of
                               Nothing -> put "Error fatal1"
                               Just t -> let r = fromList [("userName",UN n)]
                                         in  case search ["userName"] r t of
                                              Nothing -> put "Error fatal2"
                                              Just reg -> let (UB bases) = reg ! "dataBases"
                                                           -- Si ya existe la base devolver un error
                                                          in if not $ elem b bases then baseNotExist b
                                                             else let reg' = adjust (\_ -> UB $ [x | x <- bases, x /= b]) "dataBases" reg
                                                                    -- Reemplazar info vieja con info nueva
                                                                      t' = push (fun reg') reg' t
                                                                  in do reWrite t' (syspath ++ "/Users")
                                                                        res2 <- obtainTable syspath "Tables"
                                                                        case res2 of
                                                                         Nothing -> put "Error fatal3"
                                                                         Just t2 -> do let t2' = filterT fun2 t2
                                                                                       reWrite t2' (syspath ++ "/Tables")
                                                                                       removeDirectoryRecursive (url (name e) b)

 where fun2 x = let (TB b') = x ! "dataBase"
                in b /= b'


fun reg x = fstByCC (\z1 z2 -> c2 ["userName"] z1 z2 ) reg x



createTable :: Env -> String -> [CArgs]  -> IO ()
createTable e n c =
 do res <- obtainTable syspath "Tables" :: IO (Maybe (AVL (HashMap String TableDescript)))
    case res of
      Nothing -> putStrLn "Error Fatal al crear tabla"
      Just t -> do let reg = createRegister e n
                    -- Existe alguna tabla?
                   if isMember fields reg t then tableExists n
                   else do let (q@(scheme,types,nulls,k,fk),r) = collect c ||| url' e n
                           let setFKNulls = toSet [x | (_,xs,s1,s2) <- fk,(x,_) <- xs,s1 == Nullifies || s2 == Nullifies ]
                           let setNulls = toSet nulls
                           let setScheme = toSet scheme
                           let setKey = toSet k
                           let setFKFields = toSet [x | (_,xs,_,_) <- fk,(x,_) <- xs]
                           -- La clave y la clave foránea son parte del esquema?
                           if isSubset setKey setNulls || (not $ isSubset setFKNulls setNulls) then errorCreateTableNulls
                           else if k == [] || (not $ isSubset setKey setScheme) || ( not $ isSubset setFKFields  setScheme) then errorCreateTableKeyOrFK
                                 else do b <- checkReference e fk (fromList $ zip scheme types) --- Chequeos de seguridad
                                         if not b  then errorCheckReference
                                         else do d1 <- createReference n e fk
                                                 let hs = r ++ ".hs"
                                                 d2 <- d1 `deepseq` writeFile hs $ code n q
                                                 d2 `deepseq` compile hs
                                                 removeFile $ r ++ ".hi"
                                                 let t' = tree reg [TS scheme,TT types,TK k,TFK (splitFK fk), TR [],HN nulls]
                                                 d3 <- appendLine tablepath t'
                                                 d3 `deepseq` succesCreateTable n





  where tree reg l = toTree [union reg (fromList $ zip (drop 3 fields2) l)]
        splitFK f = [(x,xs) | (x,xs,_,_) <- f]
        isSubset = Set.isSubsetOf
        toSet = Set.fromList






-- Crear referencias
createReference :: String -> Env -> ForeignKey -> IO ()
createReference _ _ [] = return ()
createReference n e ((x,xs,o1,o2):ys) =
  do res <- obtainTable syspath "Tables"
     case res of
      Nothing -> error "Error Fatal"
      Just t ->  do let reg = createRegister e  x
                    -- Reemplaza en el árbol t el registro correspondiente
                    let t' = write  (fun (n,o1,o2) fields reg) t
                    reWrite t' tablepath
                    succesCreateReference n x
                    createReference n e ys

  where -- Función para actualizar el registro correspondiente en la tabla referenciada
        fun m k r1 r2  = case c k r1 r2 of
                            Eq y -> let f (TR l) = Just $ TR $ m:l
                                        in Eq $ update f "refBy" y
                            y -> y








dropTable :: Env -> String -> IO ()
dropTable e n = do res <- obtainTable tablepath "Tables"
                   case res of
                     Nothing -> putStrLn "Error fatal"
                     Just t -> do inf <- loadInfoTable ["refBy","fkey"] e n
                                  case inf of
                                    [] -> tableDoesntExist
                                    [TR refBy, TFK fkey] -> -- Si existen tablas que hagan referencia a n no se puede eliminar
                                                            if refBy /= [] then imposibleDelete n [x | (x,_,_) <- refBy]
                                                            else dropTable' [x | (x,_) <- fkey] e n t

 where
  -- segundo nivel de dropTable
  dropTable' l e n t  =
              do t' <- removeReferences e t n l
                 let reg = createRegister e n
                 case deleteT  (c2 fields reg) t' of
                   Nothing -> putStrLn $ errorDropTable n
                   Just t'' -> do reWrite t'' tablepath
                                  let r = url' e n
                                  deleteFile $ r ++ ".hs"
                                  deleteFile $ r ++ ".o"
                                  succesDropTable n


-- Elimina todas las referencias hechas por la tabla n
removeReferences :: Env -> AVL (HashMap String TableDescript) -> String -> [String] -> IO(AVL (HashMap String TableDescript))
removeReferences _ t _ [] = return t
removeReferences e t n (x:xs) = let reg = fromList $ zip fields [TO (name e), TB (dataBase e), TN x]
                                    t' = write (find n reg) t
                                in removeReferences e t' n xs

          -- Se elimina la tabla n de la lista de referencias de la tabla x
    where find x r1 r2 = case c fields r1 r2 of
                        Eq _ -> Eq (change x r2)
                        other -> other
          -- modificar lista en hashmap de r2
          change x r2 = alter (change' x) "refBy" r2
          change' x (Just (TR l)) = Just $ TR [(a,b,c) | (a,b,c) <- l, a /= x]


-- Procesa las columnas para separar la información pertinente
collect :: [CArgs] -> TableInf
collect [] = ([],[],[],[],[])
collect((Col n t hn):xs) = let (l1,l2,l3,k,fk) = collect xs
                          in -- Chequear si la columna admite nulos
                             if hn then (n:l1,t:l2,n:l3,k,fk)
                             else (n:l1,t:l2,l3,k,fk)
collect ((PKey s):xs) = let (l1,l2,l3,k,fk) = collect xs
                        in (l1,l2,l3,s++k,fk)
collect ((FKey xs s ys o1 o2):rs) = let (l1,l2,l3,k,fk) = collect rs
                                    in (l1,l2,l3,k,(s,zip xs ys,o1,o2):fk)


-- Mostrar todas las tablas correspondientes a la actual base de datos
showTable :: Env -> IO()
showTable e = do res <- obtainTable syspath "Tables"  :: IO (Maybe (AVL (HashMap String TableDescript)))
                 case res of
                  Nothing -> putStrLn "Error fatal"
                  Just t -> do let fields = ["owner","dataBase"]
                               let reg = fromList $ zip fields  [TO (name e), TB (dataBase e)]
                               let t' = filterT (aux fields reg) t
                               printTable show3 ["tableName"] t'


   where aux fields r1 r2   = case c fields r1 r2 of
                                Eq _ -> True
                                _ -> False
