#!/usr/local/bin/stack runhaskell
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveGeneric #-}
module Scrap where

import Data.Aeson ((.:), Value, withObject, decode)
import Data.Aeson.Types (parseMaybe, Parser, Array)
import Data.Maybe
import Data.Text (Text)
import qualified Data.Vector as V
import Data.Vector (Vector)
import qualified Data.ByteString.Lazy.Char8 as BS
import Data.ByteString.Lazy.Char8 (ByteString)

collectFromArray :: Array -> Vector Text
collectFromArray array = V.map getSemantic array
  where getSemantic o  = fromMaybe "default" $ parseSemantic o
        parseSemantic  = parseMaybe $ parseLookup "s" :: Value -> Maybe Text


parseLookup :: Text -> Value -> Parser Text
parseLookup key = withObject "span" $ (\span -> span .: key :: Parser Text)


collectSemantics :: Vector ByteString -> Vector Text
collectSemantics columns = V.concatMap collect columns
  where collect = (collectFromArray =<<) . V.fromList . maybeToList . decode

main :: IO ()
main = do text <- BS.readFile "snippet.txt"
          let columns = V.fromList $ BS.split '\t' text
          print $ collectSemantics columns

