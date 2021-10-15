---
title: Trasformazioni di liste e Quick Sort
---

{% include links.md %}

## Introduzione

In questo caso di studio illustriamo come combinare e usare due
caratteristiche chiave dei linguaggi funzionali fortemente tipati --
il **polimorfismo** e le **funzioni di ordine superiore** -- per
implementare nel modo più generale possibile alcune trasformazioni
su liste che ricorrono frequentemente in programmi funzionali.  I
principi descritti favoriscono il **riuso** e la
**specializzazione** del codice, riducono drasticamente i casi in
cui è necessario definire funzioni ricorsive *ad hoc* e sono
applicabili ad altri tipi di dato, inclusi quelli definiti
dall'utente.

## Map

Un'operazione frequente nei programmi funzionali consiste nel
modificare ogni elemento di una lista secondo una trasformazione
data. Quando si dice "modificare una lista" si intende, ovviamente,
produrre una **nuova** lista contenente gli elementi trasformati.
Supponiamo, ad esempio, di voler arrotondare tutti gli elementi di
una lista di numeri con virgola. Possiamo realizzare questa
trasformazione per mezzo di una funzione `arrotonda`, mostrata qui
sotto:

``` haskell
arrotonda :: (RealFrac a, Integral b) => [a] -> [b]
arrotonda []       = []
arrotonda (x : xs) = round x : arrotonda xs
```

La funzione usa il pattern matching per esaminare la struttura della
lista da trasformare. Per ogni elemento della lista da trasformare
la funzione ne crea uno nella lista risultante.

Come secondo esempio, supponiamo di voler calcolare il quadrato di
ogni elemento di una lista di numeri (se la lista rappresenta un
vettore di uno spazio vettoriale, questa operazione potrebbe essere
parte del calcolo della norma del vettore). In tal caso potremmo
scrivere la funzione seguente:

``` haskell
quadrati :: Num a => [a] -> [a]
quadrati []       = []
quadrati (x : xs) = x ^ 2 : quadrati xs
```

Anche in questo la trasformazione della lista è ricondotta alla
trasformazione dei singoli elementi.

Le funzioni `arrotonda` e `quadrati` sono strutturalmente
analoghe. Se si escludono nome e tipo, l'unica differenza
sostanziale tra le due è la trasformazione applicata a ogni elemento
della lista ([`round`] nel caso di `arrotonda` e `(^ 2)` nel caso di
`quadrati`). È facile immaginare molte altre funzioni
strutturalmente simili a `arrotonda` e `quadrati` che differiscono
da queste solo per il tipo di trasformazione applicata.  In un
linguaggio come Haskell, in cui le funzioni sono entità di prima
classe ed il sistema di tipi supporta il polimorfismo parametrico, è
possibile realizzare un'unica funzione -- storicamente chiamata
[`map`] -- che realizza una volta per tutte questa trasformazione di
liste. Il codice di [`map`] è mostrato qui sotto:

``` haskell
map :: (a -> b) -> [a] -> [b]
map _ []       = []
map f (x : xs) = f x : map f xs
```

Il tipo di [`map`] ne rivela le caratteristiche essenziali.  In primo
luogo, vediamo che [`map`] è una funzione di ordine superiore, dal
momento che ha come primo argomento un'altra funzione. In secondo
luogo, notiamo che [`map`] prescinde completamente sia dal tipo degli
elementi della lista da trasformare (rappresentato dalla variabile
di tipo `a`) che dal tipo degli elementi della lista risultante
dalla trasformazione (rappresentato dalla variabile di tipo
`b`). Ciò rende [`map`] applicabile nel più ampio spettro di contesti,
compresi quelli in cui il tipo degli elementi nella lista risultante
dalla trasformazione è *diverso* dal tipo degli elementi nella lista
iniziale, come in `arrotonda`.

L'implementazione di [`map`] segue sostanzialmente quella delle
funzioni `arrotonda` e `quadrati`, salvo che la funzione da
applicare a ogni elemento della lista è un argomento di [`map`] invece
di essere fissata a priori. L'equazione corrispondente al caso della
lista vuota fa uso del pattern `_` dal momento che la trasformazione
non è applicata.

