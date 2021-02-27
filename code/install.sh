

# cabal update
# cabal install ghc
# cabal install ghc-paths
# cabal install readline
# cabal install terminal-size1

# cd Data/COrdering/
# cabal init -n
# cabal configure
# cabal install
# cd ../..

cd Data/Avl/
cabal init -n
cabal configure
cabal install
cd ../..

cd Data/AST/
cabal init -n
cabal configure
cabal install
cd ../..

ghc DataBase/system/Tables.hs
ghc DataBase/system/Users.hs
