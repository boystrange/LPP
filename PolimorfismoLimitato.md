---
title: Approfondimento sulle classi
---

## Classi predefinite

![](../assets/images/class_diagram.png)

Il diagramma qui sopra riassume alcune delle classi più importanti
predefinite nella libreria standard di Haskell.  Le classi sono
rappresentate dai riquadri rossi. Ogni classe è identificata da un
nome -- ad esempio `Eq` o `Num` -- e per ogni classe sono indicate
alcune funzioni/operazioni definite sui tipi istanza di quella
classe. Le linee continue descrivono la relazione di
**ereditarietà** tra le classi, in particolare la relazione $C \to
D$ indica che $C$ è **sotto-classe** di $D$, e dunque le operazioni
disponibili per le istanze di $D$ sono disponibili anche per le
istanze di $C$.  I riquadri verdi descrivono alcuni tipi di dato
primitivi, mentre le frecce tratteggiate mostrano le classi di cui
tali tipi sono istanza. Ad esempio, `Int` è istanza di `Bounded` e
di `Integral`, e dunque indirettamente di `Enum`, `Real`, `Num`,
`Ord`, `Eq`.

È possibile ottenere informazioni su una classe, incluse le
operazioni e le funzioni definite per le istanze di quella classe,
con il comando `:info` di GHCi.

``` haskell
:info Num
:info Eq
:info Ord
```

## Eq

`Eq` è la classe dei tipi sui quali sono definite le relazioni di
uguaglianza `==` e disuguaglianza `/=`. Molti tipi sono istanza di
`Eq`, ma non il tipo delle funzioni. In particolare, non è possibile
confrontare due funzioni per determinare se sono "uguali" o
"diverse".

``` haskell
:t (==)
:t (/=)
```

## Ord

`Ord` è la classe dei tipi per i quali esiste un **ordine
totale**. Su questi tipi sono definite le relazioni d'ordine `<`,
`>`, `<=` e `>=`, oltre al calcolo di minimo `min` e massimo `max`.

``` haskell
:t (<)
:t min
```

## Enum

`Enum` è la classe dei tipi "enumerati" i cui elementi hanno un
**successore** e un **predecessore**.

``` haskell
:t succ
:t pred
```

## Bounded

`Bounded` è la classe dei tipi "limitati" i quali hanno un elemento
più piccolo di tutti `minBound` e un elemento più grande di tutti
`maxBound`.

``` haskell
:t minBound
:t maxBound
```

## Num e sotto-classi

La classe `Num` comprende tutti i tipi che rappresentano numeri di
varia natura.

* Tutti i numeri supportano le usuali operazioni aritmetiche di
  somma `+`, sottrazione `-`, moltiplicazione `*`, valore assoluto
  `abs` e negazione `negate`.
* Sui tipi della classe `Integral` sono definite le operazioni di
  divisione intera `div` e resto della divisione intera `mod`.
* I tipi della classe `Fractional` rappresentano numeri "con
  virgola" e supportano le operazioni di divisione non intera `/` e
  calcolo del reciproco `recip`.
* I tipi della classe `RealFrac` supportano le operazioni di
  troncamento `truncate` e arrotondamento `round`.
* I tipi della classe `Floating` rappresentano numeri in virgola
  mobile e comprendono la rappresentazione di π, le funzioni di
  esponenziale `exp` e logaritmo `log`, la radice quadrata `sqrt` e
  l'esponenziazione `**`, le funzioni trigonometriche.

``` haskell
:t (+)
:t (/)
:t sin
```

## Esercizi

1. Usare GHCi per scoprire il più piccolo ed il più grande numero di
   tipo `Int`.
   ``` haskell
   minBound :: Int
   maxBound :: Int
   ```
   {:.solution}
2. Mostrare che le funzioni `succ` e `pred` della classe `Enum` sono
   *parziali*, ovvero non sempre definite per tutti i valori di un
   tipo istanza di `Enum`.
   ``` haskell
   pred (minBound :: Int)
   succ (maxBound :: Int)
   ```
   {:.solution}
3. C'è una caratteristica del diagramma delle classi qui sopra che
    lascia intendere che `Integer` sia un tipo di numeri interi di
    dimensione arbitraria. Quale?
   ^
   > `Integer` non è istanza di `Bounded`, dunque non c'è a priori
   > un più piccolo/grande valore di tipo `Integer`.
   {:.solution}
4. Immaginare le classi di cui può essere istanza il tipo `Bool`.
   ```haskell
   :info Bool
   ```
   {:.solution}
