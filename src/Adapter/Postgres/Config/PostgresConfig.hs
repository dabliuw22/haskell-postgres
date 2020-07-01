module Adapter.Postgres.Config.PostgresConfig (Configuration(..), create, destroy) where

import qualified Database.PostgreSQL.Simple as PG
import Database.PostgreSQL.Simple.Time
import Control.Exception
import Data.Pool
import GHC.Word

data Configuration =
   Configuration {
    host :: String,
    port :: Integer,
    user :: String,
    pass :: String,
    database :: String
   } deriving Eq

--pool :: Configuration -> (Pool PG.Connection -> IO a) -> IO a
--pool conf = bracket initPool cleanPool where
  --initPool = createPool (connection conf) close 1 10 15
  --cleanPool = destroyAllResources
create :: Configuration -> IO (Pool PG.Connection)
create conf = createPool (connection conf) close 1 10 15

destroy :: Pool PG.Connection -> IO ()
destroy pool = destroyAllResources pool

connection :: Configuration -> IO PG.Connection
connection conf = PG.connect PG.ConnectInfo {
  PG.connectHost = host conf,
  PG.connectPort = fromIntegral (port conf),
  PG.connectUser = user conf,
  PG.connectPassword = pass conf,
  PG.connectDatabase = database conf
}

close :: PG.Connection -> IO ()
close = PG.close