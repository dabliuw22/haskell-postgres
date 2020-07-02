module Application.Products where

import Data.Text (Text)
import qualified Domain.Products as P

class (Functor m, Monad m) => ProductService m where
  findById' :: (Text -> m (Maybe P.Product)) -> Text -> m (Maybe P.Product)
  findAll' :: m [P.Product] -> m [P.Product]
  create' :: (P.Product -> m ()) -> P.Product -> m ()
  
instance ProductService IO where
  findById' f id = f id
  findAll' f =  f
  create' f product = f product
