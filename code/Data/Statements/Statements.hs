module Statements where


import Control.Monad.Trans.Class
import Control.Monad (liftM)





newtype EitherT m a = EitherT { runEitherT :: m (Either String   a) }



instance Functor (EitherT m) where


instance (Functor m, Monad m) => Applicative (EitherT m) where
    pure = EitherT . return . Right
    mf <*> mx = EitherT $ do
        mb_f <- runEitherT mf
        case mb_f of
            Left e -> return $ Left e
            Right f  -> do
                mb_x <- runEitherT mx
                case mb_x of
                     Left e2 -> return $ Left e2
                     Right v2  -> return $ Right (f v2)
    m *> k = m >>= \_ -> k

instance MonadTrans EitherT where
    lift = EitherT . liftM Right


instance (Monad m) => Monad (EitherT m) where
    return = lift . return
    x >>= f = EitherT $ do
        v <- runEitherT x
        case v of
            Left e -> return $ Left e
            Right v -> runEitherT (f v)


readUser :: EitherT IO String
readUser = EitherT $ do str <- getLine
                        if length str > 5 then return $ Right  str
                        else return $ Left "Error"



main = do maybeCreds <- runEitherT readUser
          case maybeCreds of
           Left m -> putStrLn m
           Right input -> putStrLn input
