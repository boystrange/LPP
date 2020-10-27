---
title: Esercizi sulle liste
---

{% include links.md %}

## Esercizi su liste

1. Definire una funzione ricorsiva che, applicata a una lista non
   vuota di numeri $[a_1, a_2, \dots, a_n]$, restituisca [`True`] se
   l'ultimo elemento è uguale alla somma di quelli che lo precedono
   (ovvero se $a_1 + a_2 + \cdots + a_{n-1} = a_n$) e [`False`] altrimenti. Non
   è consentito l'uso di funzioni della libreria standard di
   Haskell.
   ^
   ``` haskell
   ultimoSomma :: (Eq a, Num a) => [a] -> Bool
   ultimoSomma = aux 0
     where
       aux somma [x] = somma == x
       aux somma (x : xs) = aux (somma + x) xs
   ```
   {:.solution}
2. Risolvere l'esercizio precedente facendo uso di funzioni della
   libreria standard di Haskell e senza definire funzioni ricorsive.
   ^
   ``` haskell
   ultimoSomma :: (Eq a, Num a) => [a] -> Bool
   ultimoSomma xs = head ys == sum (tail ys)
     where
       ys = reverse xs
   ```
   {:.solution}
3. Definire una funzione che, applicata a una lista **non vuota** di
   liste $l$, produca la lista delle liste in $l$ che hanno
   lunghezza massima.  Per esempio, tale funzione applicata a $[[],
   [3,4], [1,8,4], [3], [2,5], [9,8,4]]$ deve produrre $[[1,8,4],
   [9,8,4]]$.  Non è consentito l'uso della
   ricorsione. Suggerimento: usare la funzione di libreria [`maximum`].
   ^
   ``` haskell
   piuLunga :: [[a]] -> [[a]]
   piuLunga xs = filter ((== m) . length) xs
     where
       m = maximum (map length xs)
   ```
   {:.solution}
4. Ridefinire `map :: (a -> b) -> [a] -> [b]` in termini di [`foldr`]
   e senza fare uso esplicito della ricorsione.
   ^
   ``` haskell
   myMap :: (a -> b) -> [a] -> [b]
   myMap f = foldr ((:) . f) []
   ```
   {:.solution}
5. Ridefinire `filter :: (a -> Bool) -> [a] -> [a]` in termini di
   [`foldr`] e senza fare uso della ricorsione esplicita.
   ^
   ``` haskell
   myFilter :: (a -> Bool) -> [a] -> [a]
   myFilter p = foldr aux []
     where
       aux x xs | p x = x : xs
                | otherwise = xs
   ```
   {:.solution}

## Esercizi su sotto-liste

Diciamo che $l_1$ è **sotto-lista** di $l_2$ se $l_1$ può essere
ottenuta rimuovendo zero o più elementi da $l_2$. Per esempio
$[4,2]$ e $[3,0,1]$ sono sotto-liste di $[2,3,4,0,1,2]$ e $[]$ è una
sotto-lista di quasiasi altra lista.

1. Definire una funzione che, applicata a due liste $l_1$ ed $l_2$,
   restituisca [`True`] se $l_1$ è sotto-lista di $l_2$ e [`False`]
   altrimenti.
   ^
   ``` haskell
   sottoLista :: Eq a => [a] -> [a] -> Bool
   sottoLista [] _ = True
   sottoLista _ [] = False
   sottoLista (x : xs) (y : ys) | x == y = sottoLista xs ys
   sottoLista xs (_ : ys) = sottoLista xs ys
   ```
   {:.solution}
2. Definire una funzione che, applicata a una lista $l$, generi la
   lista di tutte le sotto-liste di $l$.  Non è consentito l'uso di
   funzioni della libreria standard di Haskell eccetto [`map`] e [`++`].
   ^
   ``` haskell
   sottoListe :: [a] -> [[a]]
   sottoListe [] = [[]]
   sottoListe (x : xs) = xss ++ map (x :) xss
     where
       xss = sottoListe xs
   ```
   {:.solution}
