---
title: Alberi binari di ricerca
---

## Descrizione del problema

In questo caso di studio sviluppiamo una libreria per rappresentare
e manipolare **alberi binari di ricerca**. Si ricorda che un albero
binario di ricerca è caratterizzato dal fatto che, fissato un
qualsiasi suo sotto-albero $T$ avente per radice un elemento $x$,
tutti gli elementi nel sotto-albero **sinistro** di $T$ sono **più
piccoli** di $x$ e tutti gli elementi nel sotto-albero **destro** di
$T$ sono **più grandi** di $x$.

## Un tipo algebrico per alberi binari

Ogni albero binario ha una delle seguenti forme:

* una **foglia**, che non contiene elementi e non ha figli;
* una **diramazione**, che contiene un elemento e ha due
  sotto-alberi.

Di conseguenza, possiamo rappresentare alberi binari con un tipo
polimorfo e ricorsivo, parametrico rispetto al tipo degli elementi
contenuti nell'albero.

``` haskell
data Tree a = Leaf | Branch a (Tree a) (Tree a)
  deriving Show
```

Come suggerito dai nomi dei costruttori, usiamo `Leaf` per
rappresentare l'albero vuoto (senza elementi) e `Branch` per
rappresentare diramazioni.

``` haskell
:type Leaf
:type Branch 1 Leaf (Branch 2 Leaf Leaf)
```

Definiamo ora alcune funzioni fondamentali su alberi, partendo dalla
funzione `empty` che determina se un albero è vuoto.

``` haskell
empty :: Tree a -> Bool
empty Leaf = True
empty _    = False
```

La funzione `depth` calcola la **profondità** di un albero, ovvero
la lunghezza del percorso più lungo dalla radice dell'albero a una
delle sue foglie.

``` haskell
depth :: Tree a -> Int
depth Leaf             = 0
depth (Branch _ t₁ t₂) = 1 + max (depth t₁) (depth t₂)
```

``` haskell
depth Leaf
depth (Branch 1 Leaf (Branch 2 Leaf Leaf))
```

Infine, la funzione `elements` raccoglie in una lista tutti gli
elementi di un albero facendo una visita in ordine infisso
(visitando una diramazione, l'elemento alla radice della diramazione
viene raccolto *dopo* tutti quelli nel sotto-albero sinistro e
*prima* di tutti quelli nel sotto-albero destro).

``` haskell
elements :: Tree a -> [a]
elements Leaf             = []
elements (Branch x t₁ t₂) = elements t₁ ++ [x] ++ elements t₂
```

``` haskell
elements Leaf
elements (Branch 1 Leaf (Branch 2 Leaf Leaf))
```

## Operazioni fondamentali

La funzione `tmax` determina l'elemento **più grande** in un albero
binario di ricerca, che può essere individuato seguendo tutte le
diramazioni destre dell'albero.

``` haskell
tmax :: Tree a -> a
tmax (Branch x _ Leaf) = x
tmax (Branch _ _ t)    = tmax t
```

Notiamo due particolarità di `tmax`. La prima è che si tratta di una
funzione *parziale*, non definita se applicata all'albero vuoto. Per
questo motivo, nella prima equazione di `tmax` usiamo il pattern
matching "profondo" per fermare la ricorsione al livello
immediatamente precedente al raggiungimento di una foglia. In
secondo luogo, la funzione `tmax` restituisce l'elemento più grande
di un albero binario di ricerca, ma non di un albero binario
qualsiasi. In altri termini, `tmax` fa un'assunzione implicita (non
manifesta nel tipo della funzione) sulla caratteristica dell'albero
binario a cui è applicata.

``` haskell
tmax Leaf
tmax (Branch 1 Leaf (Branch 2 Leaf Leaf))
```

La funzione `insert` inserisce un elemento in un albero binario di
ricerca, restituendo come risultato un nuovo albero binario di
ricerca in cui l'inserimento è stato effettuato.

``` haskell
insert :: Ord a => a -> Tree a -> Tree a
insert x Leaf = Branch x Leaf Leaf
insert x t@(Branch y t₁ t₂) | x == y    = t
                            | x < y     = Branch y (insert x t₁) t₂
                            | otherwise = Branch y t₁ (insert x t₂)
```

Inserendo `x` nell'albero vuoto si ottiene un albero che contiene
solo `x`. Per inserire `x` in una diramazione che contiene `y`
occorre distinguere tre casi:

* Se `x` ed `y` sono uguali, allora l'albero è invariato. Potremmo
  esprimere questo comportamento di `insert` scrivendo, a destra del
  simbolo `=`, l'espressione `Branch y t₁ t₂` che *ricostruisce*
  esattamente lo stesso albero a cui `insert` è stata applicata. È
  più comodo (e lievemente più efficiente) restituire direttamente
  l'albero inziale. A tal fine usiamo un'**ascrizione** `t@(Branch y
  t₁ t₂)` che dà nome `t` all'albero in cui avviene l'inserimento e
  allo stesso tempo controlla che tale albero abbia la forma di una
  diramazione.
