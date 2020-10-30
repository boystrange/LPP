---
title: La lista infinita dei numeri primi
---

{% include links.md %}

In questo caso di studio illustriamo come la *laziness* di Haskell
consenta la scrittura di programmi modulari laddove è solitamente
necessario intercalare operazioni di **produzione** e **selezione**
di informazione.

## Soluzione iterativa/ricorsiva

Il problema che andiamo a risolvere in questo caso di studio è
quello del calcolo dei primi $n$ numeri primi, per un $n$
arbitrario. È noto che ci sono infiniti numeri primi distribuiti in
modo irregolare nella sequenza dei numeri naturali, dunque il
problema richiede una scansione della sequenza numeri naturali da 2
in poi (2 è il primo numero primo) fino a un limite che non è
possibile calcolare a priori (non vi è una relazione diretta tra $n$
e l'$n$-esimo numero primo).

La soluzione più ovvia, che esaminiamo prima in Java e che fa uso
del metodo `primo` [discusso in
precedenza](Iterazione.html#descrizione-del-problema), realizza tale
scansione con un ciclo `while` e aggiunge ogni numero primo
individuato a una lista fino a quando questa non raggiunge la
dimensione $n$.

``` java
public static ArrayList<Integer> primi(int n) {
    ArrayList<Integer> l = new ArrayList<>();
    int k = 2;
    while (n > 0) {
        if (primo(k)) {
            l.add(k);
            n--;
        }
        k++;
    }
    return l;
}
```

Notando che il ciclo `while` può modificare a ogni iterazione le
variabili locali `n` e `k`, possiamo trasporre questa soluzione
iterativa in Haskell definendo una funzione ausiliaria `aux` con due
argomenti che produce la lista desiderata.

``` haskell
primi :: Int -> [Integer]
primi = aux 2
  where
    aux _ 0 = []
    aux k n | primo k   = k : aux (k + 1) (n - 1)
            | otherwise = aux (k + 1) n
```

La caratteristica comune di queste due realizzazioni è che in
entrambe sono presenti fasi di **produzione** dell'informazione e
altre di **selezione** dell'informazione:

* **Produzione**: Nella versione Java si considera la lista dei
  numeri naturali a partire da 2 per mezzo di una variabile locale
  `k` inizializzata a 2 e incrementata a ogni iterazione del
  ciclo. Nella versione Haskell si usa il primo argomento di `aux`
  che è impostato a 2 nella prima applicazione di `aux` e
  incrementato a ogni ricorsione. Queste combinazioni di
  inizializzazione/incremento rappresentano logicamente la scansione
  di questa lista di numeri, anche se la lista non viene prodotta
  materialmente.
* **Selezione**: dalla lista di numeri prodotta si selezionano solo
  i numeri primi (si veda l'`if` nella versione Java e la guardia
  `primo k` nella versione Haskell).
* **Selezione**: dei numeri primi così individuati si considerano
  solo i primi $n$ (si veda la condizione `n > 0` del ciclo `while`
  nella versione Java e il caso base di `aux` nella versione
  Haskell).

Notiamo infine che queste fasi sono mescolate in maniera non banale,
nel senso che non è semplice separare il codice che riguarda le une
e le altre. Questo avviene perché il codice è concepito in modo tale
da far terminare la fase di produzione dell'informazione non appena
quella di selezione ha raggiunto il suo obiettivo.

``` haskell
primi 100
```

## Soluzione in stile dataflow

È possibile riscrivere la funzione `primi` in maniera da
identificare (e quindi distinguere) chiaramente le fasi di
produzione e selezione dell'informazione sfruttando la
caratteristica di Haskell di essere un linguaggio *lazy*, in cui gli
argomenti di una funzione sono valutati solo se necessario. L'idea
di base è di produrre materialmente la lista (infinita) dei numeri
naturali a partire da 2, da questa selezionare solo i numeri primi e
poi troncare la lista risultante considerando solo i primi $n$
elementi.

Nella libreria standard di Haskell è presente la funzione [`enumFrom`]
che genera la lista degli elementi di un tipo appartenente alla
classe [`Enum`] a partire dall'elemento dato come argomento della
funzione.

``` haskell
enumFrom :: Enum a => a -> [a]
enumFrom n = n : enumFrom (succ n)
```

In un linguaggio di programmazione convenzionale -- cioè che usa
l'ordine **applicativo** per la riduzione delle espressioni --
questa definizione di [`enumFrom`] sarebbe inutilizzabile. Infatti,
notiamo che `enumFrom n` produce una lista che ha `n` come testa e
il risultato di `enumFrom (succ n)` come coda. L'ordine applicativo
richiederebbe la valutazione di `enumFrom (succ n)` **prima** di
dell'applicazione del costruttore `(:)` per produrre la lista
risultante. Dal momento che [`enumFrom`] produce (in generale) una
lista infinita, questa valutazione non avrebbe mai fine e non si
otterrebbe alcun risultato o, più probabilmente, un errore come
*stack overflow* causato dalle troppe applicazioni ricorsive di
[`enumFrom`].

In Haskell, la definizione di [`enumFrom`] è utile dal momento che
l'argomento `enumFrom (succ n)` di `(:)` è valutato solo se
necessario. Per convincerci di questo fatto è possibile fare alcuni
semplici esperimenti in cui accediamo a una porzione **finita**
della lista prodotta da [`enumFrom`]:

``` haskell
head (enumFrom 2)        -- il primo elemento di enumFrom 2
head (tail (enumFrom 2)) -- il secondo elemento di enumFrom 2
enumFrom 2 !! 5          -- il sesto elemento di enumFrom 2
take 10 (enumFrom 2)     -- i primi 10 elementi di enumFrom 2
```

Valutando `enumFrom 2`, GHCi tenta invano di visualizzare l'intera
lista. Si può interrompere la valutazione della seguente espressione
premendo la combinazione di tasti `CTRL-C`:

``` haskell
enumFrom 2
```

Ritornando al problema oggetto di questo caso di studio, possiamo
ora concepire una implementazione alternativa di `primi` in stile
*dataflow* che sfrutti la *laziness* di Haskell:

``` haskell
primi :: Int -> [Integer]
primi n = take n (filter primo (enumFrom 2))
```

La struttura di `primi` è semplice: si **produce** la lista di tutti
i numeri naturali a partire da 2 con `enumFrom 2`. Da questa, si
selezionano solo i numeri primi con `filter primo`. Della lista
risultante, si seleziona solo il prefisso di lunghezza `n` con `take
n`. Da notare che entrambe le liste `enumFrom 2` che `filter primo
(enumFrom 2)` sono potenzialmente infinite e vengono materialmente
prodotte "a richiesta" fintantoché [`take`] non ha selezionato `n`
numeri primi.

## Esercizi

1. Definire una funzione non ricorsiva `primoMaggioreDi :: Integer ->
   Integer` che, applicata a un numero intero $n$, restituisca il più
   piccolo numero primo maggiore di $n$.
   ^
   ``` haskell
   primoMaggioreDi :: Integer -> Integer
   primoMaggioreDi n = head (filter (> n) (filter primo (enumFrom 2)))

   -- OPPURE --

   primoMaggioreDi :: Integer -> Integer
   primoMaggioreDi n = head (filter primo (enumFrom (max 2 (n + 1))))
   ```
   {:.solution}
2. Due numeri primi che differiscono di 2 sono chiamati **primi
   gemelli**. Ad esempio 3 e 5 sono primi gemelli, mentre 2 e 3 non
   lo sono. Definire una funzione `primiGemelli :: Int -> (Integer,
   Integer)` che, applicata a un numero $n$ non negativo,
   restituisca le prime $n$ coppie di primi gemelli.
   ^
   ``` haskell
   primiGemelli :: Int -> [(Integer, Integer)]
   primiGemelli n = take n (filter gemelli (zip ps (tail ps)))
     where
       ps = filter primo (enumFrom 2)
       gemelli (p, q) = q == p + 2
   ```
   {:.solution}
3. Che caratteristica ha la lista `xs` definita nel seguente modo?
   Per rispondere, consultare la documentazione della funzione di
   libreria [`zipWith`] e usare [`take`] per esaminare `xs`.
   ^
   ``` haskell
   xs :: [Integer]
   xs = 0 : 1 : zipWith (+) xs (tail xs)
   ```
   ^
   > È la sequenza di Fibonacci.
   {:.solution}