Un volta implementato in [`map`] questo schema di trasformazione di
liste, `arrotonda` e `quadrati` sono ottenibili come semplici
specializzazioni di [`map`] senza usare esplicitamente la ricorsione:

``` haskell
arrotonda :: (RealFrac a, Integral b) => [a] -> [b]
arrotonda = map round

quadrati :: Num a => [a] -> [a]
quadrati = map (^ 2)
```

## Filter

Un'altra trasformazione comune è quella che seleziona, o *filtra*,
da una lista solamente quegli elementi che soddisfano una
determinata proprietà. Supponiamo, ad esempio, di voler selezionare
in una lista tutti gli elementi *minori* di un valore dato. A tal
fine, potremmo definire la seguente funzione:

``` haskell
minori :: Ord a => a -> [a] -> [a]
minori _ [] = []
minori x (y : ys) | y < x     = y : minori x ys
                  | otherwise = minori x ys
```

In maniera duale, se volessimo selezionare tutti gli elementi
*maggiori o uguali* a un valore dato avremmo:

``` haskell
maggiori :: Ord a => a -> [a] -> [a]
maggiori _ [] = []
maggiori x (y : ys) | y >= x    = y : maggiori x ys
                    | otherwise = maggiori x ys
```

Notiamo ancora una volta le forti analogie strutturali tra `minori`
e `maggiori`. Esattamente come nel caso di [`map`], possiamo astrarre
da queste funzioni il predicato usato per selezionare gli elementi
che sopravvivono al filtro e renderlo esso stesso un argomento della
funzione che effettua il filtro, chiamata appunto [`filter`]:

``` haskell
filter :: (a -> Bool) -> [a] -> [a]
filter _ [] = []
filter p (x : xs) | p x       = x : filter p xs
                  | otherwise = filter p xs
```

È ora possibile definire `minori` e `maggiori` come semplici
specializzazioni di [`filter`]:

``` haskell
minori :: Ord a => a -> [a] -> [a]
minori x = filter (< x)

maggiori :: Ord a => a -> [a] -> [a]
maggiori x = filter (>= x)
```

Si noti in particolare l'uso delle sezioni `(< x)` e `(>= x)` per
costruire "al volo" i predicati "essere minore di `x`" ed "essere
maggiore o uguale a `x`".

## Quick Sort

QuickSort è un famoso algoritmo di ordinamento di tipo
*divide-et-impera*: per ordinare una lista non vuota si sceglie
un particolare elemento detto *pivot* usato per partizionare la
lista in due sotto-liste contenenti rispettivamente tutti gli elementi
minori del pivot e maggiori o uguali al pivot. Le due sotto-liste, che
sono necessariamente più piccole della lista originaria, possono
essere ordinate ricorsivamente. A questo punto è sufficiente
concatenare le due liste risultanti ricordandosi di collocare il pivot
in mezzo ad esse.

In questa descrizione dell'algoritmo QuickSort è evidente come
occorra eliminare da una lista tutti gli elementi che non soddisfano
una determinata condizione (essere minori del pivot, oppure essere
maggiori o uguali al pivot). Ciò suggerisce l'uso della funzione
[`filter`]. Possiamo dunque realizzare la funzione `quickSort` nel
seguente modo:

``` haskell
quickSort :: Ord a => [a] -> [a]
quickSort [] = []
quickSort (x : xs) =
  quickSort (filter (< x) xs) ++ [x] ++ quickSort (filter (>= x) xs)
```

