---
title: Liste
---

Una **lista** è una sequenza **omogenea** di elementi. Il fatto che
la sequenza sia omogenea significa che gli elementi della lista
hanno tutti lo stesso tipo. In questa scheda illustriamo alcuni modi
di costruire liste e alcune funzioni predefinite che lavorano con le
liste.

## Creazione diretta di liste

Esistono vari modi per creare liste, il più diretto dei quali
consiste nell’elencare gli elementi della lista tra parentesi
quadre, separati da virgole:

```haskell
[]                 -- lista vuota
[1]                -- lista che contiene il solo numero 1
[1, 2, 3]          -- lista con i numeri 1, 2 e 3
[0.5, 3]           -- lista con i numeri floating-point 0.5 e 3
[True, False]      -- lista con i valori True e False
[[], [1, 2], [3]]  -- lista di liste di numeri
```

Laddove gli elementi di una lista sono di un tipo per il quale
esiste una relazione d’ordine (per esempio, per i numeri) allora è
possibile creare una lista con tutti gli elementi appartenenti a un
intervallo. Ad esempio:

```haskell
[1..10]     -- lista con i numeri (interi) da 1 a 10
[1..]       -- lista con tutti i numeri (interi) da 1 in avanti
```

Nel secondo caso vediamo un esempio di creazione di *lista
infinita*. In quanto tale, la sua visualizzazione non ha mai fine e
bisogna interromperla in GHCi premendo `CTRL-C`.

## Costruttori canonici

Ogni lista può essere costruita a partire da due *costruttori
canonici* indicati dai simboli `:` e `[]`. Quest’ultimo, come
abbiamo visto poco fa, rappresenta la lista vuota. Il costruttore
`:` -- pronunciato tradizionalmente *cons* dall’abbreviazione di
*constructor* -- crea una lista a partire da un elemento e da
un’altra lista. In particolare

```haskell
X : L
```

è la lista che ha come primo elemento `X` e che continua come la
lista `L`. In gergo, `X` ed `L` sono rispettivamente la **testa**
e la **coda** della lista `X : L`. Ad esempio, la lista

```haskell
1 : 2 : 3 : []
```

ha testa `1` e coda `2 : 3 : []` o, equivalentemente, `[2, 3]`,
esattamente come la lista `[1, 2, 3]` vista prima. È possibile
convincersi di questo fatto osservando che le due liste sono a tutti
gli effetti uguali:

```haskell
[1, 2, 3] == 1 : 2 : 3 : []
```

Questo esempio ci permette anche di apprezzare il fatto che `:` è
un operatore *associativo a destra*:

```haskell
1 : 2 : 3 : [] == 1 : (2 : (3 : []))
```

È importante sottolineare che il costruttore `:` *non modifica* le
liste già esistenti, ma si limita a crearne una nuova con la
proprietà descritta.

## Il tipo delle liste

Se `L` è una lista di elementi di tipo `T`, allora `L` ha tipo
`[T]`. Ovvero, il tipo di una lista si ottiene mettendo tra
parentesi quadre il tipo dei suoi elementi:

``` haskell
:t []
:t [1, 2, 3]
:t [0.5, 3]
:t [True, False]
:t [[], [1, 2], [3]]
```

Vale la pena commentare alcuni di questi tipi:

* `[]` ha tipo `[a]` dove `a` rappresenta un tipo sconosciuto. In
  assenza di elementi della lista, Haskell non è in grado di
  imparare nulla di più sul tipo della lista.
* `[1, 2, 3]` ha tipo `Num a => [a]`, coerentemente col fatto che
  una costante come `1` ha tipo `Num a => a` per quanto [visto in
  precedenza](Tipi.html).
* `[0.5, 3]` ha tipo `Fractional a => [a]`, coerentemente col fatto
  che una costante come `0.5` ha tipo `Fractional a => a`.

L'operatore `::` che forza il tipo di un'espressione può essere
usato anche con le liste:

``` haskell
:t [] :: [Int -> Int]
:t [1, 2, 3] :: [Int]
:t [0.5, 3] :: [Float]
```

## Operatori e funzioni su liste

Le liste sono una struttura dati di primaria importanza in ogni
linguaggio di programmazione funzionale e la libreria standard di
Haskell contiene un gran numero di operatori e funzioni predefiniti
per lavorare con le liste. Qui ne descriviamo alcune tra le più
importanti.

La funzione

``` haskell
length :: [a] -> Int
```

può essere usata per calcolare la *lunghezza* di una lista:

```haskell
length []
length [1, 2, 3]
length [True, False]
```

Come evidenziato dall’ultimo esempio, `length` può essere applicata
a liste di elementi di tipo arbitrario.

<!-- Le funzioni `head` e `tail` restituiscono rispettivamente la testa e -->
<!-- la coda di una lista non vuota: -->

<!-- ``` haskell -->
<!-- head [1, 2, 3] -->
<!-- tail [1, 2, 3] -->
<!-- ``` -->

<!-- Se applicate alla lista vuota, `head` e `tail` causano il lancio di -->
<!-- un'eccezione. In altre parole, `head` e `tail` sono **funzioni -->
<!-- parziali** definite solo per alcuni elementi del loro dominio: -->

