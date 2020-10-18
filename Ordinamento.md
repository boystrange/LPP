---
title: Insertion Sort e Merge Sort
---

## Descrizione del problema

Haskell è un linguaggi di programmazione **puro**, intendendo con
ciò che non sono normalmente previste istruzioni che modificano il
contenuto della memoria. Questa limitazione limita, almeno in
apparenza, il tipo di algoritmi che si possono realizzare. Un
esempio tipico è costituito dagli algoritmi di ordinamento, che nei
linguaggi di programmazione convenzionali sono solitamente
realizzati in modo da **modificare** una collezione di elementi
(tipicamente un *array*) cosicché gli elementi in essa contenuti
siano ordinati. È evidente che questi algoritmi di ordinamento non
possono essere realizzati nello stesso modo in Haskell, dove le
strutture dati -- e le liste in particolare -- sono invece
**immutabili**. In questo caso di studio illustriamo la
realizzazione di due algoritmi di ordinamento classici chiamati
**insertion sort** e **merge sort**. In entrambi i casi, l'idea di
fondo è che tali realizzazioni non modificano (perché non possono
farlo) la lista da ordinare, bensì **creano una nuova lista** che
contiene gli stessi elementi di quella iniziale, ma ordinati.

## Insertion Sort

L'insertion sort è forse l'algoritmo più ingenuo (e di conseguenza
non particolarmente efficiente) per ordinare una collezione di
elementi. Si basa sull'idea di considerare gli elementi da ordinare
uno alla volta e di **inserirli** nella lista risultante al posto
giusto. In questa descrizione informale abbiamo dunque individuato
le due componenti chiave di questo algoritmo di ordinamento: la
scansione della lista iniziale un elemento per volta e l'inserimento
di un elemento in una lista ordinata.

Realizziamo la seconda componente, che è ausiliaria della prima, con
una funzione `insert` così definita:

``` haskell
insert :: Int -> [Int] -> [Int]
insert x [] = [x]
insert x (y : ys) | x <= y    = x : y : ys
                  | otherwise = y : insert x ys
```

Nel commentare la funzione `insert`, è importante tenere presente
l'assunzione implicita -- non manifesta nel tipo della funzione --
che la lista all'interno della quale si inserisce l'elemento è
ordinata. Il caso base della funzione descrive l'effetto
dell'inserimento di un elemento `x` nella lista vuota. In tal caso,
il risultato è la lista singoletto `[x]`. Quando `x` viene inserito
in una lista non vuota -- e dunque della forma `y : ys` -- occorre
distinguere due casi per capire come inizierà la lista risultante.
Se `x <= y`, allora possiamo concludere che `x` è l'elemento più
piccolo e lo collochiamo in testa alla lista risultante, mentre la
coda `y : ys` è già ordinata per ipotesi. Se `x > y`, allora
possiamo concludere che `y` è l'elemento più piccolo e lo
collochiamo in testa alla lista risultante, andando a inserire `x`
ricorsivamente nella coda `ys`.

Una volta realizzata `insert`, l'implementazione dell'insertion sort
consta di una semplice ricorsione:

``` haskell
insertSort :: [Int] -> [Int]
insertSort []       = []
insertSort (x : xs) = insert x (insertSort xs)
```

La prima equazione è il caso base della ricorsion e tratta la lista
vuota, che è già ordinata. La seconda equazione tratta il caso di
una lista con testa `x` e coda `xs`. In questo caso è sufficiente
ordinare `xs` con una applicazione ricorsiva di `insertSort` e poi
inserire `x` nel punto giusto della lista risultante.

``` haskell
insertSort [1]
insertSort [3, 2, 1]
```

Come è già stato fatto in precedenza, volendo riconoscere il ruolo
esclusivamente ausiliario di `insert` nei confronti di `insertSort`,
è possibile definire la seconda funzione localmente alla prima in
una clausola `where` apposita:

``` haskell
insertSort :: [Int] -> [Int]
insertSort []       = []
insertSort (x : xs) = insert x (insertSort xs)
  where
    insert x [] = [x]
    insert x (y : ys) | x <= y    = x : y : ys
                      | otherwise = y : insert x ys
```

## Merge Sort

Il merge sort è un efficiente algoritmo di ordinamento che si basa
sul principio *divide et impera*:
* si **divide** la collezione da ordinare in due partizioni più o meno
  della stessa grandezza;