Questa implementazione del QuickSort è compatta ed evidentemente
corretta. Di fatto è la trascrizione in codice Haskell della
descrizione informale che ne abbiamo dato qui sopra. Occorre
comunque sottolineare due aspetti potenzialmente critici che
differenziano `quickSort` da altre implementazioni dello stesso
algoritmo, in particolare quelle per linguaggi imperativi.  In primo
luogo, il pivot scelto è sempre il primo elemento della lista da
ordinare, ovvero l'elemento a cui è più facile accedere. è noto che
questa scelta può non essere ottimale dal punto di vista della
complessità dell'algoritmo di ordinamento, soprattutto se la lista
originale è già ordinata o è ordinata in senso inverso. Scegliere un
elemento pivot diverso dal primo è possibile, ma ha a sua volta
degli svantaggi: la rappresentazione delle liste in Haskell è tale
per cui l'accesso all'$n$-esimo elemento di una lista ha un costo
proporzionale a $n$.  Il secondo aspetto critico, che però è
largamente responsabile della semplicià ed eleganza di `quickSort`,
è che `quickSort` non modifica materialmente la lista originale, ma
ne crea una nuova che contiene gli elementi della lista originale
ordinati in modo crescente. Ciò significa che `quickSort` ha un
costo in termini di memoria utilizzata che dipende (in modo non
banale) dalla dimensione della lista da ordinare.

## Fold

Il terzo e ultimo tipo di trasformazione comune delle liste riguarda
quei casi in cui è necessario **combinare** tutti gli elementi di
una lista usando un determinato operatore binario. Due esempi di
tali combinazioni sono forniti dalle funzioni [`sum`] e [`product`] che
rispettivamente sommano e moltiplicano tutti gli elementi di una
lista. Tali funzioni potrebbero essere definite ricorsivamente
facendo pattern matching sulla lista di elementi da combinare:

``` haskell
sum :: Num a => [a] -> a
sum []       = 0
sum (x : xs) = x + sum xs

product :: Num a => [a] -> a
product []       = 1
product (x : xs) = x * product xs
```

Proprio come [`map`] e [`filter`], anche qui possiamo apprezzare delle
forti analogie strutturali tra [`sum`] e [`product`]. In particolare,
gli elementi di una lista sono combinati per mezzo di vari operatori
([`+`] o `*`) che possono essere astratti dal corpo di queste
funzioni. A differenza degli esempi discussi in precedenza,
tuttavia, notiamo che anche il valore restituito nel caso base varia
a seconda dell'operazione che vogliamo eseguire: usiamo `0` in [`sum`]
e `1` in [`product`]. Ciò suggerisce che, per astrarre adeguatamente
questa trasformazione di liste e renderla generica, occorra
specificare non solo l'operazione usata per combinare tra loro gli
elementi di una lista, ma anche l'elemento da restituire nel momento
in cui si cerca di trasformare la lista vuota. Seguendo questa
intuizione otteniamo la funzione [`foldr`]:

``` haskell
foldr :: (a -> b -> b) -> b -> [a] -> b
foldr _ x []       = x
foldr f x (y : ys) = f y (foldr f x ys)
```

Indicando con $\oplus$ una generica operazione binaria e con
$\mathbf{0}$ il valore da restituire nel caso della lista vuota,
possiamo descrivere l'effetto di [`foldr`] applicato a una lista
$[a_1, a_2, \dots, a_n]$ così:

$$
  \mathtt{foldr}~(\oplus)~\mathbf{0}~[a_1, a_2, \dots, a_n] = a_1 \oplus (a_2 \oplus (\cdots (a_n \oplus \mathbf{0})\cdots))
$$

È ora possibile definire [`sum`] e [`product`] come specializzazioni di
[`foldr`]:

``` haskell
sum :: Num a => [a] -> a
sum = foldr (+) 0

product :: Num a => [a] -> a
product = foldr (*) 1
```

La `r` in [`foldr`] è l'abbreviazione di "right", lasciando intendere
l'esistenza di un'altra versione della stessa funzione che si chiama
[`foldl`] (per "left"). La differenza tra [`foldr`] e [`foldl`] risiede
nell'associatività che si intende dare all'operatore $\oplus$ usato
per combinare tutti gli elementi della lista: nel caso di [`foldr`]
tale operatore è inteso associativo a destra, mentre nel caso di
[`foldl`] come associativo a sinistra. In altri termini, abbiamo

