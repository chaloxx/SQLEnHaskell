module Url  where
import AST (Env (..))



-- Modulo para la formación de rutas de acceso

--Obtiene la ruta hacia una BD
url :: Env -> FilePath
url e = "DataBase/" ++ (name e)  ++ "/" ++ (dataBase e) ++ "/"

--Obtiene la ruta hacia una tabla
url' :: Env -> String -> FilePath
url' e t = (url e) ++ t
