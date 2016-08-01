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


-- |global update

updateLine :: ByteString -> ByteString
updateLine line = BS.intercalate "\t" $ map (updateColumn semantics) columns
  where semantics = V.fromList $ gatherSemantics columns
        columns   = BS.split '\t' line


-- |gather Semantics

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


-- |update Labels

throwError :: Value -> String -> Value
throwError value expected = 
    error $ (show value) ++ " should be an " ++ expected


updateColumn :: Vector Text -> ByteString -> ByteString
updateColumn semantics column = 
    case (decode column :: Maybe Object) of
      Nothing   -> column
      Just json -> encode $ updatePValue semantics json


updatePValue :: Vector Text -> Object -> Value
updatePValue semantics obj = 
    Object $ HM.adjust (updateLabelArray semantics) "p" obj


updateLabelArray :: Vector Text -> Value -> Value
updateLabelArray semantics (Array labels) = 
    Array $ V.zipWith updateLabelObj semantics labels
updateLabelArray _ value = throwError value "array"


updateLabelObj :: Text -> Value -> Value
updateLabelObj semantic (Object label) = 
    Object $ HM.adjust (updateLabelText semantic) "l" label
updateLabelObj _ value = throwError value "object"


updateLabelText :: Text -> Value -> Value
updateLabelText semantic (String label) = 
    String $ T.concat [label, ",", semantic]
updateLabelText _ value = throwError value "string"

main :: IO ()
main = do text <- BS.readFile "locationSearch_gradingtest.txt" 
          let filelines = BS.lines text
              newText   = BS.unlines $ map updateLine filelines
          BS.writeFile "new.locationSearch_gradingtest" newText

