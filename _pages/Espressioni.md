---
title: Espressioni aritmetiche
tags: (+) (-) (*) div mod (^)
---

{% include links.md %}

## Numeri interi e operatori

In prima istanza l’interprete Haskell può essere usato come una
semplice calcolatrice. Inserendo una espressione — aritmetica, per
il momento — l’interprete la **valuta** e ne mostra il valore.

``` haskell
2               -- la costante intera 2
2 + 3           -- 2 più 3
2 - 3           -- 2 meno 3
2 * 3           -- 2 per 3
2 `div` 3       -- 2 diviso 3 (divisione intera con troncamento)
2 `mod` 3       -- il resto di 2 diviso 3 (divisione intera)
2 ^ 3           -- 2 alla 3
```

Gli operatori [`div`] e [`mod`] devono essere racchiusi tra **singoli
apici invertiti** (detti anche **backtick**) per poter essere usati
in notazione **infissa**, ovvero in mezzo ai loro operandi. Vedremo
in seguito che è anche possibile usarli senza apici, in notazione
prefissa.

Un **commento** inizia con due trattini consecutivi `--` e continua
fino alla fine della riga. Un **commento multilinea** è composto da
tutto il testo racchiuso tra `{-` e `-}`. I commenti multilinea si
possono anche annidare.

## Uso delle parentesi

Come al solito, le parentesi **tonde** possono essere utilizzate per
forzare l’associatività delle espressioni:

``` haskell
2 * 3 + 4
(2 * 3) + 4
2 * (3 + 4)
```
{:.run}

## Funzioni predefinite sui numeri interi

Per applicare una funzione al suo argomento si scrive il nome della
funzione **di fianco** all’argomento. Intuitivamente, lo **spazio**
che separa la funzione dal suo argomento svolge il ruolo di
operatore (invisibile) di **applicazione funzionale**:

``` haskell
negate 2
negate 2 + 3
negate (2 + 3)
abs 2 - 5
abs (2 - 5)
```
{:.run}

Come si nota dagli esempi, l’espressione `negate 2 + 3` viene
interpretata come `(negate 2) + 3` ovvero prima si applica la
funzione [`negate`] a `2` e _successivamente_ si somma il risultato
a `3`.  Al contrario, in `negate (2 + 3)` si applica la funzione
[`negate`] al risultato della somma di `2` e `3`.  In generale,
l’operatore (invisibile) di applicazione funzionale ha la **priorità
massima** tra tutti gli operatori di Haskell (inclusi quelli che
verranno introdotti in seguito).

## Associatività dell’applicazione funzionale

L’operatore (invisibile) di applicazione funzionale è associativo
**a sinistra**, questo significa che una espressione della forma `A
B C` viene interpretata come `((A B) C)`, ovvero `A` applicata a
`B`, ed il risultato dell’applicazione applicato a sua volta a `C`.

``` haskell
abs (negate 3)
abs negate 3
(abs negate) 3
```
{:.run}

Gli ultimi due esempi causano un **errore di tipo** in quanto si
cerca di applicare la funzione [`abs`], che si aspetta come argomento
un numero, a un’altra funzione ([`negate`]).

## Numeri con virgola e operatori

I numeri con virgola sono riconoscibili in quanto hanno il
separatore decimale `.` oppure un esponente `e`:

``` haskell
0.5
2.0
5.0e-8   -- 5.0 moltiplicato per 10 elevato alla -8
0.5e7    -- 0.5 moltiplicato per 10 elevato alla 7
```
{:.run}

A differenza di alcuni linguaggi, quando si usa il punto decimale
`.` sia la parte intera che quella frazionaria vanno specificate.

``` haskell
.5   -- errore
2.   -- errore
```
{:.run}

Gli operatori aritmetici sono utilizzabili anche su operandi con virgola:

``` haskell
1.5 + 2 * 3.5
(1.5 + 2) * 3.5
0.5 ^ 10
```
{:.run}

In aggiunta, l’operatore [`/`] indica la divisione (con
virgola). Notare la differenza tra [`/`] e [`div`]:

```haskell
7 / 2
7 `div` 2
7.0 / 2
7.0 `div` 2
```
{:.run}

Nell’ultimo esempio si ottiene un errore in quanto [`div`] funziona
esclusivamente su operandi interi.

## Esercizi

1. Scrivere un’espressione per calcolare la somma dei numeri da 1
   a 5. Il valore dell'espressione deve essere 15.
   ```haskell
   1 + 2 + 3 + 4 + 5
   ```
   {:.solution}
2. Scrivere un’espressione per calcolare il prodotto dei numeri da 1
   a 5. Il valore dell'espressione deve essere 120.
   ```haskell
   1 * 2 * 3 * 4 * 5
   ```
   {:.solution}
3. Scrivere un’espressione per calcolare la sommatoria \\(2^0 +
   2^1 + 2^2 + 2^3 + 2^4\\) delle prime 5 potenze di 2 usando gli
   operatori `+` e `^` e minimizzando il numero di parentesi
   utilizzate. Il valore dell'espressione deve essere 31.
   ```haskell
   2^0 + 2^1 + 2^2 + 2^3 + 2^4
   ```
   {:.solution}
4. Scrivere un'espressione per calcolare

   $$
	   \frac{1}{1 + \frac{1}{1 + \frac{1}{1 + \frac{1}{2}}}}
   $$

   minimizzando il numero di parentesi utilizzate tenendo condo
   della priorità degli operatori. Il valore dell'espressione deve
   essere 0.625.

   ```haskell
   1 / (1 + 1 / (1 + 1 / (1 + 1 / 2)))
   ```
   {:.solution}
