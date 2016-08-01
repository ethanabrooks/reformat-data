#!/usr/local/bin/stack runhaskell

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveGeneric #-}
module Scrap where

import Control.Lens
import Data.Vector.Lens (sliced)
import Data.Aeson.Lens (nth, key,  _Array, _Object, _Integer, _String)
import Data.Aeson ((.:), Value, withObject, decode, encode)
import Data.Aeson.Types
import Data.Vector.Lens
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

{-    
x :: Maybe Integer -- Maybe means it might fail
x = v ^? key "foo" 
        . key "bar"
        . key "baz"
        . ix  3
        . _Integer  -- looks a bit like XPath, right?
        -}

main :: IO ()
main = do
    text <- BS.readFile "snippet.txt"
    let v = fromJust $ decode text ::  Value
        {-x = v ^? key "p" . _Array-}
        updatedLabelCol = v & key "p" . _Array . each %~ f
        f labelObj = labelObj & key "l" . _String %~ \label -> T.concat [label, "TEST"]
        {-w = set (nth 1 . key "p") v (String "x")-}
        {-y = v & nth 0 . key "l" %~ (\(String x) -> String $ T.concat [x, "TEST"])-}
    print text
    print $ encode updatedLabelCol
