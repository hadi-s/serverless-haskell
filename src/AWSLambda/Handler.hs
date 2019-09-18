{-|
Module      : AWSLambda.Handler
Stability   : experimental
Portability : POSIX

Entry point for AWS Lambda handlers deployed with @serverless-haskell@ plugin.
-}
module AWSLambda.Handler
  ( lambdaMain
  ) where

import Control.Exception (finally)
import Control.Lens
import Control.Monad (void)

import qualified Data.Aeson as Aeson

import qualified Data.Text.Encoding as Text
import qualified Data.Text.IO as Text

import Network.Wreq

import System.Environment (lookupEnv)
import System.IO (stdout)

type Handler = (String, Value -> IO Value)

lambdaMain ::
     [Handler]
  -> IO ()
lambdaMain handlers = do
  Just runtimeEndpoint <- lookupEnv "AWS_LAMBDA_RUNTIME_API"
  forever $ processRequest handlers runtimeEndpoint

dispatchTo ::
     (Aeson.FromJSON event, Aeson.ToJSON res)
  => (event -> IO res) -- ^ Function to process the event
  -> Value -> IO Value
dispatchTo = _

processRequest ::
     [Handler]
  -> String -- ^ AWS Lambda runtime endpoint
  -> IO ()
processRequest handlers runtimeEndpoint = do
  request <- asJSON =<< get $ "http://" ++ runtimeEndpoint ++ "/2018-06-01/runtime/invocation/next"
  let body = r ^. responseBody
  let requestId = r ^. responseHeader "Lambda-Runtime-Aws-Request-Id"

