---
title: Pattern Matching
---

{% include links.md %}

Come abbiamo già visto con le funzioni ricorsive, è possibile
definire funzioni usando più equazioni, ciascuna identificata da un
**pattern** che indica la forma dell'argomento a cui quell'equazione
si applica. In questa traccia estendiamo il meccanismo del pattern
matching alle liste.

## Pattern matching strutturale

È possibile usare i **costruttori canonici** delle liste per
specificare pattern nelle equazioni di funzioni. Ad esempio, la
funzione

``` haskell
somma :: [Int] -> Int
somma []       = 0
somma (x : xs) = x + somma xs
```

calcola la somma di tutti gli elementi di una lista di numeri
interi. La funzione `somma` ha due equazioni. La prima indica il
comportamento di `somma` quando `somma` è applicata alla lista
vuota, nel qual caso il risultato è 0. La seconda indica il
comportamento di `somma` quando è applicata a una lista **non**
vuota, ovvero una lista che ha la forma `x : xs` per una certa testa
`x` e una certa coda `xs`. I nomi dati alla testa e alla coda della
lista sono scelti dal programmatore e possono essere usati nella
parte destra dell'equazione, in cui denotano le parti della lista a
cui fanno riferimento.

``` haskell
somma []
somma [1]
somma [1, 2]
somma [1, 2, 3]
```

Quando `somma` viene applicata a una lista, Haskell sceglie
l'equazione da usare in base alla forma della lista, confrontandola
con i pattern delle varie equazioni. La prima equazione (dall'alto
verso il basso) in cui la lista corrisponde al -- tecnicamente, "fa
match con il" -- pattern, viene scelta per determinare il
comportamento della funzione.

## Pattern matching profondo

È possibile effettuare il pattern matching a profondità arbitraria
nella struttura delle liste. A titolo di esempio, supponiamo di
voler scrivere una funzione per determinare se una lista è ordinata
in modo non decrescente. Quando la lista è vuota o contiene un solo
elemento la risposta è banalmente [`True`], ma quando la lista
contiene due o più elementi è necessario confrontare **i primi due
elementi** della lista per vedere se soffisfano la relazione
d'ordine. Possiamo realizzare la funzione con un pattern matching
"profondo", così:

``` haskell
ordinata :: [Int] -> Bool
ordinata []           = True
ordinata [_]          = True
ordinata (x : y : xs) = x <= y && ordinata (y : xs)
```

Notiamo in particolare che l'ultima equazione si applica a liste
della forma `x : y : xs` in cui `x` è il nome scelto per il
**primo** elemento della lista, `y` è il nome scelto per il
**secondo** elemento della lista e `xs` è il nome scelto per la coda
della coda della lista.

``` haskell
ordinata []
ordinata [1, 2, 3]
ordinata [1, 2, 0]
```

## Pattern matching su più argomenti

Supponiamo di voler scrivere una funzione `stessaLunghezza` che
determina se due liste di interi hanno la stessa lunghezza. Potremmo
sfruttare la funzione di libreria [`length`] e ottenere

``` haskell
stessaLunghezza :: [Int] -> [Int] -> Bool
stessaLunghezza xs ys = length xs == length ys
```

Tenuto conto che un'applicazione come `length xs` ha un costo
computazionale proporzionale alla lunghezza di `xs`, la
realizzazione proposta di `stessaLunghezza` potrebbe essere
svantaggiosa nel momento in cui una delle due liste è più lunga
dell'altra. Per esempio, se una lista è vuota e l'altra ha 100000
elementi, si paga un costo proporzionale a 100000 laddove si
potrebbe rispondere immediatamente [`False`].

Una realizzazione alternativa e più efficiente di `stessaLunghezza`
è illustrata qui sotto, in cui entrambe le liste da misurare sono
analizzate con il pattern matching:

``` haskell
stessaLunghezza :: [Int] -> [Int] -> Bool
stessaLunghezza []       []       = True
stessaLunghezza []       _        = False
stessaLunghezza _        []       = False
stessaLunghezza (_ : xs) (_ : ys) = stessaLunghezza xs ys
```

