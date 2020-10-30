---
title: Tipi e classi
---

{% include links.md %}

Haskell è un linguaggio di programmazione **fortemente tipato**,
ovvero in cui solo le espressioni che rispettano alcune **regole di
tipo** sono compilate e valutate. La specifica precisa delle regole
di tipo di Haskell esula dagli scopi del corso. In questa scheda
riassumiamo alcune nozioni fondamentali sui tipi di Haskell.

## Tipi primitivi

In Haskell ci sono **tipi predefiniti** corrispondenti alle costanti
numeriche e logiche usate fino ad ora. In particolare:
* [`Int`] è il tipo dei **numeri interi a precisione finita**
  (indicativamente corrisponde al tipo `int` di Java);
* [`Integer`] è il tipo dei **numeri interi a precisione arbitraria**
  (la dimensione massima dei numeri interi di questo tipo è limitata
  solo dalla memoria del calcolatore);
* [`Float`] è il tipo dei **numeri in virgola mobile a precisione
  singola** (corrisponde al tipo `float` di Java);
* [`Double`] è il tipo dei **numeri in virgola mobile a precisione
  doppia** (corrisponde al tipo `double` di Java);
* [`Bool`] è il tipo dei valori booleani (indicativamente
  corrispondente al tipo `boolean` di Java).

È possibile chiedere a GHCi di mostrare il tipo di una costante e,
in generale, di una espressione usando il comando `:type` o la sua
abbreviazione `:t`. Ad esempio, nel caso delle costanti booleane:

``` haskell
:type True
:type False
```

Se si richiede il tipo di una costante numerica, il risultato non è
quello che ci si aspetta:

``` haskell
:type 1
:type 1.5
```

Il punto è che la costante `1` può avere *tipi diversi* a seconda
del contesto in cui è utilizzata. Potrebbe essere una costante
intera (a precisione finita) di tipo [`Int`], ma potrebbe anche essere
una costante intera (a precisione arbitraria) di tipo [`Integer`] o
una costante in virgola mobile a precisione singola di tipo [`Float`]
o una costante in virgola mobile a precisione doppia di tipo
[`Double`]. Da sola, la costante `1` non contiene abbastanza
informazioni per permettere ad Haskell di risolvere questa ambiguità
interpretativa, pertanto Haskell sostiene che il tipo di `1` ha la
forma

``` haskell
Num a => a
```

che è da leggersi come "un tipo sconosciuto `a` che è istanza della
classe [`Num`]". Intuitivamente, una **classe** è un insieme di tipi
per i quali sono definite un insieme comune di funzioni. Senza
entrare nei particolari, per il momento ci accontentiamo di
apprezzare che Haskell "capisce" che `1` deve essere un **numero**
di qualche tipo, anche se non è in grado di dire precisamente di che
tipo.

È però possibile **forzare** il tipo di un'espressione usando una
sintassi particolare:

``` haskell
:type 1 :: Int
:type 1 :: Integer
:type 1 :: Float
:type 1 :: Double
```

Un'espressione della forma `E :: T`, dove `E` è un'espressione e `T`
è un tipo, è semanticamente equivalente a (cioè ha lo stesso valore
di) `E`, ma il programmatore indica esplicitamente il tipo `T` che
si intende dare all'espressione. Il tipo `T` specificato dal
programmatore deve essere una istanza del tipo che Haskell ha
inferito automaticamente per `E`. Gli esempi qui sopra mostrano che
[`Int`], [`Float`] e [`Double`] sono tutte istanze della classe [`Num`].

Da notare che anche le costanti con la virgola, come `1.5`, non
comprendono sufficiente informazione per individuarne univocamente
il tipo:

``` haskell
:type 1.5
```

In questo caso, Haskell inferisce per `1.5` un tipo della forma

``` haskell
Fractional a => a
```

che indica come `1.5` abbia un tipo sconosciuto `a` istanza della
classe [`Fractional`], la classe dei tipi che rappresentano "numeri
con la virgola". In effetti, `1.5` potrebbe essere un numero in
virgola mobile a precisione singola o doppia, o anche un numero
razionale o complesso. Ad esempio, è possibile forzare il tipo di
`1.5` a [`Float`] o [`Double`]:

