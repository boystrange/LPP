---
title: List comprehension
---

{% include links.md %}

Data l'importanza delle liste in tutti i programmi funzionali,
Haskell fornisce una notazione intuitiva per esprimere liste
derivate da altre liste.

## Generatori

È possibile generare una lista a partire da un'altra lista usando un
**generatore**. Ad esempio, l'espressione

``` haskell
[ x ^ 2 | x <- [1..10] ]
```

calcola la lista dei quadrati dei numeri interi da 1
a 10. L'espressione a sinistra della barra verticale `|` specifica
come calcolare ogni elemento della lista. Tale espressione fa uso di
un nome `x` definito dal **generatore** `x <- [1..10]`. Per ogni
valore `x` della lista `[1..10]`, si calcola `x ^ 2`. Dunque, la
forma qui sopra è equivalente a

``` haskell
map (^ 2) [1..10]
```

È possibile usare un numero qualsiasi di generatori, nel qual caso
vengono considerati tutti gli assegnamenti possibili dei nomi
definiti da tali generatori. Ad esempio

``` haskell
[ (x, y) | x <- [1..10], y <- [1..10] ]
```

calcola la lista di tutte le coppie formate da numeri compresi tra 1
e 10. È facile verificare che tale lista contiene 100 elementi:

``` haskell
length [ (x, y) | x <- [1..10], y <- [1..10] ]
```

Un generatore può fare riferimento a nomi definiti in generatori
precedenti. Ad esempio

``` haskell
[ (x, y) | y <- [1..10], x <- [1..y] ]
```

calcola la lista di tutte le coppie formate da numeri compresi tra 1
e 10 in cui la prima componente è minore o uguale alla seconda.

## Guardie

Si possono specificare **guardie** per filtrare gli elementi della
lista da generare. Ad esempio, l'espressione

``` haskell
[ (x, y) | x <- [1..10], y <- [1..10], x <= y ]
```

genera esattamente la lista dell'ultimo esempio nella sezione
precedente. Come per i generatori, anche le guardie possono essere
usate in numero arbitrario e possono fare riferimento ai nomi
definiti dai generatori che le precedono.

## Esercizi

1. Ridefinire [`map`] e [`filter`] usando solo list comprehension.
   ```haskell
   map :: (a -> b) -> [a] -> [b]
   map f xs = [ f x | x <- xs ]

   filter :: (a -> Bool) -> [a] -> [a]
   filter p xs = [ x | x <- xs, p x ]
   ```
   {:.solution}
2. Definire la funzione `primo :: Integral a => a -> Bool` nel modo
   più compatto possibile con una list comprehension.
   ``` haskell
   primo :: Integral a => a -> Bool
   primo n = [ d | d <- [2..n], n `mod` d == 0 ] == [n]
   ```
   {:.solution}
3. Diciamo che $(a,b,c)$ è una *terna pitagorica primitiva* se
   $a^2 + b^2 = c^2$ e $a$ e $b$ sono co-primi (cioè l'unico
   divisore che hanno in comune è 1). Definire nel modo più compatto
   possibile la funzione `terne :: Int -> [(Int, Int, Int)]` che,
   applicata a $n$, generi tutte le terne pitagoriche primitive tali
   che $a < b < c \leq n$.
   ``` haskell
   terne :: Int -> [(Int, Int, Int)]
   terne n = [ (a, b, c) | a <- [1..n]
                         , b <- [a + 1..n]
						 , c <- [b + 1..n]
						 , coprimi a b, a^2 + b^2 == c^2 ]
     where
       coprimi a b = mcd a b == 1

       mcd 0 n = n
       mcd m n | m > n = mcd n m
       mcd m n = mcd m (n - m)
   ```
   {:.solution}
