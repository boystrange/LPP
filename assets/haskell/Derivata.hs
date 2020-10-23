
data Fun = X
         | Con Int
         | Fun :+: Fun
         | Fun :-: Fun
         | Fun :*: Fun
         | Fun :^: Int

infixr 2 :+:, :-:
infixr 3 :*:
infixl 4 :^:

instance Show Fun where
  show = auxU
    where
      auxU X = "x"
      auxU (Con n) = show n
      auxU (f :+: g) = auxG 2 f ++ " + " ++ auxG 2 g
      auxU (f :-: g) = auxG 2 f ++ " - " ++ auxG 2 g
      auxU (f :*: g) = auxG 3 f ++ " * " ++ auxG 3 g
      auxU (f :^: n) = auxG 4 f ++ "^" ++ show n

      auxG p f@(_ :+: _) | p > 2 = parens (auxU f)
      auxG p f@(_ :-: _) | p > 2 = parens (auxU f)
      auxG p f@(_ :*: _) | p > 3 = parens (auxU f)
      auxG _ f = auxU f

      parens s = "(" ++ s ++ ")"

derive :: Fun -> Fun
derive X         = Con 1
derive (Con _)   = Con 0
derive (f :+: g) = derive f :+: derive g
derive (f :-: g) = derive f :-: derive g
derive (f :*: g) = f :*: derive g :+: derive f :*: g
derive (f :^: n) = Con n :*: f :^: (n - 1) :*: derive f

eval :: Fun -> Float -> Float
eval X         x = x
eval (Con n)   _ = fromIntegral n
eval (f :+: g) x = eval f x + eval g x
eval (f :-: g) x = eval f x - eval g x
eval (f :*: g) x = eval f x * eval g x
eval (f :^: n) x = eval f x ^ n

simplify :: Fun -> Fun
simplify (f :+: g) =
  case (simplify f, simplify g) of
    (Con m, Con n) -> Con (m + n)
    (Con 0, g)     -> g
    (f, Con 0)     -> f
    (f, g)         -> f :+: g
simplify (f :-: g) =
  case (simplify f, simplify g) of
    (Con m, Con n) -> Con (m - n)
    (f, Con 0)     -> f
    (f, g)         -> f :-: g
simplify (f :*: g) =
  case (simplify f, simplify g) of
    (Con m, Con n) -> Con (m * n)
    (Con 0, _)     -> Con 0
    (_, Con 0)     -> Con 0
    (Con 1, g)     -> g
    (f, Con 1)     -> f
    (f, g)         -> f :*: g
simplify (f :^: n) =
  case simplify f of
    Con m          -> Con (m ^ n)
    f | n == 0     -> Con 1
    f | n == 1     -> f
    (f :^: m)      -> f :^: m * n
    f              -> f :^: n
simplify f = f
