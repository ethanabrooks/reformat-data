#!/usr/local/bin/stack runhaskell
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DeriveGeneric #-}
module Scrap where

import Debug.Trace
import Data.Aeson ((.:), Value, withObject, decode, encode, genericParseJSON, defaultOptions, Array)
import Data.Aeson.Types
import Data.Maybe
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import qualified Data.ByteString.Lazy.Char8 as BS
import qualified Data.HashMap.Strict as HM
import Data.Vector (Vector)
import Data.HashMap.Strict (HashMap, (!))
import Data.ByteString.Lazy.Char8 (ByteString)
import GHC.Exts

type TextHash = HashMap Text Text
type P = Vector TextHash

getObj :: Value -> Maybe Object
getObj value = parseMaybe parseJSON value

getP :: Value -> Maybe P
getP value = parseMaybe (genericParseJSON defaultOptions) value

updateCol :: Vector Text -> ByteString -> ByteString
updateCol semantics column = fromMaybe column updatedString
  where updatedString = do
            json    <- decode column :: Maybe Object
            updated <- (updateObj semantics) json
            return $ encode updated

updateObj :: Vector Text -> Object -> Maybe Object
updateObj semantics json = HM.adjust update "p" json
  where update = parse $ updateArray semantics


updateArray :: Vector Text -> Value -> Parser Array
updateArray semantics value = withArray "array" f value
  where f labels = parseJSON . Array . V.map (uncurry updateLabelObj) $ V.zip semantics labels


updateLabelObj :: Text -> Value -> Parser Object
updateLabelObj semantic value = withObject "object" f value
    {-Object $ -}
  where f labelObj = parseJSON . Object . HM.adjust (updateText semantic) "l" labelObj
        updateText :: Text -> Text -> String
        updateText semantic label = String $ T.concat [label, ",", semantic]



main :: IO ()
main = do text <- BS.readFile "snippet.txt" 
          let filelines = BS.lines text
              semantics = V.fromList $ map (T.pack . show) [1..9]
              newText   = updateObj semantics text
          print newText

