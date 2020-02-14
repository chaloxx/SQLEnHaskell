module Patterns where


-- Patrones de cómputo (ahorran código)
(|||) :: a -> b -> (a,b)
a ||| b = (a,b)

(||||):: (Monad m, Monad n) => m (n a) -> m (n b) -> m (n (a,b))
a |||| b = do (a', b') <- a //// b
              return $ do (a'',b'') <- a' //// b'
                          return (a'',b'')

(////) :: Monad m => m a -> m b -> m (a,b)
a //// b = do a' <- a
              b' <- b
              return (a',b')


pattern :: (Monad m, Functor n) => m (n a) -> (a -> b) -> m (n b)
pattern r f = do r' <- r
                 return $ fmap f r'

pattern2 :: IO (Either String a) -> (a -> IO (Either String b)) -> IO (Either String b)
pattern2 res f = do res' <- res
                    case res' of
                      Right v -> f v
                      Left msg -> return (Left msg)
