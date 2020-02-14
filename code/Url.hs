module Url  where


import AST (Env (..))


--Obtiene la ruta hacia una BD
url :: String -> String -> FilePath
url n b = "DataBase/" ++ n ++ "/" ++ b

--Obtiene la ruta hacia una tabla
url' :: Env -> String -> FilePath
url' e t = (url (name e) (dataBase e)) ++ "/" ++ t


--Obtiene la ruta hacia un usuario
url'' :: Env -> FilePath
url'' e = "DataBase/" ++ (name e) ++ "/"

url''' :: Env -> FilePath
url''' e  = url'' e ++ (dataBase e) ++ "/"
