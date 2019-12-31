module UserFunctions where
import qualified Data.HashMap.Strict as H
import AST (Env(..),UserInfo(..))
import Avl (toTree,isMember,filterT,c)
import System.Directory (createDirectory,removeDirectoryRecursive,doesDirectoryExist)
import DynGhc (appendLine,obtainTable,reWrite)
import Error (userpath,syspath,logError,welcome,nameAlreadyExist,invalidData)
import COrdering
-- Este modulo provee funciones para la administración de usuarios (crear, borrar, seleccionar)

userFields = ["userName","pass"]


createUser :: String -> String -> IO ()
createUser u p   = case u == "" || p == "" of
                     True -> invalidData
                     False-> do res <- obtainTable syspath "Users"
                                case res of
                                  Nothing -> putStrLn "Error fatal"
                                  Just t -> do let k = userFields !! 0
                                                   m = H.fromList [(k,u)]
                                               if isMember [k] m t then nameAlreadyExist u -- El nombre ya existe?
                                               else do createDirectory ("DataBase/"++u)
                                                       let t' = toTree $ [H.fromList $ zip (userFields ++ ["dataBases"]) [UN u,UP p,UB []]]
                                                       appendLine userpath t'




selectUser :: String -> String -> String -> IO (Env)
selectUser s u p = if u == "" || p == "" then logError u s
                   else do res <- obtainTable syspath "Users"
                           case res of
                            Nothing -> error ""
                            Just t -> do let m = H.fromList $ zip userFields [UN u,UP p]
                                         if isMember userFields m t then welcome u s
                                         else  logError u s


deleteUser :: String -> String ->  IO ()
deleteUser u p = case u == "" || p == "" of
                  True -> invalidData
                  False -> do res <- obtainTable userpath "Users"
                              case res of
                               Nothing -> putStrLn "Error fatal"
                               Just t -> do let k = userFields !! 0
                                            let m = H.fromList [(k,u)]
                                            let t' = filterT (aux [k] m) t
                                            reWrite t' userpath
                                            let path = "DataBase/" ++ u
                                            b <- doesDirectoryExist path
                                            if b then removeDirectoryRecursive path
                                            else return ()

       where aux k m x = case c k m x of
                           Eq _ -> False
                           _ -> True