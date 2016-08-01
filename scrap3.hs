#!/usr/local/bin/stack runhaskell
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveGeneric #-}
module Scrap where

import Debug.Trace
import Data.Aeson ((.:), Value, withObject, decode, encode)
import Data.Aeson.Types
import Data.Maybe
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import qualified Data.ByteString.Lazy.Char8 as BS
import qualified Data.HashMap.Strict as HM
import Data.Vector (Vector)
import Data.HashMap.Strict (HashMap)
import Data.ByteString.Lazy.Char8 (ByteString)


type TextHash = HashMap Text Text
type P = Vector TextHash



gatherSemantics :: [ByteString] -> [Text]
gatherSemantics columns = concat $ mapMaybe gatherFrom columns

gatherFrom :: ByteString -> Maybe [Text]
gatherFrom column = do json  <- decode column :: Maybe Object
                       spans <- HM.lookup "spans" json
                       return $ gatherFromArray spans

gatherFromArray :: Value -> [Text]
gatherFromArray (Array spans) = map getSemantic $ V.toList spans
  where getSemantic (Object span) = 
          getText . fromMaybe "default" $ HM.lookup "s" span
        getText (String text)     = text


main :: IO ()
main = do text <- BS.readFile "snippet.txt"
          let columns = BS.split '\t' text
          let result = gatherSemantics columns
          print result

