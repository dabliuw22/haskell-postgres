{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Adapter.Postgres.Config.PostgresConfig as DB
import Adapter.Postgres.Products
import Data.Text (Text)
import Data.Maybe
import qualified Domain.Products as P
import System.Environment

load :: IO DB.Configuration
load = do
  host' <- lookupEnv "DB_HOST"
  port' <- lookupEnv "DB_PORT"
  user' <- lookupEnv "DB_USER"
  pass' <- lookupEnv "DB_PASS"
  name' <- lookupEnv "DB_NAME"
  return DB.Configuration {
           DB.host = fromMaybe "localhost" host',
           DB.port = read (fromMaybe "5432" port') :: Integer,
           DB.user = fromMaybe "haskell" user',
           DB.pass = fromMaybe "haskell" pass',
           DB.database = fromMaybe "haskell_db" name'
         }

newProduct = P.Product {
  P.productId = P.ProductId { P.id = "750e8400-e29b-41d4-a716-446655440000" },
  P.productName = P.ProductName { P.name = "NewProduct" },
  P.productStock = P.ProductStock { P.stock = 20.0 }
}

main :: IO ()
main = do
  conf <- load
  pool <- DB.create conf
  --new <- create pool newProduct
  all <- findAll pool
  print all
  one <- findById pool "d91ae396-42e7-4483-a3ef-e729c486980f"
  print one
  DB.destroy pool