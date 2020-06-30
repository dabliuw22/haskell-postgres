{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Adapter.Postgres.Config.PostgresConfig as DB
import Adapter.Postgres.Products
import Data.Text (Text)
import qualified Domain.Products as P

conf = DB.Configuration {
  DB.host = "localhost",
  DB.port = 5432,
  DB.user = "haskell",
  DB.pass = "haskell",
  DB.database = "haskell_db"
}

newProduct = P.Product {
  P.productId = P.ProductId { P.id = "950e8400-e29b-41d4-a716-446655440000" },
  P.productName = P.ProductName { P.name = "NewProduct" },
  P.productStock = P.ProductStock { P.stock = 20.0 }
}

main :: IO ()
main = do
  pool <- DB.create conf
  new <- create pool newProduct
  all <- findAll pool
  print all
  one <- findById pool "d91ae396-42e7-4483-a3ef-e729c486980f"
  print one
  DB.destroy pool