* Se `x` è più piccolo di `y`, allora il risultato è una diramazione
  che continua ad avere `y` nella radice e `t₂` come sotto-albero
  destro, ma in cui il sotto-albero sinistro è il risultato
  dell'inserimento di `x` in `t₁`.
* Il caso in cui `x` è più grande di `y` è simmetrico del precedente.

``` haskell
insert 3 (Branch 1 Leaf (Branch 2 Leaf Leaf))
foldr insert Leaf [4, 2, 1, 3, 0, 5]
```

Come abbiamo già osservato per le liste, la "modifica" di un albero
binario di ricerca è da intendersi come creazione di un *nuovo*
albero avente le caratteristiche richieste. Nel caso
dell'inserimento, notiamo che tale creazione riutilizza buona parte
dell'albero iniziale attraverso i nomi (`t`, `t₁` e `t₂`) che
compaiono direttamente nel risultato a destra del simbolo `=`. In
particolare, l'inserimento di un elemento `x` in un albero `t`
ricostruisce solo il percorso che collega la radice di `t` al punto
in cui `x` è stato collocato.

La funzione `delete` rimuove un elemento `x` da un albero binario di
ricerca. Se l'albero non contiene `x`, l'operazione non ha alcun
effetto.

``` haskell
delete :: Ord a => a -> Tree a -> Tree a
delete _ Leaf = Leaf
delete x (Branch y t₁ t₂) | x < y = Branch y (delete x t₁) t₂
                          | x > y = Branch y t₁ (delete x t₂)
delete x (Branch _ t Leaf) = t
delete x (Branch _ Leaf t) = t
delete x (Branch _ t₁ t₂)  = Branch y (delete y t₁) t₂
  where
    y = tmax t₁
```

La prima equazione gestisce il caso banale in cui l'albero è vuoto,
nel quale evidentemente l'elemento da rimuovere non c'è.  Le due
equazioni successive gestiscono i casi in cui l'elemento da
rimuovere è più piccolo o più grande di quello che si trova alla
radice dell'albero. In questi casi la radice "sopravvive" e `x`
viene cercato -- ed eventualmente rimosso -- nel sotto-albero
sinistro o destro a seconda della sua relazione con la radice
dell'albero.  Dalla terza equazione in poi sappiamo che l'elemento
da rimuovere si trova nella radice dell'albero. In particolare, la
terza e la quarta equazione gestiscono i casi in cui almeno uno dei
due sotto-alberi è vuoto, e dunque il risultato è l'altro
sotto-albero.  L'ultima equazione gestisce il caso in cui nessuno
dei due sotto-alberi è vuoto. In tal caso, si elegge come nuova
radice dell'albero l'elemento più grande `y` del sotto-albero
sinistro dal quale viene rimosso nel risultato. Si noti l'utilizzo
della definizione locale di `y` che evita l'applicazione multipla di
`tmax` (`y` compare due volte nel risultato). In maniera simmetrica
si potrebbe realizzare questo caso scegliendo come nuova radice
dell'albero l'elemento più piccolo del sotto-albero destro.

## Esercizi

1. Definire la funzione `tmin :: Tree a -> a` che restituisce
   l'elemento più piccolo in un albero binario di ricerca non vuoto.
   ^
   ``` haskell
   tmin :: Tree a -> a
   tmin (Branch x Leaf _) = x
   tmin (Branch _ t _)    = tmin t
   ```
   {:.solution}
2. Definire una versione *totale* di `tmin` con tipo `Tree a ->
   Maybe a`.
   ^
   ``` haskell
   tmin :: Tree a -> Maybe a
   tmin Leaf           = Nothing
   tmin (Branch x t _) = case tmin t of
                           Nothing -> Just x
						   Just y  -> Just y
   ```
   {:.solution}
3. Definire una funzione `treeSort :: Ord a => [a] -> [a]` che
   ordina gli elementi di una lista usando un albero binario come
   struttura intermedia. Nota: usando l'implementazione di `insert`
   mostrata sopra è normale che eventuali elementi ripetuti nella
   lista da ordinare compaiano una sola volta nel risultato.
   ^
   ``` haskell
   treeSort :: Ord a => [a] -> [a]
   treeSort = elements . foldr insert Leaf
   ```
   {:.solution}
4. Definire una funzione `bst :: Tree a -> Bool` che, applicata a
   un albero binario `t`, restituisca `True` se `t` è un albero
   binario di ricerca e `False` altrimenti. Suggerimento: usare
   `empty`, `tmin` e `tmax`.
   ^
   ``` haskell
   bst :: Ord a => Tree a -> Bool
   bst Leaf = True
   bst (Branch x t₁ t₂) = bst t₁ && bst t₂ &&
                          (empty t₁ || tmax t₁ < x) &&
						  (empty t₂ || x < tmin t₂)
   ```
   {:.solution}
