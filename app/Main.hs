{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Adapter.Postgres.Config.PostgresConfig as DB
import Adapter.Postgres.Migration.PostgresMigration
import qualified Adapter.Postgres.Products as ADA
import qualified Application.Products as APP
import Control.Monad.IO.Class
import Data.Maybe (fromJust, fromMaybe)
import Data.Text (Text, pack)
import Data.UUID.V1 (nextUUID)
import qualified Data.UUID as UUID
import qualified Domain.Products as P
import System.Environment

dir = "db/migrations"

main :: IO ()
main = do
  conf <- load
  pool <- DB.create conf
  migration <- migrate pool dir
  newProduct <- new
  insert <- APP.create' (ADA.create pool) newProduct
  all <- APP.findAll' (ADA.findAll pool)
  print all
  one <- APP.findById' (ADA.findById pool) "038b7106-bc8d-11ea-8001-3af9d3b254d0"
  print one
  DB.destroy pool

load :: MonadIO m => m DB.Configuration
load = do
  host' <- liftIO $ lookupEnv "DB_HOST"
  port' <- liftIO $ lookupEnv "DB_PORT"
  user' <- liftIO $ lookupEnv "DB_USER"
  pass' <- liftIO $ lookupEnv "DB_PASS"
  name' <- liftIO $ lookupEnv "DB_NAME"
  return DB.Configuration {
           DB.host = fromMaybe "localhost" host',
           DB.port = read (fromMaybe "5432" port') :: Integer,
           DB.user = fromMaybe "haskell" user',
           DB.pass = fromMaybe "haskell" pass',
           DB.database = fromMaybe "haskell_db" name'
         }

new :: MonadIO m => m P.Product
new = do
  uuid <- liftIO nextUUID
  let uuid' = pack (UUID.toString (fromJust uuid))
  return P.Product {
    P.productId = P.ProductId { P.id = uuid' },
    P.productName = P.ProductName { P.name = uuid' },
    P.productStock = P.ProductStock { P.stock = 100.0 }
  }