---
title: Funzioni ricorsive
---

In Haskell non ci sono comandi di assegnamento o comandi
iterativi. L’unico modo per esprimere computazioni ripetute è per
mezzo di funzioni ricorsive, ovvero funzioni in cui il valore
prodotto può essere ottenuto per mezzo di una applicazione della
funzione stessa che viene definita.

## Definizioni ricorsive

Un tipico esempio di funzione definibile ricorsivamente è quella che
calcola il fattoriale di un numero naturale $n$. Ricordando che il
fattoriale di $n$, denotato da $n!$, è il prodotto dei numeri da 1 a
$n$ e che il fattoriale di 0 è 1 per convenzione, la funzione
fattoriale può essere espressa matematicamente come

$$
	n! = \left\{
	\begin{array}{ll}
		1 & n = 0 \\
		n \times (n - 1)! & n > 0 \\
	\end{array}
	\right.
$$

e in codice Haskell come illustrato qui sotto:

```haskell
fattoriale :: Int -> Int
fattoriale n | n == 0 = 1
             | otherwise = n * fattoriale (n - 1)
```

```haskell
fattoriale 0
fattoriale 2
fattoriale 10
```
{:.run}

## Pattern e funzioni a più equazioni

Fino ad ora abbiamo scritto funzioni dando **nomi** simbolici (come
`n` o `x`) ai loro argomenti. In generale, è possibile usare
cosiddetti **pattern** per descrivere la forma degli argomenti a cui
una particolare equazione si applica. Ad esempio, è possibile
riformulare la funzione fattoriale nel modo seguente:

```haskell
fattoriale :: Int -> Int
fattoriale 0 = 1
fattoriale n = n * fattoriale (n - 1)
```

```haskell
fattoriale 0
fattoriale 2
fattoriale 10
```
{:.run}

Qui abbiamo usato **due** equazioni distinte per definire
`fattoriale`. La prima equazione fa uso del pattern `0` per indicare
che si applica esclusivamente al caso in cui l’argomento della
funzione è proprio pari a `0`. La seconda equazione, in cui il
pattern è `n`, si applica in tutti i casi rimanenti.

Le equazioni di una definizione vengono provate dalla prima
all’ultima, fino a trovare quella in cui l’argomento fornito alla
funzione è descritto dal pattern di quella equazione. Ne segue che
l’ordine delle equazioni è importante: invertendo le equazioni qui
sopra, la definizione di `fattoriale` non sarebbe ben fondata, dal
momento che l’equazione con pattern `n` si applicherebbe a qualsiasi
argomento e non si raggiungerebbe mai il **caso base**.

Un altro esempio tipico di funzione ricorsiva è quella che calcola
l’$n$-esimo numero nella sequenza di Fibonacci. Tale sequenza inizia
con i numeri 0 e 1 ed ogni numero successivo è dato dalla somma dei
due precedenti. Dunque, i primi numeri nella sequenza di Fibonacci
sono

$$
	0, 1, 1, 2, 3, 5, 8, 13, 21, \dots
$$

Possiamo definire la funzione che calcola l’$n$-esimo numero nella
sequenza di Fibonacci come una funzione ricorsiva con due casi base:

```haskell
fibonacci :: Int -> Int
fibonacci 0 = 0
fibonacci 1 = 1
fibonacci n = fibonacci (n - 1) + fibonacci (n - 2)
```

```haskell
fibonacci 0
fibonacci 2
fibonacci 10
```
{:.run}

## Esercizi

1. Definire ricorsivamente la funzione che calcola la somma dei
   primi $n$ numeri naturali.
   ```haskell
   somma :: Int -> Int
   somma 0 = 0
   somma n = n + somma (n - 1)
   ```
   {:.solution}

2. Definire una funzione `pow2 :: Int -> Int` che, applicata a un
   numero intero $n$ non negativo, calcoli $2^n$ senza usare gli
   operatori `^` e `**` di Haskell.
   ```haskell
   pow2 :: Int -> Int
   pow2 0 = 1
   pow2 n = 2 * pow2 (n - 1)
   ```
   {:.solution}

3. Definire una funzione `bits :: Int -> Int` che, applicata a un
   numero intero $n$ non negativo, calcoli il numero di bit a 1
   nella rappresentazione binaria di $n$.
   ```haskell
   bits :: Int -> Int
   bits n | n == 0         = 0
          | n `mod` 2 == 0 = bits (n `div` 2)
          | otherwise      = 1 + bits (n `div` 2)
   ```
   {:.solution}

4. Definire una funzione `potenzaDi2 :: Int -> Bool` che, applicata a un
   numero intero $n$ non negativo, restituisca `True` se $n$ è una
   potenza di 2 e `False` altrimenti.
   ```haskell
   potenzaDi2 :: Int -> Bool
   potenzaDi2 0 = False
   potenzaDi2 1 = True
   potenzaDi2 n = n `mod` 2 == 0 && potenzaDi2 (n `div` 2)
   ```
   {:.solution}
