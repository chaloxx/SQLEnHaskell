module Run where
import SqlParse (sqlParse)
import AST (Env(..),DDL(..),DML(..),ManUsers(..),SQL(..),ParseResult(..))
import DdlFunctions (createTable,dropTable,showTable,createDataBase,dropDataBase,showDataBase)
import DmlFunctions
import Url
import System.TimeIt
import Control.Exception
import Data.List (isSuffixOf,dropWhileEnd,nub,sort)
import Error (errorSource,errorOpen,errorSelUser,errorSelBase,put)
import UserFunctions
import DynGhc (appendLine)
import qualified Data.HashMap.Strict as H
import System.Directory (doesDirectoryExist,doesFileExist,listDirectory)


-- Parsear comando
parseCmd :: Env ->  String -> IO (Env)
parseCmd e s = case sqlParse s of
                Failed msg -> do put $ (source e) ++ ":" ++ msg
                                 return e
                Ok cmd ->  runSql e cmd


-- Ejecutar comando
runSql :: Env -> SQL -> IO (Env)
runSql e (S1 cmd) = runDml e cmd
runSql e (S2 cmd) = runDdl e cmd
runSql e (S3 cmd) = runManUser e cmd
runSql e (Seq cmd1 cmd2) = do e' <- runSql e cmd1
                              runSql e' cmd2
runSql e (Source p) = if ".sql" `isSuffixOf` p then read (Env (name e) (dataBase e) p) p `catch` exception p e
                      else do put errorSource
                              return e

 where read e p = do s <- readFile p
                     let s' = process s
                     e' <- parseCmd e s'
                     return (Env (name e') (dataBase e') "Estándar Input")


       exception p e r = do let err = show (r :: IOException)
                            put $ errorOpen p err
                            return e
       -- Eliminar saltos de linea y espacios iniciales y finales
       process s = let s' =  dropWhileEnd f s in
                             dropWhile f s'
       f x = x == '\n' || x == ' '




-- Funciones de usuario
runManUser :: Env -> ManUsers ->  IO (Env)
runManUser e (CUser u) = do createUser u;return e
runManUser e (SUser u) = selectUser (source e) u
runManUser e (DUser u) = deleteUser e u



-- Ejecuta un comando DDL
runDdl :: Env -> DDL -> IO (Env)
runDdl e cmd = if checkSelectUser e then runDdl1 e cmd
               else  do put errorSelUser
                        return e

runDdl1 e cmd = case cmd of
  (CBase b) -> aux e $ createDataBase b e
  (DBase b) -> aux e $ dropDataBase b e
  (DTable t) -> runDdl2 e $ dropTable e t
  (CTable n c) -> runDdl2 e $  createTable e n c
  (Use b) -> do v <- doesDirectoryExist (url (name e) b)
                if v then do put $ "Usando la base " ++ b
                             return (Env (name e) b (source e))
                else do put $ "La base " ++ b ++ " no existe"
                        return e


  (ShowB) -> do showDataBase e
                return e

  (ShowT) -> do showTable e
                return e

  where quitComa "" = ""
        quitComa (x:xs) = xs
        aux e f = do f
                     return e

runDdl2 e f = do if checkSelectBase e then f
                 else put errorSelBase
                 return e




-- Ejecuta un comando DML chequeando que previamente
-- se halla seleccionado una base o tabla válida
runDml :: Env -> DML -> IO (Env)
runDml e dml = let (b1,b2) = (checkSelectBase e ,checkSelectUser e) in
               if b1 && b2 then do runDml2 e dml;return e
               else do if b1 then put  errorSelUser
                       else put errorSelBase;
                       return e


runDml2 e (Insert m t) = insert e m t
runDml2 e (Delete m exp) = delete (e,H.empty,H.empty) m exp
runDml2 e (Update m v exp) = update (e,H.empty,H.empty) m v exp
runDml2 e q = runQuery (e,H.empty,H.empty) q



-- Determina si previamente  se ha elegido una BD
checkSelectBase :: Env ->  Bool
checkSelectBase e  = case dataBase e of
                        "" -> False
                        _  -> True

-- Determina si previamente  se ha elegido un usuario
checkSelectUser :: Env -> Bool
checkSelectUser e = case name e of
                      "" -> False
                      _ -> True

checkTable :: FilePath -> IO(Bool)
checkTable r = do b <- doesFileExist (r ++ ".hs")
                  return b








-- Imprime las tablas en un ruta data
printDirectory :: FilePath -> IO ()
printDirectory p = do l <- listDirectory p
                      let l' = sort $ nub $ map quitExtension l
                      sequence_ (map put l' )
  where quitExtension s = takeWhile (\x -> x /= '.') s
