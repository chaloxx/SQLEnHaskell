module Url  where
import AST (Env (..))



-- Modulo para la formación de rutas de acceso

--Obtiene la ruta hacia una BD
url :: String -> String -> FilePath
url u n = "DataBase/" ++ u ++ "/" ++ n

--Obtiene la ruta hacia una tabla
url' :: Env -> String -> FilePath
url' e t = (url (name e) (dataBase e)) ++ "/" ++ t
