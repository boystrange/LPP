---
title: Funzioni con guardie
---

Capita spesso che il valore prodotto da una funzione debba essere
calcolato in modo diverso a seconda di qualche proprietà
dell'argomento. Per esempio, la funzione che calcola il valore
assoluto di un numero $n$ ha due comportamenti possibili, a seconda
che $n \geq 0$ oppure $n < 0$. Nel primo caso, la funzione
restituisce il valore di $n$ immutato, nel secondo restituisce il
negato di $n$. Esistono due modi per esprimere questi comportamenti
che dipendono da una condizione, le espressioni condizionali e le
definizioni con guardie.

È possibile definire funzioni facendo uso di equazioni multiple,
ciascuna accompagnata da una condizione — detta **guardia** — che
specifica per quali valori degli argomenti quella equazione viene
applicata. Ad esempio, la funzione “valore assoluto” si può
realizzare con guardie nel seguente modo:

```haskell
assoluto :: Int -> Int
assoluto n | n >= 0 = n
           | n < 0  = negate n
```

Ogni guardia è preceduta dal simbolo `|`. Haskell usa l'indentazione
del codice per capire che guardie diverse appartengono allo stesso
blocco di codice, pertanto è fondamentale allineare verticalmente i
caratteri `|`. L'allineamento dei simboli `=` è puramente estetico e
non è necessario.

Quando si applica una funzione con guardie a un argomento, Haskell
usa la prima equazione (dall'alto verso il basso) la cui guardia ha
valore `True` per determinare il valore prodotto dalla funzione.

```haskell
assoluto 3
assoluto (negate 3)
```

Quando si usa un blocco di guardie **esaustive**, cioè che coprono
tutte le possibilità, l'ultima guardia svolge una funzione analoga a
quella del ramo `else` di un'espressione condizionale, in quanto il
suo valore deve essere necessariamente `True`. Nel caso della
funzione `assoluto`, ad esempio, è evidente che se la condizione $n
\geq 0$ è falsa, allora la condizione $n < 0$ deve essere vera. Da
questo punto di vista, controllare che effettivamente $n$ sia
negativo nell'ultima equazione è ridondante e dunque la funzione
`assoluto` si può scrivere anche come

```haskell
assoluto :: Int -> Int
assoluto n | n >= 0    = n
           | otherwise = negate n
```

in cui la guardia `otherwise` si applica se la prima (in generale,
tutte quelle precedenti) sono false.

## Esercizi

1. Definire una funzione `Int -> Int` che, applicata a un numero
   intero $n$, calcoli il successore di $n$ se $n$ è pari e il
   valore assoluto di $n$ se $n$ è dispari. Risolvere l'esercizio
   due volte, una prima volta usando un'espressione condizionale e
   una seconda volta con guardie.
   ```haskell
   -- soluzione con espressione condizionale
   f :: Int -> Int
   f n = if pari n then successore n else assoluto n

   -- soluzione con guardie
   f :: Int -> Int
   f n | pari n = successore n
       | otherwise = assoluto n
   ```
   {:.solution}
2. Definire una funzione `giorni :: Int -> Int` che, applicata a un
   anno $n$, calcoli il numero di giorni dell'anno $n$ a seconda che
   $n$ sia un anno bisestile o meno. Si faccia uso della funzione
   `bisestile` definita nella scheda [Funzioni](Funzioni.md).
   ```haskell
   giorni :: Int -> Int
   giorni n | bisestile n = 366
            | otherwise   = 365
   ```
   {:.solution}
3. Valutare in `ghci` l'espressione

   ```haskell
   otherwise
   ```
   e, in base alla risposta ottenuta, rivisitare mentalmente la
   seconda implementazione di `assoluto` per comprenderne il
   funzionamento.

   > L'espressione `otherwise` non è altro che un nome alternativo
   > per la costante `True`, dunque può essere usata come "ultima
   > guardia" sempre verificata.
   {:.solution}
