#!/usr/local/bin/stack runhaskell
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveGeneric #-}
module Scrap where

import Debug.Trace
import Data.Aeson ((.:), Value, withObject, decode, encode)
import Data.Aeson.Types
import Data.Aeson.Lens
import Control.Lens
import Data.Maybe
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import qualified Data.ByteString.Lazy.Char8 as BS
import qualified Data.HashMap.Strict as HM
import Data.Vector (Vector)
import Data.HashMap.Strict (HashMap)
import Data.ByteString.Lazy.Char8 (ByteString)

main :: IO ()
main = do text <- BS.readFile "snippet.txt"
          let result = 
                case decode text :: Maybe Value of
                    Nothing -> Nothing
                    Just it -> it ^? _Array .~ _1
          print result
