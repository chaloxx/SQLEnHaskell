{-# LANGUAGE CPP #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -fno-warn-implicit-prelude #-}
module Paths_Patterns (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/pablo/.cabal/bin"
libdir     = "/home/pablo/.cabal/lib/x86_64-linux-ghc-8.0.2/Patterns-0.1.0.0-BPyoqL4FikH6LKoT7Gi55"
dynlibdir  = "/home/pablo/.cabal/lib/x86_64-linux-ghc-8.0.2"
datadir    = "/home/pablo/.cabal/share/x86_64-linux-ghc-8.0.2/Patterns-0.1.0.0"
libexecdir = "/home/pablo/.cabal/libexec"
sysconfdir = "/home/pablo/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "Patterns_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "Patterns_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "Patterns_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "Patterns_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "Patterns_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "Patterns_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
