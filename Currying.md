---
title: Funzioni a più argomenti e applicazione parziale
---

In Haskell ogni funzione ha *esattamente un argomento*. La tecnica
per rappresentare funzioni che lavorano su due o più argomenti è
detta **currying** e consiste nel rappresentare una funzione a $n$
argomenti come una "catena" di $n$ funzioni a un solo
argomento. Questa tecnica di rappresentazione delle funzioni a più
argomenti consente l'**applicazione parziale**, un meccanismo che
favorisce il **riuso** del codice e la **specializzazione** delle
funzioni.

## Funzioni a più argomenti

Una funzione a più argomenti si definisce elencando tutti gli
argomenti prima del simbolo `=`. Ad esempio, la funzione che somma
due numeri interi si può definire in questo modo:

``` haskell
addizione :: Int -> Int -> Int
addizione x y = x + y
```

Tralasciamo per un momento l'interpretazione del tipo `Int -> Int ->
Int` e concentriamoci su come applicare `addizione` ai suoi
argomenti. Come suggerisce la definizione stessa di `addizione`,
applicare una funzione a più argomenti si ottiene scrivendo (il nome
del)la funzione seguita da ciascun argomento.

```haskell
addizione 2 3
addizione (negate 2) 3
```
{:.run}

Per comprendere meglio la natura delle funzioni a più argomenti,
ripetiamo sulla funzione `addizione` l'esercizio della [sezione
precedente](Lambda.md), in cui abbiamo riscritto
`successore` usando una funzione anonima. Dal momento che
`addizione` ha due argomenti, avremo bisogno di due passaggi in cui
spostiamo ciascun argomento della funzione da sinistra a destra del
simbolo `=`. Procedendo un argomento alla volta abbiamo

``` haskell
addizione :: Int -> Int -> Int
addizione x = \y -> x + y
```

al primo passaggio e poi

``` haskell
addizione :: Int -> Int -> Int
addizione = \x -> \y -> x + y
```

al secondo. Quest'ultimo passaggio ci permette di dare una lettura
di `addizione` che ne rivela la natura: "`addizione` è una funzione
che, applicata a un numero intero `x`, produce una funzione che,
applicata a un numero intero `y`, produce `x + y`".

È importante sottolineare che tutte le varie definizioni di
`addizione` che abbiamo dato qui sono *equivalenti*, nel senso che
sono formulazioni sintatticamente diverse ma semanticamente uguali
della stessa funzione, anche in termini di codice prodotto dal
compilatore.

Abbiamo dunque conferma dei seguenti fatti riguardanti Haskell:

* Tutte le funzioni hanno esattamente un argomento;
* Le funzioni a più argomenti sono rappresentate come "catene" di
  funzioni a un solo argomento.

Questa rappresentazione di funzioni "a catena" si dice **currying**
in onore di Haskell Curry che per primo ha studiato questa
rappresentazione di funzioni a più argomenti.

## Associatività di freccia e applicazione

Una volta svelata la natura di `addizione`, possiamo interpretarne
correttamente il tipo `Int -> Int -> Int`. Ora sappiamo che
`addizione` è una funzione che, applicata a un numero di tipo `Int`,
produce una funzione la quale, applicata a un altro numero di tipo
`Int`, produce un numero di tipo `Int`. In altre parole, `addizione`
ha dominio `Int` e codominio `Int -> Int`. Scopriamo dunque che il
tipo freccia `->` è **associativo a destra** e che il tipo

``` haskell
Int -> Int -> Int
```

deve essere interpretato come

``` haskell
Int -> (Int -> Int)
```

Spostandoci dai tipi alle espressioni, abbiamo che l'applicazione

``` haskell
addizione 2 3
```

è da interpretare come l'applicazione di `addizione` a `2`, che ha
come risultato una nuova funzione la quale è a sua volta applicata a
`3`. Deduciamo quindi che l'operatore (invisibile) di applicazione
funzionale è **associativo a sinistra** e che l'espressione qui
sopra deve essere interpretata come

``` haskell
(addizione 2) 3
```

## Applicazione parziale

La possibilità di rappresentare funzioni a più argomenti in termini
di funzioni a un singolo argomento ha due conseguenze importanti nel
linguaggio.

La prima è che il linguaggio di programmazione risulta essere **più
semplice**, perché di fatto tutte le funzioni hanno esattamente un
argomento e le funzioni "a più argomenti" sono in un certo senso
solo illusorie. Nel seguito continueremo a parlare di "funzioni a
$n$ argomenti", ma sapendo che con questa terminologia si intende
una catena di $n$ funzioni a un solo argomento.

La seconda conseguenza è che, dato che le funzioni "a più argomenti"
vengono applicate un argomento alla volta, diventa apparentemente
possibile applicare una funzione a **meno argomenti** rispetto a
quelli che si aspetta. Si parla in questi casi di **applicazione
parziale** di una funzione. Per fare un esempio concreto, potremmo
chiederci che cos'è

``` haskell
addizione 1
```

ovvero il risultato dell'applicazione di `addizione` -- una funzione
virtualmente "a due argomenti" -- al solo argomento 1. La
valutazione di questa espressione in GHCi produce un errore, perché
come sappiamo `addizione 1` è una funzione di tipo `Int -> Int` e,
in generale, GHCi non è in grado di visualizzare in modo sensato una
funzione. Possiamo però dare un nome a questa funzione e fare alcuni
esperimenti per capire di che funzione si tratta:

``` haskell
mistero :: Int -> Int
mistero = addizione 1
```

Ora:

``` haskell
mistero 0
mistero 1
mistero 2
mistero 10
```

Come si evince dalla valutazione di queste espressioni, `mistero` si
comporta esattamente come la funzione `successore` definita in
precedenza. In effetti, se immaginiamo che l'applicazione funzionale
`F A` ha l'effetto di **sostituire** l'argomento `A` nel corpo della
funzione `F`, abbiamo

``` haskell
  addizione 1 = (\x -> \y -> x + y) 1 ~~> \y -> 1 + y
