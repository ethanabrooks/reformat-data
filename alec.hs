{-# LANGUAGE OverloadedStrings #-}
module Lib where
import Data.Aeson
import qualified Data.Map as M
import Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as BS
import Data.Text (Text)
import qualified Data.Text as T

--transform :: ByteString -> [Text]
transform bs = do
   decoded <- decode bs :: Maybe [M.Map Text Value]
   return . cat_maybes . map extract_s $ decoded

cat_maybes (Just x:xs)  = x : cat_maybes xs
cat_maybes (Nothing:xs) = cat_maybes xs
cat_maybes []           = []

extract_s :: M.Map Text Value -> Maybe Text
extract_s m = do
   s_value <- "s" `M.lookup` m

   "span" `M.lookup` m

   case s_value of
       String s -> Just s
       _        -> Nothing

test_string :: ByteString
test_string = "[{\"a\":\"b\"},{\"span\":\"whatever\",\"s\":\"hello\"}]"
-- ["hello"]
