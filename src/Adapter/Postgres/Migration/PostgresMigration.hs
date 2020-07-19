module Adapter.Postgres.Migration.PostgresMigration (migrate) where

import Data.Pool
import qualified Database.PostgreSQL.Simple as PG
import qualified Database.PostgreSQL.Simple.Migration as M

migrate :: Pool PG.Connection -> String -> IO ()
migrate pool dir = do
  migration <- withResource pool
    (\conn -> PG.withTransaction conn (M.runMigrations False conn commands))
  case migration of
    M.MigrationError e -> return ()
    _                  -> return () -- MigrationSuccess
  where
    commands = [M.MigrationInitialization, M.MigrationDirectory dir]