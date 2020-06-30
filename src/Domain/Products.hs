module Domain.Products where

import Data.Text (Text)

newtype ProductId = ProductId { id :: Text } deriving Show

newtype ProductName = ProductName { name :: Text } deriving Show

newtype ProductStock = ProductStock { stock :: Double } deriving Show

data Product = 
  Product {
    productId :: ProductId,
    productName :: ProductName,
    productStock :: ProductStock
  } deriving Show