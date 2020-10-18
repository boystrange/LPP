
type Matrice = (Integer, Integer, Integer, Integer)

mul :: Matrice -> Matrice -> Matrice
mul (a₁₁, a₁₂, a₂₁, a₂₂) (b₁₁, b₁₂, b₂₁, b₂₂) =
  (a₁₁ * b₁₁ + a₁₂ * b₂₁,
   a₁₁ * b₁₂ + a₁₂ * b₂₂,
   a₂₁ * b₁₁ + a₂₂ * b₂₁,
   a₂₁ * b₁₂ + a₂₂ * b₂₂)

pow :: Matrice -> Int -> Matrice
pow a k | k == 0         = (1, 0, 0, 1)
        | k `mod` 2 == 0 = b `mul` b
        | otherwise      = a `mul` b `mul` b
  where
    b = a `pow` (k `div` 2)

slow :: Int -> Integer
slow 0 = 0
slow 1 = 1
slow n = slow (n - 1) + slow (n - 2)

fast :: Int -> Integer
fast = aux 0 1
  where
    aux m _ 0 = m
    aux m n k = aux n (m + n) (k - 1)

faster :: Int -> Integer
faster k = risultato
  where
    (_, risultato, _, _) = (1, 1, 1, 0) `pow` k

