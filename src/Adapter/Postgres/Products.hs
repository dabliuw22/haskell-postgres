{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE BlockArguments #-}
module Adapter.Postgres.Products (ProductRepository(..)) where

import Control.Monad.Except
import Control.Monad.IO.Class
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
  findById pool id = findById' pool id `catchError` (\e -> pure Nothing)
  findAll pool = findAll' pool `catchError` (\e -> pure [])
  create pool product = create' pool product

instance FromRow ProductRow where
  fromRow = ProductRow <$> field <*> field <*> field

instance ToRow ProductRow where
  toRow p = [toField (_id p), toField (_name p), toField (_stock p)]

findById' :: MonadIO m => Pool Connection -> Text -> m (Maybe P.Product)
findById' pool' id' = do
    let sql = "SELECT * FROM products WHERE id = ?"
    result <- liftIO $ withResource pool' (\conn' -> query conn' sql [id'])
    return $ case result of
             (h: _) -> Just (toDomain h)
             _      -> Nothing

findAll' :: MonadIO m => Pool Connection -> m [P.Product]
findAll' pool' = liftIO $ fmap (map toDomain) (withResource pool' (`query_` "SELECT * FROM products"))

create' :: MonadIO m => Pool Connection -> P.Product -> m ()
create' pool' p' = do
    let sql = "INSERT INTo products(id, name, stock) VALUES (?, ?, ?)"
    let row = fromDomain p'
    result <- liftIO $ withResource pool' (\conn' -> execute conn' sql (_id row , _name row, _stock row))
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