<!-- ``` haskell -->
<!-- head [] -->
<!-- tail [] -->
<!-- ``` -->

<!-- **Attenzione**: nella pratica è abbastanza raro usare le funzioni -->
<!-- `head` e `tail`. Vedremo in seguito un modo più dichiarativo e -->
<!-- robusto di accedere agli elementi di una lista esaminandone la -->
<!-- struttura. -->

Le funzioni `sum` e `product` possono essere usate per calcolare
rispettivamente la **somma** ed il **prodotto** degli elementi di
liste di numeri:

``` haskell
sum [1, 2, 3]
product [4, 5, 6]
```

Se applicate alla lista vuota, `sum` e `product` restituiscono
rispettivamente 0 (la somma di zero numeri) ed 1 (il prodotto di
zero numeri). Non a caso 0 e 1 sono gli elementi neutri delle due
operazioni.

``` haskell
sum []
product []
```

L'operatore `++` -- detto **append** -- **concatena** due liste `xs`
ed `ys`, creando una terza lista che contiene tutti gli elementi di
`xs` seguiti da tutti gli elementi di `ys`:

```haskell
[1, 2, 3] ++ [4, 5, 6]
[1] ++ [2] ++ [3] == [1, 2, 3]
```

L’operazione di concatenazione è **associativa** ma **non
commutativa** e ha `[]` come elemento neutro:

```haskell
[1] ++ ([2] ++ [3]) == ([1] ++ [2]) ++ [3]
[1, 2] ++ [3] /= [3] ++ [1, 2]
[1, 2] ++ [] == [1, 2] && [] ++ [1, 2] == [1, 2]
```

<!-- Infine, l’operatore `!!` può essere usato per leggere l’elemento che -->
<!-- si trova in una determinata posizione specificata tramite un -->
<!-- indice. Il primo elemento ha indice 0, il secondo elemento ha indice -->
<!-- 1, ecc: -->

<!-- ```haskell -->
<!-- [1, 2, 3] !! 0 -->
<!-- [1, 2, 3] !! 1 -->
<!-- [1, 2, 3] !! 3 -->
<!-- ``` -->

<!-- Nell’ultimo caso viene lanciata un'eccezione in quanto si tenta di -->
<!-- accedere al quarto elemento (quello con indice 3) in una lista che -->
<!-- ne contiene solo 3. -->

## Libreria standard

Riepiloghiamo il titolo dei costruttori e delle funzioni viste in
questa sezioni per operare sulle liste:

``` haskell
[]      :: [a]               -- lista vuota
(:)     :: a -> [a] -> [a]   -- cons, costruttore della lista non vuota
length  :: [a] -> Int        -- lunghezza di una lista
sum     :: Num a => [a] -> a -- somma degli elementi di una lista
product :: Num a => [a] -> a -- prodotto degli elementi di una lista
(++)    :: [a] -> [a] -> [a] -- concatenazione di due liste
```

## Esercizi

1. Scrivere la lista con i primi 10 numeri primi.
   ```haskell
   [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
   ```
   {:.solution}
2. Ricordando che gli elementi di una lista devono avere tutti lo
   stesso tipo, quali delle seguenti espressioni sono ben tipate?
   Verificare le risposte usando GHCi:
   ```haskell
   [1, 2 + 3]
   [True, 2 == 3]
   [1, True]
   [[1], []]
   [[1], False]
   1 : 2
   [[], [[2.5, 3], 4 : 5 : []]]
   ```
3. Definire una funzione **non ricorsiva** `media :: [Int] -> Float`
   per calcolare la media aritmetica degli elementi di una lista di
   numeri. La funzione non deve necessariamente restituire un
   risultato significativo se la lista è vuota.
   ```haskell
   media :: [Int] -> Float
   media xs = fromIntegral (sum xs) / fromIntegral (length xs)
   ```
   {:.solution}
4. Definire una funzione **non ricorsiva** per calcolare il
   fattoriale di un numero naturale.
   ```haskell
   fattoriale :: Int -> Int
   fattoriale n = product [2..n]
   ```
   {:.solution}
5. Senza usare la sintassi $[m..n]$, definire una funzione ricorsiva
   `intervallo :: Int -> Int -> [Int]` che, applicata a due numeri
   interi $m$ ed $n$, crei la lista dei numeri compresi
   nell'intervallo $[m,n]$, estremi inclusi. La funzione deve
   restituire la lista vuota nel caso in cui l'intervallo sia vuoto,
   ovvero se $m > n$.
   ^
   ```haskell
   intervallo :: Int -> Int -> [Int]
   intervallo m n | m > n     = []
                  | otherwise = m : intervallo (m + 1) n
   ```
   {:.solution}
6. Definire una funzione `primi :: Int -> [Int]` che, applicata a un
   numero intero $n$, crei la lista dei numeri primi da 2 a
   $n$. Utilizzare la funzione `primo` [discussa in
   precedenza](Iterazione.html) per determinare se un numero è
   primo.
   ```haskell
   primi :: Int -> [Int]
   primi n = aux 2
     where
	   aux k | k > n     = []
	         | primo k   = k : aux (k + 1)
             | otherwise = aux (k + 1)
   ```
   {:.solution}
