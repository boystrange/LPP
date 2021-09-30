---
title: Funzioni anonime e sezioni
---

{% include links.md %}

In Haskell le funzioni sono *entità di prima classe*, nel senso che
è possibile usare le funzioni come ogni altro tipo di dato. È
possibile scrivere funzioni che accettano funzioni come argomento,
così come è possibile scrivere funzioni che restituiscono altre
funzioni come risultato. Non solo, per mezzo di cosiddette **lambda
espressioni** è possibile definire funzioni "al volo" laddove
necessario, proprio come è possibile inserire una costante numerica
o logica all'interno di una espressione qualsiasi.

## Funzioni anonime

A titolo di esempio, riconsideriamo la funzione `successore` vista
[in precedenza](Funzioni.md):

``` haskell
successore :: Int -> Int
successore x = x + 1
```

Questa definizione stabilisce che il valore prodotto dalla funzione
`successore` quando è applicata a un numero intero `x` è pari a `x +
1`. Un modo alternativo e del tutto equivalente di definire la
stessa funzione è il seguente:

``` haskell
successore :: Int -> Int
successore = \x -> x + 1
```

Questa definizione stabilisce che `successore` è la funzione che,
applicata a un numero intero `x`, produce `x + 1`. Si noti come
l'argomento `x` della funzione è passato da sinistra a destra del
simbolo `=`. L'espressione a destra del simbolo `=` è una **funzione
anonima** anche detta **lambda espressione**. In particolare

``` haskell
\x -> x + 1
```

è una espressione Haskell che rappresenta la funzione (senza nome)
che, applicata a un numero `x`, produce `x + 1`. Il simbolo `\` che
precede l'argomento della funzione richiama la forma della lettera
greca lambda $\lambda$, da cui deriva il nome di questa particolare
forma di espressione.

Per convincersi che le funzioni anonime sono espressioni a tutti gli
effetti, è possibile fare alcuni semplici esperimenti in cui si
*applica* una funzione anonima subito dopo averla definita, ma senza
averle dato un nome.

``` haskell
(\x -> x + 1) 2
(\x -> x >= 0) 2
(\x -> x + 1) (negate 2)
```
{:.run}

Come al solito, l'applicazione funzionale si indica ponendo funzione
e argomento una di fianco all'altro. In questi esempi, le parentesi
attorno alla funzione anonima sono necessarie in quanto, per
convenzione, il corpo di una funzione anonima si estende il più
possibile a destra della freccia `->`.

## Sezioni

In Haskell, si dice **sezione** un'espressione racchiusa tra
parentesi in cui un operatore binario viene applicato a uno solo dei
suoi due argomenti. A titolo di esempio, le espressioni

``` haskell
(1 +)
(`mod` 2)
```

sono sezioni. Nella prima è stato omesso l'operando destro
dell'operatore [`+`]. Nella seconda è stato omesso l'operando sinistro
dell'operatore [`mod`].

Le sezioni rappresentano funzioni il cui argomento è l'operando
mancante. Pertanto, le due sezioni illustrate qui sopra
rappresentano la funzione "successore" e la funzione "resto della
divisione per 2", rispettivamente.  Siccome non c'è un modo ovvio di
"visualizzare una funzione", la valutazione delle due sezioni
proposte qui sopra produce un errore, ma è possibile convincersi
della natura delle sezioni *applicandole* a un argomento:

``` haskell
(1 +) 2
(1 +) 3
(`mod` 2) 2
(`mod` 2) 3
```
{:.run}

Haskell **espande** le sezioni in funzioni anonime. Ad esempio,
avremo

```haskell
(1 +)     ~~> \x -> 1 + x
(`mod` 2) ~~> \x -> x `mod` 2
```

dove il simbolo `~~>` è da leggersi "si espande in". Nota:
l'espansione è fatta automaticamente dal compilatore Haskell ed il
simbolo `~~>` non fa parte della sintassi del linguaggio.

Occorre prestare attenzione al fatto che la funzione risultante
dall'espansione può variare in base alla proprietà di
**commutatività** dell'operatore. Per esempio, `(1 +)` e `(+ 1)`
sono sezioni diverse che però rappresentano sempre la funzione
"successore", in quando l'operatore [`+`] è commutativo. Al contrario,
le sezioni ``(`mod` 2)`` e ``(2 `mod`)`` rappresentano funzioni
diverse.

## Esercizi

1. Scrivere due funzioni anonime che stabiliscano se un numero è
   pari o dispari.
   ```haskell
   \x -> x `mod` 2 == 0        -- essere un numero pari
   \x -> x `mod` 2 /= 0        -- essere un numero dispari
   ```
   {:.solution}
2. Scrivere la funzione anonima "valore assoluto".
   ```haskell
   \x -> if x >= 0 then x else negate x
   ```
   {:.solution}
3. Ricordando che [`.`] è l'operatore di composizione funzionale,
   descrivere a parole le seguenti funzioni. Verificare le proprie
   risposte valutando in GHCi alcune applicazioni delle funzioni
   indicate. Suggerimento: può essere d'aiuto espandere le sezioni
   in lambda espressioni.
   1. `(< 10)`
   2. `(10 <)`
   3. ``(`mod` 2)``
   4. `(1 /)`
   5. `(+ 1) . (* 2)`
   6. `(* 2) . (+ 1)`
   7. ``(== 0) . (`mod` 2)``
   8. ``(/= 0) . (`mod` 2)``
   ^
   1. La funzione che applicata a un numero $x$ determina se $x$ è minore di 10
   2. La funzione che applicata a un numero $x$ determina se $x$ è maggiore di 10
   3. La funzione che applicata a un numero intero $x$ calcola il resto della della divisione di $x$ per 2
   4. La funzione $\frac{1}{x}$
   5. La funzione $2x + 1$
   6. La funzione $2(x + 1)$
   7. La funzione che applicata a un numero intero $x$ determina se $x$ è pari
   8. La funzione che applicata a un numero intero $x$ determina se $x$ è dispari
   {:.solution}
