{-# OPTIONS_GHC -fplugin GHC.TypeLits.Normalise #-}

module Bug where

import Bindings.NFC
import Control.Monad

doSomething :: IO ()
doSomething = void initialize
