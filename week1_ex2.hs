{-# Language FlexibleInstances#-}
module Week1_2 where

import Prelude hiding (Semigroup, Monoid, (<>), mempty)
import Data.Either
import Data.List.NonEmpty
import Data.Map as Map

class Semigroup a where
  (<>) :: a -> a -> a

class Semigroup a => Monoid a where
  mempty :: a


-- AND operator is accociative
-- a <> (b <> c)= (a <> b) <> c 
-- LHS = a <> (b <> c)
-- a && (b && c) = (a && b) && c 
-- { By bool.a }
-- a <> (b && c) 
-- { By bool.a }
-- a && (b && c)
-- {And is assoctive}
-- (a && b) && C
--{ By bool.a  in reverse}
-- (a <> b ) && c 
--{ By bool.a  in reverse}
-- (a <> b ) <> c 
-- = RHS
instance Semigroup Bool where
  a <> b = a && b      --- boool.1

-- True is mempty in terms of AND operation
instance Monoid Bool where
  mempty = True




-- Just xs <> (Just ys <> Just zs) =? (Just xs <> Just ys) <> Just zs 
--LHS=	Just xs <> (Just ys <> Just zs)
--{By applying Just.1}
-- =Just xs <> Just (xs <> ys )
--{By applying Just.1}
-- = Just (xs <> ys <> zs)  ... .2
--RHS=  (Just xs <> Just ys) <> Just zs 
--{By applying Just.1}
-- = Just (xs <> ys) <> Just zs
--{By applying Just.1}
-- = Just (xs <> ys <> zs)  .....1
-- {from .1 and .2 }
--RHS == LHS
instance Semigroup a => Semigroup (Maybe a) where
  (Just xs) <> (Just ys) = Just (xs <> ys)   --Just.1
  Nothing  <> ys         = ys
  xs       <> Nothing    = xs

instance Monoid a => Monoid (Maybe a) where
  mempty = Nothing


-- Show doesn't work on this for some reason
instance (Semigroup a, Semigroup b) => Semigroup (Either a b) where
  (Left x)  <> (Left y)  = Left  (x <> y)
  (Right x) <> (Right y) = Right (x <> y)
  (Left x)  <> _         = Left x
  _         <> Left y    = Left y

instance (Monoid a, Monoid b) => Monoid (Either a b) where
  mempty = Right mempty



--Proving associativity for id function
-- a <> (b <> c)= (a <> b) <> c 
-- LHS=a <> (b <> c)
--{By applying fun.1 } 
-- = a <> (id)
--{By applying fun.1 } 
-- = id                      ...fun.2 

-- RHS=(a <> b) <> c
--{By applying fun.1 } 
-- = (id) <> c 
--{By applying fun.1 } 
-- = id                     ...fun.3
--{from fun.2 and fun.3}
-- RHS == LHS
instance Semigroup (a -> a) where
  _ <> _ = id       --- fun.1

instance Monoid (a -> a) where
  mempty = id
  

instance (Semigroup a, Semigroup b) => Semigroup (a, b) where
 (x1, y1) <> (x2, y2) = ((x1 <> x2), (y1 <> y2))

instance (Monoid a, Monoid b) => Monoid (a, b) where
  mempty = (mempty, mempty)


instance Semigroup () where
  _ <> _ = ()

instance Monoid () where
  mempty = ()


instance Semigroup [a] where
  xs <> ys = xs ++ ys

instance Monoid [a] where
  mempty = []


instance Semigroup (NonEmpty a) where
  (x :| xs) <> (y :| ys) = x :| (xs ++ y:ys)


instance (Ord k, Semigroup a) => Semigroup (Map k a) where
  xs <> ys = unionWith (<>) xs ys

instance (Ord k, Monoid a) => Monoid (Map k a) where
  mempty = empty
