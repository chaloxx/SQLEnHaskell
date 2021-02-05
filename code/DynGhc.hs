{-# LANGUAGE MagicHash, UnboxedTuples #-}
module DynGhc where
import GHC.Exts         ( addrToAny# )
import GHC.Ptr          ( Ptr(..) )
import System.Info      ( os, arch )
import Encoding
import GHCi.ObjLink
import Data.Typeable (TypeRep)
import GHC.Paths
import AST (Symbol,Args(..),Env(..),createInfoRegister2,fields,TableInfo(..),Query(..),fromIO,Context)
import qualified GHC
import Data.Maybe
import Avl
import Data.HashMap.Strict hiding (foldr,map)
import System.IO
import Control.DeepSeq
import Data.Char
import Error (put,syspath,tableDoesntExist)
import Prelude hiding (lookup)
import qualified System.Plugins.Load as Sys
import System.Directory




loadInfoTable :: [String] -> Env -> String -> Query [TableInfo]
loadInfoTable s e m = do t <- obtainTable syspath "Tables"
                         let reg = createInfoRegister2 e m
                         case search fields reg t of
                            Nothing -> tableDoesntExist
                            Just reg' -> return $ map  (\x -> reg' ! x) s





appendLine ::Show a => FilePath -> AVL (HashMap String a) -> IO ()
appendLine _ E = return ()
appendLine r t = do l <- obtainLastLine (r++".hs")
                    n <- obtainN l ""
                    s <- appendFile (r ++ ".hs") (upd n t)
                    s `deepseq` reCompile r


     where    upd n t   = "\nupd" ++ (show (n+1)) ++ " = " ++
                          "m " ++ "keys " ++  "upd" ++ (show n) ++
                          " (" ++ (show t) ++ ")"









obtainLastLine :: FilePath -> IO (String)
obtainLastLine r = do h <- openFile r ReadMode
                      obtainLastLine' h
 where obtainLastLine' h = do t <- hGetLine h
                              b <- hIsEOF h
                              case b of
                                 True -> do s <- hClose h
                                            s `deepseq` return t
                                 False -> obtainLastLine' h





iter :: Handle -> Int ->  IO ([String])
iter h 0 = return []
iter h n = do l <- hGetLine h
              ls <- iter h (n-1)
              return(l:ls)




-- Reescribir fuente
reWrite :: Show a => AVL (HashMap String a ) -> FilePath -> IO ()
reWrite t r   = do h <- openFile (r ++ ".hs") ReadMode
                   l <- iter h 8
                   s <- hClose h
                   let l' = if isEmpty t then l
                            else l ++ ["upd1 = m keys upd0 " ++ "(" ++ (show t) ++ ")"]
                   l <- s `deepseq`  writeFile (r ++ ".hs") $ foldr (\x y -> x ++ "\n" ++ y) "" l'
                   l `deepseq` reCompile r


obtainTable :: FilePath -> String -> Query (AVL (HashMap String a))
obtainTable r m = Q (\c -> do l <- obtainLastLine $ r++m++".hs"
                              n <- obtainN l ""
                              load c r m ("upd" ++ show n))




obtainN :: String ->String -> IO (Int)
obtainN ('u':'p':'d':xs) r = obtainN xs ""
obtainN (x:xs) r | isDigit x = obtainN xs (r ++ [x])
                 | otherwise = return (read r :: Int)



load :: Context -> FilePath -> String -> Symbol ->  IO (Either String (Context,(AVL (HashMap String a))))
load c r m f  = do res <- load' r m  f
                   return $ case res of
                             Nothing -> Left "Algo Hizo"
                             Just t -> Right (c, t)


load' :: FilePath -> String -> Symbol ->  IO (Maybe a)
load'  r m f =  do  let path = r ++ m ++ ".o"
                    compile $ r ++ m ++ ".hs"
                    initObjLinker(DontRetainCAFs)
                    loadObj path
                    resolveObjs
                    ptr <- lookupSymbol (mangleSymbol Nothing m f)
                    unloadObj path
                    return $ case ptr of
                                 Nothing -> Nothing
                                 Just (Ptr addr) -> case addrToAny# addr of
                                                    (# t #) -> Just t





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
