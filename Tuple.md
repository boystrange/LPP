---
title: Coppie e tuple
---

Una **tupla** è una sequenza **ordinata** e **finita** di elementi
non necessariamente omogenei. Ovvero, gli elementi di una tupla non
devono necessariamente avere tutti lo stesso tipo. In questa scheda
illustriamo alcuni modi di costruire tuple e come definire funzioni
che hanno tuple come argomenti.

## Creazione diretta di tuple

Per creare una **tupla** è sufficiente elencarne gli elementi
racchiusi tra parentesi tonde e separati da virgole:

``` haskell
(1, True)          -- Coppia con elementi 1 e True
(False, 2.5, True) -- Tripla con elementi False, 2.5 e True
```

Il **tipo** di una tupla ha la forma $(T_1, T_2, \dots, T_n)$ dove
$T_1$, ..., $T_n$ sono i tipi delle sue componenti.

``` haskell
:t (2.5, True)
:t (False, not)
:t (False, 2, True)
:t (False, (2, True))
```

Notiamo che è possibile creare tuple che contengono funzioni così
come è possibile creare tuple che contengono altre tuple. Gli ultimi
due esempi mostrano che `(False, 2, True)` e `(False, (2, True))`
sono profondamente diverse: la prima è una tripla; la seconda è una
coppia la cui seconda componente è un'altra coppia. Il fatto che
queste due tuple siano diverse significa anche che non è possibile
confrontarle con gli operatori `==` e `/=`, che invece si aspettano
operandi dello stesso tipo:

``` haskell
(False, 2, True) /= (False, (2, True))
```

## Pattern matching di tuple

È possibile accedere alle componenti di una tupla usando il pattern
matching, dando un nome alle componenti di una tupla che si vogliono
utilizzare. A titolo di esempio, rivisitiamo la funzione `addizione`
definita nella sezione sulle [funzioni a più
argomenti](Currying.html):

``` haskell
addizione :: (Int, Int) -> Int
addizione (x, y) = x + y
```

Il pattern `(x, y)` utilizzato nella definizione di `addizione`
specifica (come del resto già indicato nel tipo di `addizione`) che
la funzione si aspetta come argomento una coppia. In aggiunta, il
pattern specifica due nomi (`x` e `y`, scelti dal programmatore) che
possono essere usati nella parte destra della definizione laddove
necessario.

``` haskell
addizione (1, 2)
```

**Nota**: sebbene appaia naturale usare tuple per definire e
applicare funzioni a più argomenti, al punto che la sintassi
mostrata qui sopra coincide con quella adottata in linguaggi di
programmazione più tradizionali, in Haskell è più semplice, più
efficiente e più flessibile sfruttare il
[currying](Currying.html). [Vedremo dei casi](OrdineSuperiore.html)
in cui è comodo raggruppare argomenti multipli di una funzione in
una coppia, ma questi sono eccezioni che possono essere gestiti con
tecniche *ad hoc*.

## Esercizi

1. Definire una funzione `scambia :: (Int, Int) -> (Int, Int)` che,
   applicata a una coppia di numeri interi, restituisca la coppia
   con le componenti scambiate.
   ``` haskell
   scambia :: (Int, Int) -> (Int, Int)
   scambia (x, y) = (y, x)
   ```
   {:.solution}
2. Definire una funzione `ordina :: (Int, Int, Int) -> (Int, Int,
   Int)` che, applicata a una tripla di numeri interi, restituisca
   la tripla con le componenti ordinate in modo non
   decrescente.
   ``` haskell
   ordina :: (Int, Int, Int) -> (Int, Int, Int)
   ordina (a, b, c) | a > b = ordina (b, a, c)
   ordina (a, b, c) | b > c = ordina (a, c, b)
   ordina x = x
   ```
   {:.solution}
3. Un numero complesso può essere rappresentato da una coppia
   ordinata di numeri (per esempio, di tipo `Double`). Definire
   funzioni per sommare, negare e sottrarre numeri complessi.
   ``` haskell
   -- Definiamo un alias di tipo in modo che il nome Complesso sia
   -- una comoda abbreviazione per il tipo (Double, Double)
   type Complesso = (Double, Double)

   addizioneC :: Complesso -> Complesso -> Complesso
   addizioneC (a, b) (c, d) = (a + c, b + d)

   negazioneC :: Complesso -> Complesso
   negazioneC (a, b) = (negate a, b)

   sottrazioneC :: Complesso -> Complesso -> Complesso
   sottrazioneC x y = addizioneC x (negazioneC y)
   ```
   {:.solution}
