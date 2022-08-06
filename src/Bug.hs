{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fplugin Polysemy.Plugin #-}

module Bug where

import Control.Monad
import Pulsar.Client

topic :: TopicName
topic = TopicName "a-topic"

onError :: String -> RawResult -> IO ()
onError action result =
  case renderResult result of
    Just r -> putStrLn $ "Unable to " <> action <> " with error: " <> show r
    Nothing -> putStrLn $ "Unable to " <> action <> " with other error: " <> show (unRawResult result)

doSomething :: IO ()
doSomething =
  withClient defaultClientConfiguration "pulsar://localhost:6650" $ do
    void $
      consumeReader defaultReaderConfiguration topic messageIdEarliest (onError "initiate" >=> const (return [])) $
        (,)
          <$> messageId messageIdShow
          <*> messageContent
