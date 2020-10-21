---
title: Tipi polimorfi e ricorsivi
---

## Tipi polimorfi

Nella scheda sui [costruttori con
argomenti](CostruttoriArgomenti.html) abbiamo definito un tipo
`ForseInt` per rappresentare "numeri interi o niente". È possibile
generalizzare il tipo del costruttore `Proprio` rendendo questo tipo
**polimorfo**. Il tipo che si ottiene è già definito nella libreria
standard di Haskell e si chiama `Maybe`:

``` haskell
data Maybe a = Nothing | Just a
```

Notiamo che a sinistra del simbolo `=` è ora definita una
**variabile di tipo** `a` che rappresenta il tipo dell'argomento del
costruttore `Just`. Applicando `Maybe` al tipo `Int` si ottiene un
tipo isomorfo a `ForseInt`, con la differenza che ora `Maybe` può
essere applicato a tipi diversi a seconda delle necessità.

``` haskell
Just 1 :: Maybe Int
Just True :: Maybe Bool
Just [0.5] :: Maybe [Float]
```

Così come `Maybe` è diventato un tipo polimorfo, i costruttori
`Nothing` e `Just` sono polimorfi anch'essi:

``` haskell
:type Nothing
:type Just
```

Occorre prestare attenzione al fatto che `Maybe` non è più un tipo
in senso stretto, ma piuttosto un **costruttore di tipo**. Possiamo
pensare a `Maybe` come a una funzione che, applicata a un tipo,
restituisca un altro tipo. Questa intuizione è suggerita anche dalla
sintassi `Maybe T`, che è analoga a usara per applicare una funzione
al suo argomento.

Un tipo può avere un numero arbitrario di parametri di tipo. Ad
esempio, il (costruttore di) tipo `Either` è definito nella libreria
standard di Haskell in questo modo:

``` haskell
data Either a b = Left a | Right b
```

I valori di tipo `Either T S` hanno una di due forme possibili:

* valori della forma `Left x` dove `x` è di tipo `T`, oppure
* valori della forma `Right y` dove `y` è di tipo `S`.

``` haskell
:type Left 1
:type Right True
:type [Left 1, Right True]
```

## Tipi ricorsivi

Il costruttore di un tipo di dato `T` può avere argomenti il cui
tipo è a sua volta (costruito con) `T`. Per esempio, è possibile
definire il tipo delle liste con la seguente dichiarazione, che è
isomorfa a quella predefinita nella libreria standard di Haskell.

``` haskell
data List a = Nil | Cons a (List a)
```

Notiamo in particolare che il costruttore `Cons` ha due argomenti,
il primo che rappresenta la **testa** di una lista di tipo `List a`
e ha tipo `a` e l'altro che rappresenta la **coda** di una lista di
tipo `List a` e ha a sua volta tipo `List a`.

``` haskell
Nil
Cons 1 Nil
Cons 1 (Cons 2 (Cons 3 Nil))
```

## Esercizi

1. Definire le seguenti funzioni, il cui comportamento si evince dal
   loro tipo.
   1. `maybeLength :: Maybe a -> Int`
   2. `maybeMap    :: (a -> b) -> Maybe a -> Maybe b`
   3. `maybeFilter :: (a -> Bool) -> Maybe a -> Maybe a`
   ^
   ``` haskell
   maybeLength :: Maybe a -> Int
   maybeLength Nothing  = 0
   maybeLength (Just _) = 1

   maybeMap :: (a -> b) -> Maybe a -> Maybe b
   maybeMap _ Nothing  = Nothing
   maybeMap f (Just x) = Just (f x)

   maybeFilter :: (a -> Bool) -> Maybe a -> Maybe a
   maybeFilter p (Just x) | p x = Just x
   maybeFilter _ _              = Nothing
   ```
   {:.solution}
2. Il tipo `Numero` (si veda la [sezione di
   esercizi](CostruttoriArgomenti.html#Esercizi) della traccia sui
   costruttori con argomenti) può essere rappresentato con il tipo
   `Either Int Float`. Ridefinire la funzione `somma :: Either Int
   Float -> Either Int Float -> Either Int Float` per sommare due
   numeri in modo tale che il risultato sia *floating-point* solo se
   necessario.
   ^
   ``` haskell
   somma :: Either Int Float -> Either Int Float -> Either Int Float
   somma (Left m)  (Left n)  = Left (m + n)
   somma (Left m)  (Right n) = Right (fromIntegral m + n)
   somma (Right m) (Left n)  = Right (m + fromIntegral n)
   somma (Right m) (Right n) = Right (m + n)
   ```
   {:.solution}
3. Definire la funzione `length :: List a -> Int` per calcolare la
   lunghezza di una lista.
   ^
   ``` haskell
   length :: List a -> Int
   length Nil         = 0
   length (Cons _ xs) = 1 + length xs
   ```
   {:.solution}
4. Uno **stream** è una sequenza infinita di elementi. Definire il
   tipo polimorfo `Stream a` degli **stream** di elementi di tipo
   `a` e le seguenti funzioni, il cui comportamento si evince dai
   loro nomi e tipi.
   1. `forever :: a -> Stream a`
   2. `from :: Enum a => a -> Stream a`
   3. `take :: Int -> Stream a -> [a]`
   ^
   ``` haskell
   data Stream a = Cons a (Stream a)

   forever :: a -> Stream a
   forever x = Cons x (forever x)

   from :: Enum a => a -> Stream a
   from x = Cons x (from (succ x))

   take :: Int -> Stream [a] -> [a]
   take 0 _           = []
   take n (Cons x xs) = x : take (n - 1) xs
   ```
   {:.solution}
