---
title: Alberi binari di ricerca
---

## Descrizione del problema

In questo caso di studio sviluppiamo una libreria per rappresentare
e manipolare **alberi binari di ricerca**. Si ricorda che un albero
binario di ricerca è caratterizzato dal fatto che, fissato un
qualsiasi suo sotto-albero $T$ avente per radice un elemento $x$,
tutti gli elementi nel sotto-albero **sinistro** di $T$ sono **più
piccoli** di $x$ e tutti gli elementi nel sotto-albero **destro** di
$T$ sono **più grandi** di $x$.

## Un tipo algebrico per alberi binari

``` haskell
data Tree a = Leaf | Branch a (Tree a) (Tree a)
  deriving Show
```

``` haskell
:type Leaf
:type Branch 1 Leaf (Branch 2 Leaf Leaf)
```

``` haskell
empty :: Tree a -> Bool
empty Leaf = True
empty _    = False
```

``` haskell
depth :: Tree a -> Int
depth Leaf             = 0
depth (Branch _ t₁ t₂) = 1 + max (depth t₁) (depth t₂)
```

``` haskell
depth Leaf
depth (Branch 1 Leaf (Branch 2 Leaf Leaf))
```

``` haskell
elements :: Tree a -> [a]
elements Leaf             = []
elements (Branch x t₁ t₂) = elements t₁ ++ [x] ++ elements t₂
```

## Operazioni fondamentali

``` haskell
tmax :: Tree a -> a
tmax (Branch x _ Leaf) = x
tmax (Branch _ _ t)    = tmax t
```

``` haskell
insert :: Ord a => a -> Tree a -> Tree a
insert x Leaf = Branch x Leaf Leaf
insert x t@(Branch y t₁ t₂) | x == y    = t
                            | x < y     = Branch y (insert x t₁) t₂
                            | otherwise = Branch y t₁ (insert x t₂)
```

ascrizione

``` haskell
foldr insert Leaf [4, 2, 1, 3, 0, 5]
depth (foldr insert Leaf [4, 2, 1, 3, 0, 5])
```

``` haskell
delete :: Ord a => a -> Tree -> Tree a
delete _ Leaf = Leaf
delete x (Branch y t₁ t₂) | x < y = Branch y (delete x t₁) t₂
                          | x > y = Branch y t₁ (delete x t₂)
delete x (Branch _ t Leaf) = t
delete x (Branch _ Leaf t) = t
delete x (Branch _ t₁ t₂)  = Branch y (delete y t₁) t₂
  where
    y = tmax t₁
```

## Esercizi

1. Definire la funzione `tmin :: Tree a -> a` che restituisce
   l'elemento più piccolo in un albero binario di ricerca non vuoto.
   ^
   ``` haskell
   tmin :: Ord a => Tree a -> a
   tmin (Branch x Leaf _) = x
   tmin (Branch _ t _)    = tmin t
   ```
   {:.solution}
2. Definire una funzione `treeSort :: Ord a => [a] -> [a]` che
   ordina gli elementi di una lista usando un albero binario come
   struttura intermedia. Nota: usando l'implementazione di `insert`
   mostrata sopra è normale che eventuali elementi ripetuti nella
   lista da ordinare compaiano una sola volta nel risultato.
   ^
   ``` haskell
   treeSort :: Ord a => [a] -> [a]
   treeSort = elements . foldr insert Leaf
   ```
   {:.solution}
