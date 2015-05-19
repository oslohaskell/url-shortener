{-# Language OverloadedStrings, QuasiQuotes #-}

module Main where

-- Imports needed for Scotty
import Web.Scotty
import qualified Data.Text.Lazy as T

-- Imports needed for the HTML templating
import Text.Hamlet
import Text.Blaze.Html.Renderer.Text

-- Import for the SQLite database library
import Database.SQLite.Simple

-- We need `liftIO` to run IO functions in the `ActionM` monad
import Control.Monad.IO.Class (liftIO)

import System.Random (randomRIO)
import Control.Exception.Base (bracket)

getIndexH :: ActionM ()
getIndexH = do
  (html . renderHtml) [shamlet|
    $doctype 5
    <html>
      <head>
        <title>URL Shortener
    <body>
      <form method="POST" action="/create">
        <input name="url">
        <button type="submit">Create shortcut
  |]

postCreateH :: Connection -> ActionM ()
postCreateH connection = do
  url <- param "url"
  key <- liftIO $ createRandomKey 5
  liftIO $ execute connection
    "INSERT INTO mapping (key, url) VALUES (?, ?)"
    (key :: T.Text, url :: T.Text)
  html ("Created shortcut "
         `T.append` key
         `T.append` " → "
         `T.append` url)

getLookupH :: Connection -> ActionM ()
getLookupH connection = do
  key <- param "key"
  result <- liftIO $ query
         connection
         "SELECT url FROM mapping WHERE key = ?"
         (Only (key :: T.Text))
  case result of
    [Only url] -> redirect url
    _          -> html "Unknown id"

-- Generate a random string of the given length
createRandomKey :: Int -> IO T.Text
createRandomKey 0 = return ""
createRandomKey len = do
  randomChar <- randomRIO ('a', 'z') -- generate a random character
  rest <- createRandomKey (len-1)    -- generate the rest of the string
  return $ randomChar `T.cons` rest  -- return the random character prepended...
                                     -- ... to the rest of the string

app :: Connection -> IO ()
app connection =
  -- Run scotty on port 3000 and provide two GET endpoints and one POST
  -- endpoint. The routes are matched top-to-bottom.
  scotty 3000 $ do
    get  "/"       getIndexH
    post "/create" (postCreateH connection)
    get  "/:key"   (getLookupH connection) -- bind what's after `/` to `key`

main = do
  -- `bracket` is used to ensure that we close the database handle:
  bracket
    (open "mapping.db")
    close
    app
