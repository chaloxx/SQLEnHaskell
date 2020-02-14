module UserFunctions where
import qualified Data.HashMap.Strict as H
import AST (Env(..),UserInfo(..),UserName,TableInfo(..))
import Patterns ((////),(|||))
import Avl (toTree,isMember,filterT,compareCOrd,AVL)
import System.Directory (createDirectory,removeDirectoryRecursive,doesDirectoryExist)
import DynGhc (appendLine,obtainTable,reWrite)
import Error (logError,welcome,userAlreadyExist,invalidData,put)
import COrdering
import Utilities  (userpath,syspath,tablepath)
-- Este modulo provee funciones para la administración de usuarios (crear, borrar, seleccionar)


-- Crear usuario
createUser :: UserName -> IO ()
createUser u    = case u == "" of
                    True -> invalidData
                    False-> do res <- obtainTable syspath "Users"
                               case res of
                                  Nothing -> put "Error fatal"
                                  Just t -> do let k = "userName"
                                                   m = H.fromList [(k,UN u)]
                                               if isMember [k] m t then userAlreadyExist u -- El nombre ya existe?
                                               else do createDirectory ("DataBase/"++u)
                                                       let t' = toTree $ [H.fromList $ zip ([k,"dataBases"]) [UN u,UB []]]
                                                       appendLine userpath t'



-- Seleccionar usuario
selectUser :: FilePath -> UserName -> IO (Env)
selectUser s u = if u == ""  then do logError u
                                     return (Env "" "" s)
                 else do res <- obtainTable syspath "Users"
                         case res of
                            Nothing -> error ""
                            Just t -> do let  k = "userName"
                                              m = H.fromList $ [("userName",UN u)]
                                         if isMember [k] m t then do welcome u
                                                                     return (Env u "" s)
                                         else do logError u
                                                 return (Env "" "" s)



deleteUser :: Env -> UserName ->  IO (Env)
deleteUser e u = case u == "" of
                  True -> do invalidData
                             return e
                  False -> do res <- obtainTable syspath "Users" :: IO(Maybe (AVL (H.HashMap String UserInfo)))
                              case res of
                               Nothing -> do put "Error fatal"
                                             return e
                               Just t -> do let k = "userName"
                                            let m = H.fromList [(k,UN u)]
                                            if not $ isMember [k] m t then do logError u
                                                                              return e
                                            else do res2 <- obtainTable syspath "Tables" :: IO (Maybe (AVL(H.HashMap String TableInfo)))
                                                    case res2 of
                                                       Nothing -> do put "Error fatal"
                                                                     return e
                                                       Just t2 -> do  let k' = "owner"
                                                                          m' = H.fromList [("owner", TO u)]
                                                                          (t2',t') = filterT (filtro [k'] m') t2 ||| filterT (filtro [k] m) t
                                                                          path = "DataBase/" ++ u
                                                                      reWrite t2' tablepath  //// reWrite t' userpath
                                                                      b <- doesDirectoryExist path
                                                                      if b then do removeDirectoryRecursive path
                                                                                   if (name e) == u then return $ Env "" "" ""
                                                                                   else return e
                                                                      else do put "Error fatal"
                                                                              return e


       where filtro k m x = case compareCOrd k m x of
                           Eq _ -> False
                           _ -> True