```

dove la prima uguaglianza segue dalla definizione di `addizione`
(quella in cui abbiamo espresso `addizione` con una lambda
espressione) mentre la *riduzione* `~~>` cattura l'effetto della
sostituzione di 1 (l'argomento) al posto di `x` in `\y -> x + y`.

Rissumendo, l'applicazione parziale ci permette di ottenere la
funzione `successore` avendo a disposizione la funzione `addizione`,
senza bisogno di definire `successore` esplicitamente come abbiamo
fatto in precedenza. La possibilità di **specializzare** funzioni
applicandole parzialmente è un'effetto collaterale del *currying*
che facilita il riuso del codice.

## Esercizi

1. Definire le funzioni `massimo :: Int -> Int -> Int` e `minimo ::
   Int -> Int -> Int` che calcolino rispettivamente il massimo e il
   minimo dei loro argomenti.
   ```haskell
   massimo :: Int -> Int -> Int
   massimo x y | x >= y    = x
               | otherwise = y

   minimo :: Int -> Int -> Int
   minimo x y | x <= y    = x
              | otherwise = y
   ```
   {:.solution}

2. Definire una funzione `potenza :: Int -> Int -> Int` che,
   applicata a due numeri interi $m$ ed $n$ con $n \geq 0$, calcoli
   $m^n$ senza fare uso degli operatori `^` e `**` di Haskell.
   ```haskell
   potenza :: Int -> Int -> Int
   potenza _ 0 = 1
   potenza m n = m * potenza m (n - 1)
   ```
   {:.solution}

3. Ridefinire `pow2` vista in un esercizio della [sezione
   precedente](Ricorsione.md) come applicazione parziale
   di `potenza`.
   ```haskell
   pow2 :: Int -> Int
   pow2 = potenza 2
   ```
   {:.solution}

4. Data la definizione
   ```haskell
   sottrazione :: Int -> Int -> Int
   sottrazione x y = x - y
   ```
   quale tra le funzioni già viste finora è esprimibile come
   applicazione parziale di `sottrazione`? Suggerimento: è una
   funzione della [libreria standard](Espressioni.md).
   ```haskell
   negate :: Int -> Int
   negate = sottrazione 0
   ```
   {:.solution}
