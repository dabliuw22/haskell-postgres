{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}
module Adapter.Postgres.Products (ProductRepository(..)) where

import Control.Exception
import Data.Text (Text)
import Data.Pool
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.FromRow
import Database.PostgreSQL.Simple.ToRow
import Database.PostgreSQL.Simple.ToField (toField)
import qualified Domain.Products as P

data ProductRow =
  ProductRow {
    _id :: Text,
    _name :: Text,
    _stock :: Double
  }

class (Functor m, Monad m) => ProductRepository m where
  findById :: Pool Connection -> Text -> m (Maybe P.Product)
  findAll :: Pool Connection -> m [P.Product]
  create :: Pool Connection -> P.Product -> m ()

instance ProductRepository IO where
  findById pool id = findById' pool id
  findAll pool = findAll' pool
  create pool product = create' pool product

instance FromRow ProductRow where
  fromRow = ProductRow <$> field <*> field <*> field

instance ToRow ProductRow where
  toRow p = [toField (_id p), toField (_name p), toField (_stock p)]

findById' :: Pool Connection -> Text -> IO (Maybe P.Product)
findById' pool' id' = do
    let q = "SELECT * FROM products WHERE id = ?"
    r <-  withResource pool' (\conn' -> query conn' q [id'] :: IO [ProductRow])
    let p = case r of
          (h: t) -> Just (toDomain h)
          []     -> Nothing
    return p

findAll' :: Pool Connection -> IO [P.Product]
findAll' pool' = fmap (map toDomain) (withResource pool' (`query_` "SELECT * FROM products"))

create' :: Pool Connection -> P.Product -> IO ()
create' pool' p' = do
    let i = "INSERT INTo products(id, name, stock) VALUES (?, ?, ?)"
    let row = fromDomain p'
    r <- withResource pool' (\conn' -> execute conn' i (_id row , _name row, _stock row))
    return ()

toDomain :: ProductRow -> P.Product
toDomain row =
  P.Product {
    P.productId = P.ProductId (_id row),
    P.productName = P.ProductName (_name row),
    P.productStock = P.ProductStock (_stock row)
  }

fromDomain :: P.Product -> ProductRow
fromDomain p =
  ProductRow {
    _id = P.id (P.productId p),
    _name = P.name (P.productName p),
    _stock = P.stock (P.productStock p)
  }