La prima equazione si applica quando entrambe le liste sono vuote,
nel qual caso hanno la stessa lunghezza e la risposta è [`True`]. La
seconda e la terza equazione si applicano quanto una delle due liste
è vuota e l'altra no. Il pattern `_` corrisponde a ogni lista
possibile, ma siccome il caso in cui entrambe sono vuote è già
gestito dalla prima equazione e le equazioni sono provate dall'alto
verso il basso, in queste equazioni `_` corrisponde necessariamente
a liste non vuote per cui il risultato è [`False`]. Infine, l'ultima
equazione si applica quando nessuna delle due liste è vuota. In
questo caso, la risposta è determinata dall'applicazione ricorsiva
di `stessaLunghezza` alla coda delle due liste.

``` haskell
stessaLunghezza []        [4, 5, 6]
stessaLunghezza [1, 2, 3] [4, 5]
stessaLunghezza [1, 2, 3] [4, 5, 6]
```

## Esercizi

1. Riscrivere la lista `[1, 2, 3]` in tutti modi possibili come
   concatenazione (con [`++`]) di due liste.
   ``` haskell
          [] ++ [1, 2, 3]
         [1] ++ [2, 3]
      [1, 2] ++ [3]
   [1, 2, 3] ++ []
   ```
   {:.solution}
2. Cosa ci sarebbe di sbagliato se, nella definizione di `ordinata`,
   l'applicazione ricorsiva fosse `ordinata xs` e non `ordinata (y :
   xs)` come indicato?
   > Si otterrebbe una funzione che confronta gli elementi della
   > lista a coppie, ma senza controllare che gli elementi di coppie
   > diverse siano in relazione. Per esempio, avremmo `ordinata [1,
   > 2, 0] == True` quando invece la risposta deve essere [`False`].
   {:.solution}
3. Un caso estremo in cui le due definizioni date di
   `stessaLunghezza` si comportano in modo differente è il seguente:

   ``` haskell
   stessaLunghezza [] [0..]
   ```

   Giustificare il diverso comportamento.

   > La seconda lista è infinita e la funzione [`length`] non termina
   > (o esaurisce la memoria) nel vano tentativo di calcolarne la
   > lunghezza. Tuttavia, essendo la prima lista vuota, le due liste
   > hanno chiaramente lunghezze diverse. Per questo motivo, la
   > seconda definizione di `stessaLunghezza` è in grado di
   > rispondere correttamente in questo caso.
   {:.solution}
4. Senza fare uso della funzione [`product`] della libreria standard,
   definire una funzione ricorsiva `prodotto :: [Int] -> Int` che,
   applicata a una lista di numeri interi, calcoli il prodotto di
   tutti i numeri nella lista.
   ```haskell
   prodotto :: [Int] -> Int
   prodotto []       = 1
   prodotto (x : xs) = x * prodotto xs
   ```
   {:.solution}
5. Definire una funzione `inverti :: [Int] -> [Int]` che, applicata
   a una lista di numeri $[a_1, a_2, \dots, a_n]$, ne calcoli la
   **lista inversa** $[a_n, \dots, a_2, a_1]$. **Suggerimento**: usare [`++`].
   ```haskell
   inverti :: [Int] -> [Int]
   inverti []       = []
   inverti (x : xs) = inverti xs ++ [x]
   ```
   {:.solution}
6. Definire una funzione `sommaCongiunta :: [Int] -> [Int] -> [Int]`
   che, applicata a due liste di numeri interi `xs` e `ys`, calcoli
   la lista delle somme degli elementi corrispondenti di `xs` e
   `ys`. Realizzare `sommaCongiunta` in modo che la lunghezza della
   lista risultante sia pari alla lunghezza minima tra quelle di
   `xs` e `ys`.
   ```haskell
   sommaCongiunta :: [Int] -> [Int] -> [Int]
   sommaCongiunta []       _        = []
   sommaCongiunta _        []       = []
   sommaCongiunta (x : xs) (y : ys) = x + y : sommaCongiunta xs ys
   ```
   {:.solution}
