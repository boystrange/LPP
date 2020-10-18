---
title: Dall'iterazione alla ricorsione
---

## Descrizione del problema

In Haskell, lo strumento fondamentale per la realizzazione di
algoritmi iterativi è la **ricorsione**. Tuttavia, vi sono casi in
cui la versione ricorsiva di un algoritmo iterativo non è immediata
da individuare oppure è obiettivamente inefficiente. Un tipico
esempio è la funzione che calcola il $k$-esimo numero nella sequenza
di Fibonacci (che chiameremo per brevità "funzione di
Fibonacci"). La sua versione funzionale/ricorsiva è indubbiamente
elegante, ma ha complessità esponenziale in $k$:

``` haskell
fibonacci :: Int -> Integer
fibonacci 0 = 0
fibonacci 1 = 1
fibonacci k = fibonacci (k - 1) + fibonacci (k - 2)
```

In netto contrasto, una classica realizzazione imperativa/iterativa
della funzione di Fibonacci ha complessità lineare in $k$. Qui sotto
vediamo una versione in Java:

``` java
public static int fibonacci(int k) {
    assert k >= 0;
    int m = 0;
    int n = 1;
    while (k > 0) {
        n = n + m;
        m = n - m;
        k = k - 1;
    }
    return m;
}
```

Un altro esempio di algoritmo iterativo che non ammette un'ovvia
versione ricorsiva è quello che determina se un certo numero $n$ è
primo o no. Una realizzazione in Java di tale algoritmo è la
seguente:

``` java
public static boolean primo(int n) {
    assert n >= 0;
    int k = 2;
    while (k < n && n % k != 0) k++;
    return k == n;
}
```

In questo esempio, la difficoltà nell'individuare una versione
ricorsiva dell'algoritmo è dovuta al fatto che la primalità di un
certo numero $n$ è del tutto scorrelata dalla primalità di $n-1$ o
di un qualsiasi altro numero più piccolo di $n$. Di conseguenza, non
è ovvio come impostare il caso induttivo di una ipotetica funzione
ricorsiva equivalente.

In questo caso di studio vedremo come ottenere realizzazioni ricorsive
con complessità lineare della funzione di Fibonacci e del test di
primalità. La tecnica illustrata è generale e può essere usata
per trasformare algoritmi imperativi/iterativi in
funzionali/ricorsivi.

## Soluzione ricorsiva lineare di Fibonacci

Osserviamo che l'implementazione Java della funzione di Fibonacci
agisce su uno stato che comprende, oltre al parametro $k$ della
funzione, anche due variabili locali. L'idea è quella di impostare
una funzione ricorsiva che ha tanti argomenti quante sono le variabili
locali usate dall'algoritmo iterativo, simulando la **modifica** di
una variabile locale con una opportuna chiamata ricorsiva. Seguendo
questa intuizione, nel caso di `fibonacci` otteniamo una funzione
`fibonacciAux` definita come segue:

``` haskell
fibonacciAux :: Integer -> Integer -> Int -> Integer
fibonacciAux m _ 0 = m
fibonacciAux m n k = fibonacciAux n (m + n) (k - 1)
```

Abbiamo chiamato questa funzione `fibonacciAux` e non `fibonacci`
per sottolineare il fatto che tale funzione non risolve il problema
originario, bensì uno più generale. Più precisamente, se indichiamo
con $F_n$ l'$n$-esimo numero nella sequenza di Fibonacci, possiamo
dimostrare che

\begin{equation}
  \label{eq:fibonacciAux}
  \mathtt{fibonacciAux}~F_n~F_{n+1}~k = F_{n+k}
\end{equation}

per ogni $k\geq 0$.  Procediamo per induzione su $k$. Nel caso base,
quando $k=0$ abbiamo

$$
  \begin{array}{rcll}
    \mathtt{fibonacciAux}~F_n~F_{n+1}~k & = & F_n
    & \text{per definizione di fibonacciAux}
    \\
    & = & F_{n+k}
    & \text{dal momento che $k=0$}
  \end{array}
$$

Se $k>0$, allora abbiamo

$$
  \begin{array}{@{}r@{~}c@{~}ll@{}}
    \mathtt{fibonacciAux}~F_n~F_{n+1}~k & = & \mathtt{fibonacciAux}~F_{n+1}~(F_n+F_{n+1})~(k-1)
    & \text{per def. di fibonacciAux}
    \\
    & = & \mathtt{fibonacciAux}~F_{n+1}~F_{n+2}~(k-1)
    & \text{per definizione di $F_{n+2}$}
    \\
    & = & F_{n+1+k-1}
    & \text{per ipotesi induttiva}
    \\
    & = & F_{n+k}
  \end{array}
$$

Notiamo che il caso base di `fibonacciAux` corrisponde alla
condizioni di terminazione del ciclo `while` nella versione Java: se
`k` è 0 il risultato è `m`.  Dualmente, il caso ricorsivo di
`fibonacciAux` corrisponde all'esecuzione di una iterazione del
ciclo `while`: se `k` è maggiore di 0, allora il risultato è
ottenuto ponendo `m` a `n`, `n` a `m + n` e `k` a `k - 1`. Queste
modifiche di `m`, `n` e `k` sono ottenute nella versione Java con
assegnamenti che modificano lo stato. Nella versione Haskell
otteniamo un effetto analogo applicando ricorsivamente
`fibonacciAux` alle versioni modificate di `m`, `n` e `k`. Tra
l'altro, in questo modo non dobbiamo preoccuparci del fatto che `m`
ed `n` devono essere modificate con un gioco di prestigio di somme e
sottrazioni oppure usando una terza variabile di appoggio.

Resta il fatto che `fibonacciAux` **non è** la funzione che
risolve il problema originario, ma possiamo ottenere `fibonacci`
come semplice specializzazione di `fibonacciAux`:

``` haskell
fibonacci :: Int -> Integer
fibonacci = fibonacciAux 0 1
```

Il modo in cui `fibonacciAux` è applicata corrisponde
all'inizializzazione di `m` ed `n` nella versione Java.  Possiamo
ulteriormente raffinare questa soluzione osservando che l'utilità
della funzione ausiliaria `fibonacciAux` è limitata alla funzione
`fibonacci`. Per tale motivo ha senso definire `fibonacciAux` come
**funzione locale** di `fibonacci`, in un blocco di codice indentato
che segue la parola chiave `where`:

``` haskell
fibonacci :: Int -> Integer
fibonacci = aux 0 1
  where
    aux m _ 0 = m
    aux m n k = aux n (m + n) (k - 1)
```

Definire localmente la funzione ausiliaria ci consente, tra le altre
cose, di darle un nome più conciso senza rischiare conflitti con
altre funzioni omonime, e rende meno importante documentarla con una
annotazione di tipo esplicita, che dunque omettiamo.

## Soluzione ricorsiva del test di primalità

Come per `fibonacci`, anche l'implementazione Java del test di
primalità agisce su uno stato che comprende il parametro $n$ della
funzione e una variabile locale $k$ che viene fatta scorrere su tutti
i candidati divisori di $n$, da 2 a $n-1$. A differenza della funzione
di Fibonacci notiamo che solo $k$ cambia da una iterazione all'altra,
mentre $n$ non è mai modificato. Questo suggerisce una realizzazione
Haskell con una funzione ricorsiva che ha un unico argomento $k$, come
mostrato di seguito:

``` haskell
primo :: Int -> Bool
primo n = aux 2
  where
    aux k | k >= n         = k == n
          | n `mod` k == 0 = False
          | otherwise      = aux (k + 1)
```

Notiamo in particolare che la funzione ausiliaria `aux` può accedere
al parametro `n` della funzione `primo`, all'interno della quale è
localmente definita. Notiamo inoltre la solita corrispondenza tra
casi base di `aux` e condizioni di terminazione del ciclo nella
versione Java di `primo`. Il ciclo termina se `k >= n`, nel qual
caso abbiamo testato tutti i candidati divisori di `n` senza
trovarne alcuno, e dunque ritorniamo `True` o `False` a seconda che
`k` sia uguale o maggiore di `n`, rispettivamente. Il ciclo termina
anche se `k` divide `n`, il che significa che abbiamo trovato un
divisore di `n` e dunque possiamo concludere che `n` non è primo. Il
caso induttivo della ricorsione corrisponde a una iterazione del
ciclo, in cui ci limitiamo ad aggiornare `k` al candidato
successivo. Proprio come nel caso della funzione di Fibonacci, anche
qui l'applicazione `aux 2`, che dà il via alla ricorsione,
corrisponde all'inizializzazione di `k` nella versione Java
dell'algoritmo.

## Esercizi

1. Scrivere una funzione ricorsiva corrispondente al seguente algoritmo
   iterativo:
   ```java
   public static int fattoriale(int n) {
       assert n >= 0;
       int res = 1;
       while (n > 0) {
          res = res * n;
          n = n - 1;
       }
       return res;
   }
   ```

   ``` haskell
   fattoriale :: Int -> Int
   fattoriale = aux 1
	 where
	   aux res 0 = res
	   aux res n = aux (res * n) (n - 1)
   ```
   {:.solution}

2. Scrivere una funzione ricorsiva corrispondente al seguente algoritmo
   iterativo:
   ```java
   public static int bits(int n) {
	   assert n >= 0;
	   int bits = 0;
	   while (n > 0) {
		   bits = bits + n % 2;
		   n = n / 2;
	   }
	   return bits;
   }
   ```

   ``` haskell
   bits :: Int -> Int
   bits = aux 0
	 where
	   aux bits 0 = bits
	   aux bits n = aux (bits + n `mod` 2) (n `div` 2)
   ```
   {:.solution}

3. Scrivere una funzione ricorsiva corrispondente al seguente algoritmo
   iterativo:
   ```java
   public static int euclide(int m, int n) {
	   assert m > 0 && n > 0;
	   while (m != n)
		   if (m < n) n -= m; else m -= n;
	   return n;
   }
   ```

   ``` haskell
   euclide :: Int -> Int -> Int
   euclide m n | m == n    = m
			   | m < n     = euclide m (n - m)
			   | otherwise = euclide (m - n) n
   ```
   {:.solution}
