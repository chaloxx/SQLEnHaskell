import AST (Env(..))
import System.Console.Readline
import Run (parseCmd,checkSelectUser)


-- Módulo inicial

main :: IO ()
main = main' (Env "" "" "Estándar Input")

main' :: Env -> IO ()
main' e = do maybeLine <- readline (txt e)
             case maybeLine of
              Nothing  -> main' e
              Just "q" -> return ()
              Just line -> do addHistory line
                              e' <- parseCmd e line
                              main' e'

    where txt e = if checkSelectUser e then (name e) ++ "@> "
                  else "> "
