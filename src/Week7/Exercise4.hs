{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -fwarn-incomplete-patterns  #-}
{-# OPTIONS_GHC -fwarn-hi-shadowing #-}
{-# OPTIONS_GHC -fwarn-name-shadowing #-}
{-# LANGUAGE DeriveFunctor, DeriveFoldable, DeriveTraversable #-}
{-# LANGUAGE FlexibleInstances, TypeSynonymInstances #-}

module Week7.Exercise4 where

import Control.Arrow
import Data.Function (on)
import Data.Map (Map (..))
import qualified Data.Map as Map
import Data.Semigroup (Endo (..), stimesMonoid)
import Data.Set (Set (..))
import qualified Data.Set as Set
import Week4.Exercise3
import Week7.Exercise2
import Week7.Exercise3

import Data.Coerce

import Data.Char (intToDigit)
import Data.Foldable (find)
import Data.Map (Map (..))
import qualified Data.Map as Map
import Data.Semigroup (Endo (..), stimesMonoid)
import Data.Set (Set (..))
import qualified Data.Set as Set
--import Week4.Exercise3
--import Week4.Exercise4
-- import Data.Range.Algebra (Algebra)
-- import Data.Fix
-- import Data.Fix

{-
(f a -> a) one step for nonrecursive generator
(Fix f -> a) all the steps
repeats the algebra untill it is done.
comonad reader field guide
-}

-- cata :: Functor f => (f a -> a) -> Fix f -> a

-- F-Algebra
-- type Algebra f a = f a -> a 

-- type  Expr'   = (Fix (Expr'')) 
-- data Expr'' r = Add r r | Zero | Mul r r | One |
--    Let String r r | Var String deriving (Functor)
--  $(deriveShow1 ''Expr'')

-- pattern (Fix (Add l r)) = Add l r
-- pattern (Fix Zero) = Zero  
-- pattern (Fix (Mul l r )) = Mul l r
-- pattern (Fix (One)) = One  
-- pattern (Fix (Let s l r)) = Let s l r
-- pattern (Fix (Var s)) = Var s

isSimple :: Expr' -> Bool
isSimple expr = cata isSimpleAlg expr

isSimpleAlg :: Algebra ExprF Bool
isSimpleAlg expr = case expr of
  LetF _ _ _ -> False
  VarF _ -> False
  AddF False _ -> False
  AddF _ False -> False
  AddF _ _ -> True
  MulF False _ -> False
  MulF _ False -> False
  MulF _ _ -> True
  ZeroF -> True
  OneF -> True

{-case exp of
    Let _ _ _ -> False
    otherwise-> case exp of
        Var _ ->False
        otherwise->  True
-}
  
breadth :: Expr' -> Int
breadth expr = cata breadth' expr

breadth' :: Algebra ExprF Int
breadth' ZeroF = 1
breadth' OneF = 1
breadth' (AddF l r) = 1 + l + r
breadth' (MulF l r) = 1 + l + r
breadth' (LetF s l r) = 1 + l + r
breadth' (VarF _) = 1

assocAdd :: Expr' -> Expr'
assocAdd expr = undefined

-- assocAdd (Add (Add a b) z) = assocAdd (Add a (Add b z))
-- assocAdd (Add a b) = Add (assocAdd a) (assocAdd b)
-- assocAdd (Mul a b) = Mul (assocAdd a) (assocAdd b)
-- assocAdd (Let s a b) = Let s (assocAdd a) (assocAdd b)
-- assocAdd x = x

-- assocMul :: Expr' -> Expr'
-- assocMul (Mul (Mul a b) z) = assocMul (Add a (Add b z))
-- assocMul (Add a b) = Add (assocMul a) (assocMul b)
-- assocMul (Mul a b) = Mul (assocMul a) (assocMul b)
-- assocMul (Let s a b) = Let s (assocMul a) (assocMul b)
-- assocMul x = x

-- comp a b = if a>b then
--   a + 1
--   else
--   b + 1


-- depth :: Expr' -> Int
-- depth Zero = 1
-- depth One = 1
-- depth (Add a b ) = comp (depth a) (depth b)
-- depth (Mul a b ) = comp (depth a) (depth b)
-- depth (Let _ a b) = comp (depth a) (depth b) 
-- depth (Var _ ) = 1


unifyAddZero :: Expr' -> Expr'
unifyAddZero = cata unifyAddZero'

unifyAddZero' :: Algebra ExprF Expr'
unifyAddZero' (AddF (Fix ZeroF) x) = x
unifyAddZero' (AddF x (Fix ZeroF)) = x
unifyAddZero' x = coerce x

-- unifyMulOne (Mul One x) = x
-- unifyMulOne (Mul x One) = x
-- unifyMulOne x = x

-- codistAddMul :: Expr' -> Expr'
-- codistAddMul ok@(Add (Mul a b) (Mul c d))
--   | a == c , b == d = Mul (Add One One) (Mul a b)
--   | a == c = Mul a (Add b d)
--   | b == d = Mul b (Add a c)
--   | otherwise = ok
-- codistAddMul x = x



-- data Expr' = Add Expr' Expr' | Zero | Mul Expr' Expr' | One |
--   Let String Expr' Expr' | Var String


-- commAdd::  Expr' -> Expr'
--commAdd (Let s exp1 exp2)
--   |(commAdd exp1)> (commAdd exp2)= (Let s (commAdd exp2) (commAdd exp1))
--   |otherwise= (Let s  (commAdd exp1) (commAdd exp2))
--commAdd (Add exp1 exp2)
--  | exp1 > exp2 = Add exp2 exp1 
--  |otherwise= Add exp1 exp2
-- commAdd (Add x y) = case (commAdd x, commAdd y) of
--   (z, w) | z > w -> Add w z
--   (z, w) -> Add z w
-- commAdd (Mul x y) = Mul (commAdd x) (commAdd y)



-- | Free-monadic version of the `(|||)` function
-- from the `Control.Arrow` module of the `base` package.
(||||) :: (a -> b) -> (m (Free' m a) -> b) -> Free' m a -> b
f |||| g = let
  h (Pure' x) = f x
  h (Free' xs) = g xs in
  h
infixr 2 ||||

-- | Cofree-comonadic version of the `(&&&)` function
-- from the `Control.Arrow` module of the `base` package.
(&&&&) :: (a -> b) -> (a -> m (Cofree' m b)) -> a -> Cofree' m b
f &&&& g = let
  h x = Cofree' (f x) (g x) in
  h
infixr 3 &&&&

type Algebra m a = m a -> a

cata :: Functor m => Algebra m a -> Fix m -> a
cata a = let
  c = cata a in
  a . fmap c . unFix

-- | Algebraic version of the `Endo` type
-- from the `Data.Monoid` module of the `base` package.
newtype Embed m = Embed {appEmbed :: Algebra m (Fix m)}

instance Semigroup (Embed m) where
  Embed g <> Embed f = Embed (g . unFix . f)

instance Monoid (Embed m) where
  mempty = Embed Fix

type Coalgebra m a = a -> m a

ana :: Functor m => Coalgebra m a -> a -> Fix m
ana c = let
  a = ana c in
  Fix . fmap a . c

hylo :: Functor m => Algebra m b -> Coalgebra m a -> a -> b
-- Factored version of `hylo a c = cata a . ana c`.
hylo a c = let
  h = hylo a c in
  a . fmap h . c

-- | Coalgebraic version of the `Endo` type
-- from the `Data.Monoid` module of the `base` package.
newtype Project m = Project {appProject :: Coalgebra m (Fix m)}

instance Semigroup (Project m) where
  Project g <> Project f = Project (g . Fix . f)

instance Monoid (Project m) where
  mempty = Project unFix

type ProductAlgebra m a = m (Fix m, a) -> a

para :: Functor m => ProductAlgebra m a -> Fix m -> a
para a = let
  p = id &&& para a in
  a . fmap p . unFix

type SumCoalgebra m a = a -> m (Either (Fix m) a)

apo :: Functor m => SumCoalgebra m a -> a -> Fix m
apo c = let
  a = id ||| apo c in
  Fix . fmap a . c

hypo :: Functor m => ProductAlgebra m b -> SumCoalgebra m a -> a -> b
hypo a c = para a . apo c

type CofreeAlgebra m a = m (Cofree' m a) -> a

histo :: Functor m => CofreeAlgebra m a -> Fix m -> a
histo a = let
  h = histo a &&&& fmap h . unFix in
  a . fmap h . unFix

type FreeCoalgebra m a = a -> m (Free' m a)

futu :: Functor m => FreeCoalgebra m a -> a -> Fix m
futu c = let
  f = futu c |||| Fix . fmap f in
  Fix . fmap f . c

chrono :: Functor m => CofreeAlgebra m b -> FreeCoalgebra m a -> a -> b
chrono a c = histo a . futu c

-- While we could reimplement all the old functions we have for `Expr`
-- to obtain new equivalent functions for `Expr'`,
-- that would be tedious and, in part,
-- vain due to our poor choice of representation (not de Bruijn).
-- Thus, we opt to merely derive an isomorphism and
-- transport the old functions along it.

fixExprCoalg' :: Coalgebra ExprF Expr
fixExprCoalg' = let
  f :: Expr -> ExprF Expr
  f (Add x y) = AddF x y
  f Zero = ZeroF
  f (Mul x y) = MulF x y
  f One = OneF
  f (Let cs x y) = LetF cs x y
  f (Var cs) = VarF cs in
  f

fixExpr' :: Expr -> Expr'
fixExpr' = ana fixExprCoalg'

unFixExprAlg' :: Algebra ExprF Expr
unFixExprAlg' = let
  f :: ExprF Expr -> Expr
  f (AddF x y) = Add x y
  f ZeroF = Zero
  f (MulF x y) = Mul x y
  f OneF = One
  f (LetF cs x y) = Let cs x y
  f (VarF cs) = Var cs in
  f

unFixExpr' :: Expr' -> Expr
unFixExpr' = cata unFixExprAlg'

-- showsPrecExpr' :: Int -> Expr' -> ShowS
-- showsPrecExpr' n = showsPrecExpr n . unFixExpr'

-- showsExpr' :: Expr' -> ShowS
-- showsExpr' = showsPrecExpr' 0

-- showExpr' :: Expr' -> String
-- showExpr' = flip showsExpr' mempty

-- closedDeepBad' :: Expr'
-- closedDeepBad' = fixExpr' closedDeepBad

-- closedDeep' :: Expr'
-- closedDeep' = fixExpr' closedDeep

instance Eq Expr' where
  (==) = on (==) unFixExpr'

instance Ord Expr' where
  compare = on compare unFixExpr'