$$
  \mathtt{foldl}~(\oplus)~ \mathbf{0}~ [a_1, a_2, \dots, a_n] = (\cdots((\mathbf{0} \oplus a_1) \oplus a_2) \oplus \cdots \oplus a_n)
$$

Nel caso in cui $\oplus$ sia associativo, l'effetto di [`foldl`] e di
[`foldr`] è il medesimo. In generale ci sono però delle differenze tra
le due versioni di `fold` (si veda la sezione di esercizi).

## Esercizi

1. Definire [`foldl`] partendo dalla definizione informale data sopra.
   ```haskell
   foldl :: (b -> a -> b) -> b -> [a] -> b
   foldl _ x []       = x
   foldl f x (y : ys) = foldl f (f x y) ys
   ```
   {:.solution}
2. Che funzioni sono le seguenti?
   1. `length . filter (>= 0)`
	  > La funzione che calcola il numero di elementi non negativi
	  >	di una lista.
	  {:.solution}
   2. `foldr (&&) True . map (>= 0)`
      > La funzione che verifica se tutti i numeri di una lista sono
	  > non negativi.
	  {:.solution}
   3. `foldr (+) 0 . map (const 1)`
      > La funzione che calcola la lunghezza di una lista
      > ([`length`]).
	  {:.solution}
   4. `foldl (\xs x -> x : xs) []`
      > La funzione che inverte l'ordine degli elementi di una lista
	  > ([`reverse`]).
      {:.solution}
3. Definire le seguenti funzioni della libreria standard **senza
      usare esplicitamente la ricorsione**:
   1. `concat :: [[a]] -> [a]` per concatenare tutti gli elementi
	  in una lista di liste.
	  ^
	  ```haskell
      concat :: [[a]] -> [a]
	  concat = foldr (++) []
	  ```
      {:.solution}
   2. `any :: (a -> Bool) -> [a] -> Bool` per determinare se **esiste**
      un elemento di una lista (il secondo argomento della funzione)
      che soddisfa un certo predicato (il primo argomento della
      funzione).
	  ^
	  ```haskell
	  any :: (a -> Bool) -> [a] -> Bool
	  any p = foldr (||) False . map p
	  ```
	  {:.solution}
   3. `all :: (a -> Bool) -> [a] -> Bool` per determinare se **tutti**
	  gli elementi di una lista (il secondo argomento della
	  funzione) soddisfano un certo predicato (il primo argomento
	  della funzione).
	  ^
	  ```haskell
	  all :: (a -> Bool) -> [a] -> Bool
	  all p = foldr (&&) True . map p
	  ```
	  {:.solution}
4. Definire le seguenti funzioni **senza usare esplicitamente la
   ricorsione**:
   1. `massimo :: Ord a => [a] -> a` per calcolare il valore massimo
      di una lista non vuota.
	  ```haskell
	  massimo :: Ord a => [a] -> a
	  massimo (x : xs) = foldr max x xs
	  ```
	  {:.solution}
   2. `occorrenze :: Eq a => a -> [a] -> Int` per contare il numero
      di occorrenze di un elemento (il primo argomento della
      funzione) in una lista (il secondo argomento della funzione).
	  ```haskell
	  occorrenze :: Eq a => a -> [a] -> Int
	  occorrenze x = length . filter (== x)
	  ```
	  {:.solution}
   3. `membro :: Eq a => a -> [a] -> Bool` per determinare se un
      elemento (il primo argomento della funzione) occorre in una
      lista (il secondo argomento della funzione). Assicurarsi che
      `membro` interrompa la scansione immediatamente se l'elemento
      cercato è presente nella lista.
	  ```haskell
	  membro :: Eq a => a -> [a] -> Bool
	  membro x = any (== x)

	  occorrenze 2 [1, 2, 3, 1 `div` 0] -- divisione per zero
	  membro 2 [1, 2, 3, 1 `div` 0]     -- restituisce True
	  ```
	  {:.solution}
