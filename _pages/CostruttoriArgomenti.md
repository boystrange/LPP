---
title: Costruttori con argomenti
---

I costruttori di un nuovo tipo di dato possono avere **argomenti**
che consentono di associare informazioni aggiuntive al valore che
viene costruito.

## Funzioni parziali e totali

Consideriamo il problema di definire una funzione `elemento` che,
applicata a un indice $n$ e a una lista di numeri interi `xs`,
restituisca l'elemento con indice $n$ in `xs`. Nel definire il tipo
della funzione `elemento` occorre prendere in considerazione
l'eventualità che l'indice $n$ **non** sia valido, e dunque di cosa
restituire in tal caso. Ci sono due modi diversi di approcciare il
problema.

Possiamo definire `elemento` come una **funzione parziale**, ovvero
che non è definita per tutti i valori possibili dei suoi argomenti:

``` haskell
elemento :: Int -> [Int] -> Int
elemento 0 (x : _)  = x
elemento n (_ : xs) = elemento (n - 1) xs
```

L'applicazione di `indice` a un indice non valido causa
un'eccezione, in quanto non c'è una equazione che definisca il
comportamento di `elemento` in questo caso:

``` haskell
elemento 0 [1, 2, 3]
elemento 1 [1, 2, 3]
elemento 3 [1, 2, 3]
```

Se si vuole definire "elemento" come una **funzione totale**, quindi
definita per **tutti** i valori dei suoi argomenti, una strategia
possibile è quella di usare un numero particolare da restituire
quando l'indice non è valido:

``` haskell
elemento :: Int -> [Int] -> Int
elemento 0 (x : _)  = x
elemento n (_ : xs) = elemento (n - 1) xs
elemento _ _        = -1
```

Questa soluzione ha due difetti gravi. In primo luogo, si
"sacrifica" un valore specifico del codominio (`-1`) per indicare
una condizione di errore. Questo significa che, ottenendo come
risultato `-1`, non è possibile distinguere il caso in cui l'indice
fornito non è valido da quello in cui l'indice è valido e l'elemento
che si trova in quella posizione è proprio `-1`. Il secondo difetto,
legato al primo, è che l'utilizzatore della funzione `elemento` può
dimenticarsi di controllare se il valore restituito dalla funzione è
quello che segnala l'errore, dal momento che questo valore è
indistinguibile da quello di un valore "normale".

Lo scenario ideale è quello in cui la funzione `elemento`
restituisca un valore di un *nuovo tipo di dato* distinto da `Int` e
i cui valori hanno due forme possibili a seconda che l'indice
fornito sia valido oppure no. A questo scopo una
[enumerazione](Enumerazione.html) non basta, perché nel caso in cui
l'indice sia valido è necessario anche comunicare l'elemento che si
trova in quella posizione.

## Costruttori come funzioni

È possibile dotare i costruttori di un nuovo tipo di dato di
argomenti per associare informazioni ausiliarie ai valori
costruiti. Nel caso della funzione `elemento`, possiamo concepire un
tipo di dato `ForseInt` con la seguente struttura:

``` haskell
data ForseInt = Niente | Proprio Int
  deriving Show
```

I valori di tipo `ForseInt` hanno due forme possibili
corrispondenti ai costruttori `Niente` e `Proprio`. Quest'ultimo ha
un argomento di tipo `Int` che possiamo utilizzare per indicare
esplicitamente **quale** elemento della lista è stato trovato. In
altri termini, mentre `Niente` è da solo un valore di tipo
`ForseInt`, `Proprio` è una funzione che, applicata a un numero
intero, produce un valore di tipo `ForseInt`:

``` haskell
:type Niente
:type Proprio
:type Proprio 3
```

Usando `ForseInt`, possiamo ridefinire `elemento` come funzione
totale nel seguente modo:

``` haskell
elemento :: Int -> [Int] -> ForseInt
elemento 0 (x : _)  = Proprio x
elemento n (_ : xs) = elemento (n - 1) xs
elemento _ _        = Niente
```

``` haskell
elemento 0 [1, 2, 3]
elemento 1 [1, 2, 3]
elemento 3 [1, 2, 3]
```

