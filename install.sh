

cabal update
cabal install ghc-8.6.5
cabal install ghc-paths-0.1.0.12
cabal install readline-1.0.3.0
cabal install terminal-size-0.3.2.1
cabal install hashable-1.2.7.0
cabal install haskeline-0.7.4.3
cabal install split-0.2.3.3
cabal install terminfo-0.4.1.2
cabal install Unique-0.4.7.8
cabal install plugins-1.6.1
cabal install time-1.11.1.1

cd Data/COrdering/
touch LICENSE
cabal init -n
cabal configure
cabal install
cd ../..

cd Data/Avl/
touch LICENSE
cabal init -n
cabal configure
cabal install
cd ../..

cd Data/AST/
touch LICENSE
cabal init -n
cabal configure
cabal install
cd ../..

ghc DataBase/system/Tables.hs
ghc DataBase/system/Users.hs
ghc -package ghc -rdynamic Init.hs
