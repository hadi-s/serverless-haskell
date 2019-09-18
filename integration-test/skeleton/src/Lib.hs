{-# LANGUAGE OverloadedStrings #-}
module Lib where

import AWSLambda.Events.APIGateway
import Control.Lens
import Data.Semigroup
import Data.Text (Text)
import System.Environment
import Text.Regex.PCRE.Light
import qualified Data.Aeson as Aeson
import qualified Data.HashMap.Strict as HashMap

apiGatewayHello :: APIGatewayProxyRequest Text -> IO (APIGatewayProxyResponse Text)
apiGatewayHello request = do
  putStrLn "This should go to logs"
  case HashMap.lookup "name" (request ^. agprqPathParameters) of
    Just name -> return $ responseOK & responseBody ?~ "Hello, " <> name <> "\n"
    Nothing -> return responseNotFound

handler :: Aeson.Value -> IO [Int]
handler evt = do
  -- Test logs going through
  putStrLn "This should go to logs"
  -- Test passed arguments
  getArgs >>= print
  -- Test working with an included extra library (libpcre)
  print $ match (compile "[a-z]+" []) "012abc345" []
  -- Test passed event
  print evt
  -- Test return value
  pure [11, 22, 33]
