{-# LANGUAGE MagicHash, UnboxedTuples #-}
module DynGhc where
import GHC.Exts         ( addrToAny# )
import GHC.Ptr          ( Ptr(..) )
import System.Info      ( os, arch )
import Encoding
import GHCi.ObjLink
import Data.Typeable (TypeRep)
import GHC.Paths
import AST (Symbol,Args(..),Env(..),TableInfo(..),TableName,FieldNames,UserName,UserInfo(..))
import Utilities (createRegister,fields,syspath)
import qualified GHC
import Data.Maybe
import Avl
import Data.HashMap.Strict hiding (foldr,map)
import System.IO
import Control.DeepSeq
import Data.Char
import Error (put)
import Prelude hiding (lookup)
import qualified System.Plugins.Load as Sys
import System.Directory

-- Dado un entorno y el nombre de una tabla determina si esta existe
existTable :: Env -> String -> IO (Bool)
existTable e n = do res <- obtainTable syspath "Tables"
                    case res of
                      Nothing -> do put "Error fatal"
                                    return False
                      Just t -> let k = ["owner","dataBase","tableName"]
                                    reg = fromList $ zip k [TO $ name e,TB $ dataBase e,TN $ n]
                                in return $ isMember k reg t



-- Carga la información solicitada en s
loadInfoTable :: FieldNames -> Env -> TableName -> IO([TableInfo])
loadInfoTable s e m = do res <- obtainTable syspath "Tables"
                         case res of
                          Nothing -> return []
                          Just t -> do let reg = createRegister e m
                                       case search fields reg t of
                                        Nothing -> return []
                                        Just reg' -> return $ map  (\x -> reg' ! x) s


loadInfoUser :: UserName -> IO([UserInfo])
loadInfoUser u   = do res <- obtainTable syspath "Users"
                      case res of
                       Nothing -> return []
                       Just t -> do let k = "userName"
                                        reg = singleton k (UN u)
                                    case search [k] reg t of
                                      Nothing -> return []
                                      Just reg' -> return [UN u, reg' ! "dataBases"]




appendLine ::Show a => FilePath -> AVL (HashMap String a) -> IO ()
appendLine _ E = return ()
appendLine r t = do l <- obtainLastLine (r++".hs")
                    n <- obtainN l ""
                    s <- appendFile (r ++ ".hs") (upd n t)
                    s `deepseq` reCompile r


     where    upd n t   = "\nupd" ++ (show (n+1)) ++ " = " ++
                          "m " ++ "keys " ++  "upd" ++ (show n) ++
                          " (" ++ (show t) ++ ")"








-- Obtener el código de actualización más reciente
obtainLastLine :: FilePath ->  IO (String)
obtainLastLine r = do h <- openFile r ReadMode
                      obtainLastLine' h
 where obtainLastLine' h = do t <- hGetLine h
                              b <- hIsEOF h
                              case b of
                                 True -> do s <- hClose h
                                            s `deepseq` return t
                                 False -> obtainLastLine' h





iter :: Handle -> Int ->  IO (String)
iter h 0 = return ""
iter h n = do l <- hGetLine h
              ls <- iter h (n-1)
              return (l ++ "\n" ++ ls)




-- Reescribir fuente
reWrite :: Show a => AVL (HashMap String a ) -> FilePath -> IO ()
reWrite t r   = do h <- openFile (r ++ ".hs") ReadMode
                   l <- iter h 8
                   let l' = if isEmpty t then l
                            else l ++ "upd1 = m keys upd0 " ++ "(" ++ (show t) ++ ")\n"
                   s <- hClose h
                   x <- s `deepseq` writeFile (r ++ ".hs") l'
                   x `deepseq` reCompile r



-- Obtiene la tabla m alojada en la ruta r
obtainTable :: FilePath -> String -> IO(Maybe (AVL (HashMap String a)))
obtainTable r m = do l <- obtainLastLine $ r++m++".hs"
                     n <- obtainN l ""
                     load r m ("upd" ++ show n)


-- Obtener código de la última actualización
obtainN :: String ->String -> IO (Int)
obtainN ('u':'p':'d':xs) r = obtainN xs ""
obtainN (x:xs) r | isDigit x = obtainN xs (r ++ [x])
                 | otherwise = return (read r :: Int)


-- Cargar la tabla como una estructura conocida por haskell
load :: FilePath -> String -> Symbol ->  IO (Maybe a)
load r m f =  do let path = r ++ m ++ ".o"
                 initObjLinker
                 loadObj path
                 resolveObjs
                 ptr <- lookupSymbol (mangleSymbol Nothing m f)
                 unloadObj path
                 case ptr of
                    Nothing -> error f--return (Nothing)
                    Just (Ptr addr) -> case addrToAny# addr of
                                         (# t #) -> return $ Just t



mangleSymbol :: Maybe String -> String -> String -> String
mangleSymbol pkg module' valsym = prefixUnderscore ++ maybe "" (\p -> zEncodeString p ++ "_") pkg ++zEncodeString module' ++ "_" ++ zEncodeString valsym ++ "_closure"

prefixUnderscore :: String
prefixUnderscore =
  case (os,arch) of
    ("mingw32","x86_64") -> ""
    ("cygwin","x86_64") -> ""
    ("mingw32",_) -> "_"
    ("darwin",_) -> "_"
    ("cygwin",_) -> "_"
    _ -> ""

-- Recompilar actualiza el objeto
reCompile r = do v <- removeFile (r ++ ".o")
                 flag <- v `deepseq` compile (r ++ ".hs")
                 if GHC.succeeded $ flag  then putStrLn "Actualizado con exito"
                 else error "Error al cargar archivo"




compile :: FilePath -> IO (GHC.SuccessFlag)
compile r = GHC.runGhc (Just libdir) $ do
            dflags <- GHC.getSessionDynFlags
            GHC.setSessionDynFlags dflags
            target <- GHC.guessTarget r Nothing
            GHC.setTargets [target]
            GHC.load GHC.LoadAllTargets