``` haskell
:type 1.5 :: Float
:type 1.5 :: Double
```

## Il tipo delle funzioni

Abbiamo avuto modo di constatare che una funzione è un'espressione
il cui tipo ha la forma `T -> S`, in cui `T` rappresenta il
**dominio** della funzione (è il tipo dei valori accettati come
argomento) mentre `S` rappresenta il **codominio** della funzione (è
il tipo del valori prodotti come risultato). Ad esempio:

``` haskell
:type not
:type negate
```

Quando si applica una funzione a un argomento, il tipo
dell'argomento deve coincidere (o essere istanza del) dominio della
funzione e il tipo dell'intera applicazione è il codominio della
funzione:

``` haskell
:type not True
:type negate 1
:type negate (1 :: Int)
:type negate (1 :: Integer)
```

Il tipo `Num a => a -> a` di [`negate`] è particolarmente interessante
perché molto ricco di informazione. Esso indica che [`negate`] è una
funzione che accetta argomenti di qualunque tipo `a` sia istanza di
[`Num`] e produce risultati dello stesso tipo dell'argomento,
qualunque esso sia:

``` haskell
:type negate (1 :: Int)
:type negate (1 :: Float)
:type negate (1 :: Double)
```

## Conversioni tra tipi numerici

L'operatore `::` non può essere usato per convertire numeri da un
tipo all'altro. Per esempio, un numero con virgola non può essere
convertito a numero intero semplicemente forzandone il tipo:

``` haskell
1.5 :: Int
```

Analogamente, un numero intero non può essere "promosso" a numero
con virgola:

``` haskell
(1 :: Int) :: Float
```

Per effettuare queste conversioni occorre applicare una apposita
funzione, scelta tra le seguenti:

``` haskell
fromIntegral :: (Integral a, Num b)      => a -> b
truncate     :: (RealFrac a, Integral b) => a -> b
round        :: (RealFrac a, Integral b) => a -> b
```

In particolare, [`fromIntegral`] promuove un qualsiasi numero intero
(il cui tipo è istanza della classe [`Integral`]) a qualsiasi altro
tipo di numero. Le funzioni [`truncate`] e [`round`] rispettivamente
troncano e arrotondano un numero frazionario (il cui tipo è istanza
della classe [`RealFrac`]) a un qualsiasi tipo di numero intero
(istanza della classe [`Integral`]).

``` haskell
fromIntegral (1 :: Int) :: Float
truncate 1.5
round 1.5
```

## Esercizi

1. Quali delle seguenti espressioni sono ben tipate? Verificare le
   risposte con GHCi:
   ```haskell
   1 `div` 2
   1.5 `div` 2
   1 / 2
   1.5 / 2
   (1 :: Int) / 2
   (1 :: Float) / 2
   (2 :: Int) + (3 :: Integer)
   (2 :: Float) <= 3
   (2 :: Float) < (3 :: Int)
   ```
2. Correggere le espressioni mal tipate dell'esercizio precedente
   **introducendo** opportune conversioni di tipo e senza rimuovere
   alcunché dell'espressione originale. In alcuni casi potrebbero
   essere possibili soluzioni diverse usando conversioni diverse.
   ```haskell
   truncate 1.5 `div` 2
   fromIntegral (1 :: Int) / 2
   fromIntegral (2 :: Int) + (3 :: Integer)
   round (2 :: Float) < (3 :: Int)
   ```
   {:.solution}
3. Concepire due espressioni il cui valore illustri chiaramente come
   [`Int`] sia un tipo a **precisione finita** (ci sono numeri troppo
   grandi per essere rappresentati con 32, 64 o 128 bit) e [`Integer`]
   sia un tipo a **precisione arbitraria** (ci sono numeri di tipo
   [`Integer`] che evidentemente non possono essere rappresentati in
   32, 64 o 128 bit).
   ```haskell
   (2 ^ 1024) :: Int
   (2 ^ 1024) :: Integer
   ```
   {:.solution}
