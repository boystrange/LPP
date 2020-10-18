---
title: Fibonacci logaritmico
---

## Descrizione del problema

In questo caso di studio illustriamo una realizzazione efficiente
della funzione che calcola il $k$-esimo numero di Fibonacci in un
tempo proporzionale a $\log_2 k$. Discutiamo la realizzazione
ricorsiva per Haskell, ma il principio su cui si basa è applicabile
anche in una versione iterativa.  Il "trucco" per ottenere una
realizzazione efficiente consiste nel riuscire a definire una
funzione che calcola $F_k$ per mezzo della $k$-esima potenza di un
opportuno elemento $A$. è noto, infatti, che la $k$-esima potenza di
$A$ è calcolabile in un tempo proporzionale a $\log_2 k$, osservando
che

$$
  A^k =
  \begin{cases}
    \mathbf{1} & \text{se $k = 0$}
    \\
    A^{k/2} \times A^{k/2} & \text{se $k > 0$ ed è pari}
    \\
    A \times A^{\lfloor k/2\rfloor} \times A^{\lfloor k/2\rfloor} & \text{se $k$ è dispari}
  \end{cases}
$$

dove $\mathbf{1}$ rappresenta l'elemento neutro dell'operazione di
moltiplicazione $\times$ usata in questo contesto.  L'aspetto chiave
di questa formulazione di $A^k$ è che nei due casi non banali è
sufficiente calcolare $A^{\lfloor k/2\rfloor}$ **una volta** e
**riutilizzare** tale risultato **due volte** per determinare $A^k$.

Nel caso specifico della sequenza di Fibonacci, prendiamo come $A$ la
seguente matrice $2\times 2$

$$
  A = \left(
  \begin{array}{@{}cc@{}}
    1 & 1 \\
    1 & 0
  \end{array}
  \right),
$$

come operazione $\times$ la moltiplicazione matriciale, e come
elemento neutro $\mathbf{1}$ la matrice identità di dimensioni
$2\times 2$. Ora dimostriamo, per induzione su $k$, che

$$
  A^k =
  \left(
    \begin{array}{@{}cc@{}}
      F_{k+1} & F_k \\
      F_k & F_{k-1}
    \end{array}
  \right)
$$

dove assumiamo, per convenzione, che $F_{-1} = 1$. Per $k=0$ abbiamo

$$
  A^0 =
  \left(
    \begin{array}{@{}cc@{}}
      1 & 0 \\
      0 & 1
    \end{array}
  \right)
  =
  \left(
    \begin{array}{@{}cc@{}}
      F_{k+1} & F_k \\
      F_k & F_{k-1}
    \end{array}
  \right)
$$

Per $k>0$ deriviamo

$$
  A^k
  = A \times A^{k-1}
  =
  \left(
    \begin{array}{@{}cc@{}}
      1 & 1 \\
      1 & 0
    \end{array}
  \right)
  \times
  \left(
    \begin{array}{@{}cc@{}}
      F_k & F_{k-1} \\
      F_{k-1} & F_{k-2}
    \end{array}
  \right)
  =
  \left(
    \begin{array}{@{}cc@{}}
      F_k + F_{k-1} & F_{k-1} + F_{k-2} \\
      F_k & F_{k-1}
    \end{array}
  \right)
  =
  \left(
    \begin{array}{@{}cc@{}}
      F_{k+1} & F_k \\
      F_k & F_{k-1}
    \end{array}
  \right)
$$

in cui le uguaglianze seguono, procedendo da sinistra verso destra,
dalla definizione di $A^k$, dall'ipotesi induttiva, dalla
definizione di moltiplicazione matriciale, e dalla definizione della
sequenza di Fibonacci.

## Implementazione in Haskell

Per la realizzazione efficiente di `fibonacci` è necessario lavorare
con matrici $2 \times 2$ di numeri di tipo `Integer`. Tra le varie
rappresentazioni possibili di queste matrici, scegliamo di usare una
quadrupla (una tupla con 4 elementi). In altre parole, la tupla

``` haskell
	(a, b, c, d)
```

rappresenta la matrice con righe `(a, b)` e `(c, d)`. Per comodità,
possiamo definire un **alias di tipo** con un nome conciso e
significativo per il tipo di queste tuple:

``` haskell
type Matrice = (Integer, Integer, Integer, Integer)
```

È evidente che sarebbe possibile anche una rappresentazione più
strutturata, facendo uso di tuple all'interno di tuple:

``` haskell
	((a, b), (c, d))
```

Questa seconda rappresentazione è più vicina all'idea di matrice
come struttura bidimensionale, ma non porta altri vantaggi pratici
ai fini del problema in oggetto, pertanto utilizzeremo il tipo
`Matrice` definito qui sopra.

Una volta scelta la rappresentazione delle matrici, è necessario
realizzare le operazioni di moltiplicazione e potenza. Per la prima
avremo

``` haskell
mul :: Matrice -> Matrice -> Matrice
mul (a₁₁, a₁₂, a₂₁, a₂₂) (b₁₁, b₁₂, b₂₁, b₂₂) =
  (a₁₁ * b₁₁ + a₁₂ * b₂₁,
   a₁₁ * b₁₂ + a₁₂ * b₂₂,
   a₂₁ * b₁₁ + a₂₂ * b₂₁,
   a₂₁ * b₁₂ + a₂₂ * b₂₂)
```

e per la seconda

``` haskell
pow :: Matrice -> Int -> Matrice
pow a k | k == 0         = (1, 0, 0, 1)
        | k `mod` 2 == 0 = b `mul` b
        | otherwise      = a `mul` b `mul` b
  where
    b = a `pow` (k `div` 2)
```

Notiamo l'uso infisso delle funzioni `mul` e `pow`. Questo è
possibile racchiudendo il nome di tali funzioni tra backtick,
esattamente come avviene per le funzioni di libreria `div` e `mod`.
Con `pow` a disposizione, la funzione `fibonacci` efficiente è
realizzata come segue

``` haskell
fibonacci :: Int -> Integer
fibonacci k = risultato
  where
    (_, risultato, _, _) = (1, 1, 1, 0) `pow` k
```

in cui il pattern a sinistra di `=` nella definizione locale che
segue il `where` ci consente di dare un nome all'elemento della
matrice che siamo interessati a restituire come risultato.

Per avere un'idea dell'efficienza di questa realizzazione di
`fibonacci`, è possibile confrontare il tempo di esecuzione
necessario a valutare la seguente espressione per le varie versioni
presentate qui e [nel precedente caso di
studio](Iterazione.html). Tenere presente che la versione più lenta
di `fibonacci` richiede un tempo di calcolo significativo (superiore
ai 10 secondi) già intorno al 35-esimo numero di Fibonacci.

``` haskell
fibonacci 100000
```