* si **ordinano** le due partizioni ricorsivamente;
* si **fondono** le due partizioni ordinate.

L'efficienza dell'algoritmo dipende in modo cruciale dalla facilità
con cui si possono dividere e fondere collezioni di elementi. Nelle
realizzazioni tradizionali basate su array, queste operazioni si
realizzano in modo efficiente. In particolare, la "divisione" di un
array ha un costo pressoché nullo dal momento che è sufficiente
invocare la procedura di ordinamento indicando l'intervallo di
elementi da prendere in considerazione.

L'operazione di **divisione** di una lista richiede comunque una
scansione della lista stessa, in quanto i suoi elementi non sono
necessariamente adiacenti in memoria. Una possibilità è dunque
quella di calcolare la lunghezza $n$ della lista con `length`
(operazione che ha un corso proporzionale a $n$), e poi dividere la
lista più o meno a metà, separando i primi $\frac{n}2$ elementi
dagli ultimi. Anche questa operazione di divisione, tuttavia,
avrebbe un costo proporzionale a $n$. Dal momento che l'obiettivo
dell'algoritmo di ordinamento è, appunto, ordinare gli elementi
della lista, e che quindi l'ordine in cui compaiono gli elementi
nella lista originale è poco importante, possiamo dividere la lista
facendo una sola scansione, collocando gli elementi in posizione
pari in una partizione e quelli in posizione dispari nell'altra. Il
codice Haskell che realizza questa operazione è mostrato di seguito:

``` haskell
split :: [Int] -> ([Int], [Int])
split []           = ([], [])
split [x]          = ([x], [])
split (x : y : xs) = (x : ys, y : zs)
  where
    (ys, zs) = split xs
```

Usiamo una coppia di liste per restituire le due partizioni della
lista originale. I due casi base dividono la lista vuota e la lista
singoletto. Il caso ricorsivo divide ricorsivamente la coda della
coda della lista (`xs`) e distribuisce i primi due elementi (`x` e
`y`) nelle due partizioni ottenute. Si noti l'uso del pattern `(ys,
zs)` che consente di dare un nome alle due partizioni `ys` e `zs`
ottenute dall'applicazione ricorsiva di `split`.

L'operazione di **fusione**, che chiamiamo `merge`, lavora su due
liste già ordinate per produrre un'unica lista ordinata a sua volta.

``` haskell
merge :: [Int] -> [Int] -> [Int]
merge []       ys = ys
merge xs       [] = xs
merge (x : xs) (y : ys) | x <= y    = x : merge xs (y : ys)
                        | otherwise = y : merge (x : xs) ys
```

Le prime due equazioni di `merge` gestiscono i casi base in cui una
delle due liste è vuota, producendo come risultato l'altra
lista. L'ultima equazione gestisce il caso in cui nessuna delle due
liste da fondere è vuota. In questo caso occorre fare un'ulteriore
distinzione per determinare quale tra i due elementi `x` e `y` in
testa alle due liste è il più piccolo e dunque quale diventa il
primo elemento della lista risultante. La coda è ottenuta
dall'applicazione ricorsiva di `merge`.

Con questi ingredienti, la realizzazione del Merge Sort è immediata.

``` haskell
mergeSort :: [Int] -> [Int]
mergeSort []  = []
mergeSort [x] = [x]
mergeSort xs  = merge (mergeSort ys) (mergeSort zs)
  where
    (ys, zs) = split xs
```

## Esercizi

1. Consultare la documentazione delle funzioni `take` e `drop` nella
   [libreria standard](https://hoogle.haskell.org). Facendo uso
   di queste funzioni, realizzare l'operazione di divisione
   descritta a parole nel testo qui sopra.
   ``` haskell
   split :: [Int] -> ([Int], [Int])
   split xs = (take n xs, drop n xs)
     where
	   n = length xs `div` 2
   ```
   {:.solution}
2. Motivare l'utilità della seconda equazione di `mergeSort`.
   > Senza quell'equazione, tentando di ordinare una lista
   > singoletto si otterrebbe una partizione in cui `ys` è di nuovo
   > una lista singoletto, pertanto l'applicazione `mergeSort ys`
   > causerebbe una ricorsione infinita.
   {:.solution}