## Pattern matching sul risultato di una funzione

Supponiamo ora di voler definire una funzione `posizione :: Int ->
[Int] -> ForseInt` che, applicata a un numero `x` e a una lista
`xs`, restituisca l'indice della prima occorrenza di `x` in
`xs`. Possiamo sfruttare il tipo di dato `ForseInt` anche per
definire `posizione` come una funzione totale che restituisce
`Niente` nel caso in cui `x` non è presente in `xs`. Il
comportamento di `posizione` è semplice da descrivere a parole:

* se `xs` è la lista è vuota, il risultato è `Niente`;
* se `x` è il primo elemento della lista, il risultato è `Proprio 0`;
* altrimenti, il risultato è rispettivamente `Niente` o `Proprio
  (n + 1)` a seconda che `x` non sia presente nella coda della
  lista o sia presente nella coda della lista all'indice `n`.

La realizzazione dell'ultimo caso in codice Haskell richiede la
risoluzione di un problema tecnico che non si è mai presentato fino
ad ora, ovvero il *pattern matching* sul **risultato**
dell'applicazione di una funzione invece che su uno dei suoi
argomenti. Questo *pattern matching* è realizzabile per mezzo di una
*case expression* come mostrato nel codice che segue:

``` haskell
posizione :: Int -> [Int] -> ForseInt
posizione _ []                = Niente
posizione x (y : _)  | x == y = Proprio 0
posizione x (_ : xs) = case posizione x xs of
                         Niente    -> Niente
                         Proprio n -> Proprio (n + 1)
```

L'espressione `case E of...` consente di confrontare il valore di
`E`, nel caso specifico il risultato dell'applicazione ricorsiva
`posizione x xs`, con i *pattern* che seguono `of`. A destra del
simbolo `->` è specificato il risultato dell'espressione nei vari
casi.

``` haskell
posizione 0 [1, 2, 3]
posizione 1 [1, 2, 3]
posizione 3 [1, 2, 3]
```

## Esercizi

1. Realizzare una funzione **totale** `testa :: [Int] -> ForseInt`
   che, applicata a una lista `xs`, restituisca la testa di `xs` se
   `xs` non è vuota, e `Niente` altrimenti.
   ^
   ``` haskell
   testa :: [Int] -> ForseInt
   testa []      = Niente
   testa (x : _) = Proprio x
   ```
   {:.solution}
2. Definire un tipo di dato `Numero` i cui valori hanno la forma
   `I n` dove `n` è un numero intero o `F f` dove `f` è un
   numero *floating-point* a precisione singola. Questo tipo di dato
   può essere usato per rappresentare in modo uniforme numeri di
   tipo diverso. Definire una funzione `somma :: Numero -> Numero ->
   Numero` per sommare due numeri in modo tale che il risultato sia
   *floating-point* solo se necessario.
   ^
   ``` haskell
   data Numero = I Int | F Float
     deriving Show

   somma :: Numero -> Numero -> Numero
   somma (I m) (I n) = I (m + n)
   somma (I m) (F n) = F (fromIntegral m + n)
   somma (F m) (I n) = F (m + fromIntegral n)
   somma (F m) (F n) = F (m + n)
   ```
   {:.solution}
3. Usando la funzione `somma` dell'esercizio precedente ma senza
   usare esplicitamente la ricorsione, definire una funzione
   `summatoria :: [Numero] -> Numero` che, applicata a una lista di
   numeri, ne calcoli la somma.
   ^
   ``` haskell
   sommatoria :: [Numero] -> Numero
   sommatoria = foldr somma (I 0)
   ```
   {:.solution}
4. Definire una funzione `proprio :: [ForseInt] -> [Int]` che,
   applicata a una lista `xs` di valori di tipo `ForseInt`,
   restituisca la lista dei valori `n` tali che `Proprio n` compare
   in `xs`.
   ^
   ``` haskell
   proprio :: [ForseInt] -> [Int]
   proprio []               = []
   proprio (Niente : xs)    = proprio xs
   proprio (Proprio x : xs) = x : proprio xs
   ```
   {:.solution}
