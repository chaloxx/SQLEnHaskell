module Run where
import SqlParse (sqlParse)
import AST
import DdlFunctions (createTable,dropTable,showTable,createDataBase,dropDataBase,dropAllTable)
import DmlFunctions
import Url
import Control.Exception
import Data.List (isSuffixOf,dropWhileEnd,nub,sort)
import Error (errorSource,errorOpen,errorSelUser,errorSelBase,put,retFail,retMsg)
import UserFunctions
import DynGhc (appendLine)
import qualified Data.HashMap.Strict as H
import System.Directory (doesDirectoryExist,doesFileExist,listDirectory)


-- Parsear comando
parseCmd :: Env ->  String -> IO (Env)
parseCmd e s = case sqlParse s of
                Failed msg -> do putStrLn $ (source e) ++ ":" ++ msg
                                 return e
                Ok cmd -> do res <- unWrapperQuery e $ runSql cmd
                             case res of
                                Left msg  -> do put msg
                                                return e
                                Right e'  -> return e'


-- Ejecutar comando
runSql :: SQL -> Query Env
runSql (S1 cmd) = do runDml cmd
                     askEnv
runSql (S2 cmd) = do runDdl cmd
                     askEnv
runSql (S3 cmd) = do runManUser cmd
                     askEnv
runSql (Seq cmd1 cmd2) = do runSql cmd1
                            runSql cmd2
runSql (Source p) =  Q(\c ->   let e = fst' c in
                               if ".sql" `isSuffixOf` p then do read e p c `catch` exception p
                               else return $ Left "No es .sql")
 where read e p c = do s <- readFile p
                       let s' = process s
                       e' <- parseCmd e s'
                       return $ Right (c,e')


       exception p r = do let err = show (r :: IOException)
                          return  $ Left $ "Error al leer el archivo " ++ p ++":"++ err
       -- Eliminar saltos de linea y espacios iniciales y finales
       process s = let s' =  dropWhileEnd f s in
                             dropWhile f s'
       f x = x == '\n' || x == ' '






-- Ejecutar funciones de administración de usuarios
runManUser :: ManUsers ->  Query ()
runManUser (CUser u p) = fromIO $ createUser u p

runManUser (SUser u p) = do  env <- askEnv
                             fromIO $ selectUser (source env) u p

runManUser (DUser u p) = fromIO $ deleteUser u p




-- Ejecuta un comando DDL
runDdl ::  DDL -> Query Env
runDdl cmd = do e <- askEnv
                if checkSelectUser e then do runDdl1 e cmd
                else  do fromIO $ putStrLn errorSelUser
                         return e

runDdl1 e cmd = case cmd of
  (CBase b) -> do fromIO $ createDataBase b e
                  return e
  (DBase b) -> do fromIO $ dropDataBase b e
                  return e
  (DTable t) -> runDdl2 e $ dropTable e t
  (DAllTable) -> runDdl2 e $ dropAllTable e
  (CTable n c) -> runDdl2 e $  createTable e n c
  (Use b) -> do let e' = e {dataBase=b}
                v <- fromIO $ doesDirectoryExist $ url e
                if v then do fromIO $ putStrLn $ "Usando la base " ++ b
                             return e'
                else retFail $ "La base " ++ b ++ " no existe"


  (ShowB) -> retMsg $ "DataBase/" ++ (name e)


  (ShowT) -> do fromIO $ showTable e
                return e

  where quitComa "" = ""
        quitComa (x:xs) = xs

runDdl2 e f = do if checkSelectBase e then do fromIO f
                                              askEnv

                 else retFail errorSelBase





-- Ejecuta un comando DML chequeando que previamente
-- se halla seleccionado una base o tabla válida
runDml :: DML -> Query ()
runDml dml = do env <- askEnv
                let (b1,b2) = (checkSelectBase env ,checkSelectUser env)
                if b1 && b2 then runDml2 dml
                else do if b1 then retFail errorSelUser
                        else retFail errorSelBase


runDml2 :: DML -> Query ()
runDml2 (Insert m t) = insert  m t

runDml2 (Delete m exp) = delete m exp
runDml2 (Update m v exp) = update m v exp
runDml2 q = do  (ys,t) <- runQuery q
                fromIO $ printTable show2 ys t




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



-- Lista las tablas en un ruta data
printDirectory :: FilePath -> IO ()
printDirectory p = do l <- listDirectory p
                      let l' = sort $ nub $ map quitExtension l
                      sequence_ (map putStrLn l' )
  where quitExtension s = takeWhile (\x -> x /= '.') s
