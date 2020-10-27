---
title: Proposizioni logiche
---

{% include links.md %}

## Valori booleani

In Haskell le costanti di verità — detta anche **valori booleani** —
sono rappresentate da [`True`] (vero) e [`False`] (falso). Si possono
usare gli operatori logici di congiunzione [`&&`], disgiunzione [`||`] e
negazione [`not`]. Quest’ultimo è una funzione e, in quanto tale, va
applicata seguendo le convenzioni standard dell’applicazione
funzionale.

```haskell
True
False
True && True
True && False
True || False
False || False
not True
not ((True && False) || True)
```

Come in altri linguaggi di programmazione, gli operatori di
congiunzione e disgiunzione sono **cortocircuitati**, ovvero il
secondo operando viene valutato solo se necessario.

## Uguaglianza, disuguaglianza e relazioni d’ordine

Gli operatori di confronto sono essenzialmente gli stessi di C e
Java, con l’unica differenza che l’operatore di disuguaglianza è
[`/=`] invece di `!=`.

```haskell
2 == 3
2 /= 3
2.5 < 3
2 <= 3
2 > 3
2 >= 3
```

## Espressioni condizionali

Le espressioni logiche possono essere usate per rendere la
valutazione di altre espressioni dipendente da condizioni. Una
**espressione condizionale** ha la forma

```haskell
if E1 then E2 else E3
```

dove `E1` è un'espressione logica ed `E2` ed `E3` sono altre
espressioni. Il valore dell’intera espressione dipende da quello di
`E1`. Se questo è [`True`], allora l’intera espressione ha valore
`E2`. Se questo è [`False`], allora l’intera espressione ha valore
`E3`. Ad esempio, la funzione `assoluto` che calcola il valore
assoluto del suo argomento può essere realizzata nel modo seguente:

```haskell
assoluto :: Int -> Int
assoluto n = if n >= 0 then n else negate n
```

```haskell
assoluto 3
assoluto (negate 3)
```

Occorre sottolineare che l’espressione condizionale `if-then-else`
può essere usata ovunque è attesa un'espressione. Per esempio, le
seguenti sono espressioni valide

```haskell
if True then 1 else 0
if 2 < 3 then 1 else 0
if 2 == 2 then False else True
```

Affinché un’espressione della forma `if E1 then E2 else E3` sia
corretta, è necessario che `E1` sia un'espressione logica -- ovvero
il cui valore sia di tipo [`Bool`] -- e che `E2` ed `E3` producano
valori dello stesso tipo. Le seguenti espressioni sono errate:

```haskell
if 1 then True else False
if True then 1 else False
```

Non è possibile omettere il ramo `else` di un'espressione
condizionale, in quanto deve essere sempre specificato qual è il
valore prodotto dall’espressione a prescindere dal valore della
condizione.  L’espressione condizionale `if E1 then E2 else E3` è
analoga all’espressione *ternaria* `E1 ? E2 : E3` disponibile in
linguaggi come C e Java.

## Esercizi

1. Scrivere un’espressione logica per calcolare il valore della
   relazione 1 ≤ 2 ≤ 3.
   ```haskell
   1 <= 2 && 2 <= 3
   ```
   {:.solution}
2. Scrivere un’espressione per rappresentare la condizione “1 minore
   o uguale di 0 oppure 0 minore o uguale di 1”, il cui valore deve
   essere `True`.
   ```haskell
   1 <= 0 || 0 <= 1
   ```
   {:.solution}
3. Concepire una espressione logica per appurare che [`&&`] è davvero
   cortocircuitato. Suggerimento: individuare una espressione che,
   se valutata, genera un errore (es. una divisione per zero) e
   usare tale espressione in una condizione formulata usando [`&&`] e
   [`||`].
   ```haskell
   False && (1 `div` 0 == 0)
   ```
   {:.solution}
4. Ripetere l’esercizio precedente con l’operatore [`||`].
   ```haskell
   True || (1 `div` 0 == 0)
   ```
   {:.solution}
5. Esprimere le espressioni `E1 && E2` ed `E1 || E2` come
   espressioni condizionali, senza fare uso di operatori.
   ```haskell
   E1 && E2 = if E1 then E2 else False
   E1 || E2 = if E1 then True else E2
   ```
   {:.solution}
