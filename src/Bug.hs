{-# OPTIONS_GHC -fplugin Polysemy.Plugin #-}

module Bug where

import Bindings.NFC
import Control.Monad

doSomething :: IO ()
doSomething = void initialize
