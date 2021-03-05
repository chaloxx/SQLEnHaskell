 {-# LANGUAGE NoMonadFailDesugaring #-}

 module Parsing where

 import Data.Char
 import Control.Monad
 import Control.Applicative hiding (many)
 import AST (DateTime(..),Date(..),Time(..),Args(..))


-- Modulo de subparsers útiles para datos específicos

 newtype Parser a              =  P (String -> [(a,String)])

 instance Functor Parser where
    fmap = liftM

 instance Applicative Parser where
    pure = return
    (<*>) = ap

 instance Monad Parser where
    return v                   =  P (\inp -> [(v,inp)])
    p >>= f                    =  P (\inp -> [ x | (v,out) <- parse p inp, x <- parse (f v) out])

 instance Alternative Parser where
    empty = mzero
    (<|>) = mplus

 instance MonadPlus Parser where
    mzero                      =  P (\_   -> [])
    p `mplus` q                =  P (\inp -> case parse p inp of
                                                []        -> parse q inp
                                                x         -> x)

-- Basic parsers
-- -------------

 failure                       :: Parser a
 failure                       =  mzero

 item                          :: Parser Char
 item                          =  P (\inp -> case inp of
                                                []     -> []
                                                (x:xs) -> [(x,xs)])

 parse                         :: Parser a -> String -> [(a,String)]
 parse (P p) inp               =  p inp

-- Derived primitives
-- ------------------

 sat                           :: (Char -> Bool) -> Parser Char
 sat p                         =  do x <- item
                                     if p x then return x else failure

 digit                         :: Parser Char
 digit                         =  sat isDigit

 lower                         :: Parser Char
 lower                         =  sat isLower

 upper                         :: Parser Char
 upper                         =  sat isUpper

 letter                        :: Parser Char
 letter                        =  sat isAlpha

 alphanum                      :: Parser Char
 alphanum                      =  sat isAlphaNum

 char                          :: Char -> Parser Char
 char x                        =  sat (== x)

 string                        :: String -> Parser String
 string []                     =  return []
 string (x:xs)                 =  do char x
                                     string xs
                                     return (x:xs)

 many                          :: Parser a -> Parser [a]
 many p                        =  many1 p <|> return []

 many1                         :: Parser a -> Parser [a]
 many1 p                       =  do v <- p
                                     vs <- many p
                                     return (v:vs)

 ident                         :: Parser String
 ident                         =  do x <- many letter
                                     return x

 nat                           :: Parser Int
 nat                           =  do xs <- many1 digit
                                     return (read xs)

 int                           :: Parser Int
 int                           =  do char '-'
                                     n <- nat
                                     return (-n)
                                   <|> nat

 pointNumber                           :: Parser Float
 pointNumber                            = do char '-'
                                             pointNumber' "-"
                                             <|> pointNumber' ""
   where pointNumber' sign  = do intPart <- many1 digit
                                 char '.'
                                 floatPart <- many1 digit
                                 let str = sign ++  intPart ++ "." ++ floatPart
                                 return $  read  str





 space                         :: Parser ()
 space                         =  do many (sat isSpace)
                                     return ()

 sepBy                         :: Parser a -> Parser sep -> Parser [a]
 sepBy p sep                   =  sepBy1 p sep <|> return []

 sepBy1                        :: Parser a -> Parser sep -> Parser [a]
 sepBy1 p sep            = do{ x <- p
                               ; xs <- many (sep >> p)
                               ; return (x:xs) }

 endBy1                        :: Parser a -> Parser sep -> Parser [a]
 endBy1 p sep                  = many1 (do { x <- p; sep; return x })

 endBy                         :: Parser a -> Parser sep -> Parser [a]
 endBy p sep                     = many (do{ x <- p; sep; return x })



-- Ignoring spacing
-- ----------------

 token                         :: Parser a -> Parser a
 token p                       =  do space
                                     v <- p
                                     space
                                     return v

 identifier                    :: Parser String
 identifier                    =  token ident

 natural                       :: Parser Int
 natural                       =  token nat

 integer                       :: Parser Int
 integer                       =  token int

 float                         :: Parser Float
 float                         =  token pointNumber


 symbol                        :: String -> Parser String
 symbol xs                     =  token (string xs)




 stringList:: Parser String
 stringList = do x <- many letter;
                 space;
                 do char ',';
                    space;
                    xs <- stringList;
                    return (x ++ "," ++ xs)
                    <|> return (x)






 string2 :: Parser String
 string2 = do space;
              x <- many (do alphanum <|> char '.' <|> char '/' <|> char '%' <|> char '_' <|> char ' ' <|> char ',' <|> char '-');
              space;
              return x

 dateTime :: Parser Args
 dateTime = do (A6 d) <- date
               space
               (A7 t) <- time
               return (A5 $ DateTime (dayD d) (monthD d) (yearD d)
                                     (tHour t) (tMinute t) (tSecond t))

 date :: Parser Args
 date = do year <- integer
           if year < 0 then failure
           else do char '-'
                   month <- integer
                   if month < 1 || month > 12 then failure
                   else do char '-'
                           day <- integer
                           if day < 1 || day > 31 then failure
                           else return $ (A6 $ Date day month year)

 time :: Parser Args
 time = do hour <- integer
           if hour < 0 || hour > 23 then failure
           else do char ':'
                   minutes <- integer
                   if minutes < 0 || minutes > 59 then failure
                   else do char ':'
                           seconds <- integer
                           if seconds < 0 || seconds > 59 then failure
                           else return $ (A7 $ Time hour minutes seconds)
 number :: Parser Args
 number =  do x <- float
              return $ A4 x
              <|> do  x <- integer
                      return $ A3 x



 intParse = dateTime <|> date <|> time <|> number
