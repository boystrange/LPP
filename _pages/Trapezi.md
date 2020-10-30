---
title: Integrazione numerica
---

{% include links.md %}

Com'è noto, è possibile approssimare l'integrale di una funzione
$f$ in un intervallo $[a, b]$ con la somma delle aree di $n$ trapezi
usando la formula

$$
  \int_a^b f(x)\mathrm{d}x
  \approx
  \sum_{i=1}^n A_i
$$

in cui

$$
  A_i = \frac{(z_{i-1} + z_i)h}2
  \qquad
  z_i = f(a + ih)
  \qquad
  h = \frac{b - a}n
$$

La quantità $A_i$ rappresenta l'area dell'$i$-esimo trapezio ($1
\leq i \leq n$) avente basi $z_{i-1}$ e $z_i$ e altezza $h$.

In questo caso di studio vedremo come definire una procedura per
l'integrazione numerica con il metodo dei trapezi che sia
parametrica non solo nell'intervallo $[a, b]$ di integrazione e nel
numero $n$ di trapezi da usare per l'approssimazione, ma anche nella
stessa funzione $f$ da integrare in modo tale che la procedura sia
applicabile a funzioni arbitrarie.  Analizzeremo tre soluzioni
differenti: la prima, in Java, illustra come definire e usare
$\lambda$-astrazioni e scrivere metodi Java che accettano funzioni
come argomenti; la seconda, in Haskell, è derivata direttamente
dalla prima applicando la trasformazione di algoritmi
imperativi/iterativi in funzionali/ricorsivi vista in un [precedente
caso di studio](Iterazione.html). La terza e ultima versione che
analizzeremo, sempre in Haskell, non fa uso di ricorsione, ma è
ottenuta esprimendo il metodo di integrazione numerica come una
catena di trasformazioni in [stile dataflow
programming](https://en.wikipedia.org/wiki/Dataflow_programming).

## Implementazione in Java con $\lambda$-astrazioni

Nell'implementazione Java, mostrata qui sotto, notiamo che il metodo
`trapezi` ha, tra i suoi argomenti, un oggetto `f` di tipo
`Function<Double, Double>` che rappresenta la funzione da
integrare. Ogni classe che implementa questa interfaccia deve
fornire un metodo `apply`. Il primo parametro di tipo (`Double`)
rappresenta il tipo dell'argomento del metodo `apply`, mentre il
secondo parametro di tipo (anch'esso `Double`) è il tipo del valore
restituito da `apply`.

``` java
import java.util.function.*;

public class Trapezi {
  public static double trapezi(Function<Double, Double> f,
                               double a, double b, int n) {
    double area = 0;
    double h = (b - a) / n;
    while (n > 0) {
      area += (f.apply(a) + f.apply(a + h)) * h / 2;
      a += h;
      n--;
    }
    return area;
  }

  public static void main(String... args) {
    System.out.println(trapezi(x -> x / 2 + Math.sin(2 * x), 1, 7, 3));
  }
}
```

Il corpo del metodo `trapezi` definisce due variabili locali:

* `area` è la somma (parziale) delle aree dei trapezi usati per
  approssimare l'integrale di `f`;
* `h` è l'altezza di ciascun trapezio, ottenuta dividendo
  l'intervallo per il numero di trapezi.

Il metodo effettua tante iterazioni quanti sono i trapezi e, a ogni
iterazione, aggiorna `area` sommando l'area del trapezio corrente,
fa avanzare `a` alla base del trapezio successivo e decrementa il
numero `n` di iterazioni ancora da completare.  Come ci si aspetta
dal tipo di `f`, osserviamo che "applicare `f` a un argomento `x`"
significa invocare il metodo `apply` su `f` passando `x`.  Per
invocare `trapezi` (nel `main`) occorre passare come primo argomento
il riferimento ad un oggetto istanza di una classe che implementa
l'interfaccia `Function<Double, Double>`. Tale oggetto viene creato
"al volo" per mezzo dell'espressione `x -> x / 2 + Math.sin(2 * x)`
che rappresenta una $\lambda$-astrazione (ovvero una funzione
anonima) che, applicata a un argomento $x$, calcola $\frac{x}2 +
\sin 2x$. Proprio come in Haskell, si usa la freccia `->` per
separare argomento e corpo della $\lambda$-astrazione.

Il fatto che le $\lambda$-astrazioni Java siano rappresentate come
oggetti non deve sorprendere: Java nasce innanzi tutto come
linguaggio appartenente al paradigma object-oriented e nel momento
in cui i progettisti del linguaggio hanno deciso di estenderlo con
le $\lambda$-astrazioni, caratteristica tipica dei linguaggi
funzionali, hanno fatto in modo che le $\lambda$-astrazioni si
integrassero nella maniera più naturale possibile con le
caratteristiche preesistenti di Java.

## Implementazione funzionale ricorsiva

La versione Haskell del metodo `trapezi` può essere ottenuta
facilmente dalla versione Java applicando la [trasformazione di
algoritmi imperativi/iterativi in
funzionali/ricorsivi](Iterazione.html) osservando che il ciclo
`while` modifica le variabili `area`, `a` ed `n`. Il codice Haskell
risultante è mostrato di seguito:

``` haskell
trapezi :: (Double -> Double) -> Double -> Double -> Int -> Double
trapezi f a b n = aux 0 a n
  where
    aux area _ 0 = area
    aux area a n = aux (area + (f a + f (a + h)) * h / 2) (a + h) (n - 1)

    h = (b - a) / fromIntegral n
```

Non ci sono note di rilievo a parte il fatto che, in un linguaggio
funzionale come Haskell, `f` è assimilabile a qualunque altro valore
e dunque non occorre alcun accorgimento particolare per applicare
`trapezi` a `f`. Di seguito è mostrata l'espressione Haskell
corrispondente al `main` della versione Java:

``` haskell
trapezi (\x -> x / 2 + sin (2 * x)) 1 7 3)
```

## Dataflow programming

Come ulteriore sviluppo del caso di studio discutiamo ora una
versione funzionale alternativa in cui non facciamo uso esplicito
della ricorsione, ma cerchiamo invece di calcolare $\sum_{i=1}^n
A_i$ (la somma delle aree $A_i$ degli $n$ trapezi) come risultato di
una serie di trasformazioni a partire da un input opportuno. Come
nella soluzione precedente, possiamo assumere di conoscere la
funzione $f$ da integrare, l'intervallo $[a, b]$ di integrazione, ed
il numero $n$ di trapezi. Questi sono gli argomenti della funzione
`trapezi` mostrata qui sotto e discussa in dettaglio nel resto della
sezione:

``` haskell
trapezi :: (Double -> Double) -> Double -> Double -> Int -> Double
trapezi f a b n = sum as
  where
    zs = map (\i -> f (a + fromIntegral i * h)) [0..n]
    as = map (\(x, y) -> (x + y) * h / 2) (zip zs (tail zs))
    h  = (b - a) / fromIntegral n
```

La prima osservazione fondamentale è che per applicare il metodo di
approssimazione usando $n$ trapezi è necessaria la campionatura
della funzione $f$ in $n+1$ punti sull'asse delle ascisse. Dunque,
eleggiamo come input per avviare la serie di trasformazioni il
numero $n$ dal quale otteniamo la lista $[0, 1, \dots, n]$ dei primi
$n+1$ numeri naturali con l'espressione `[0..n]`.

Successivamente, calcoliamo la lista $[z_0, z_1, \dots, z_n]$ di
campioni trasformando la lista $[0, 1, \dots, n]$ per mezzo di
[`map`]. La trasformazione che ci occorre in questo caso è data dalla
$\lambda$-astrazione $\lambda i.f(a + ih)$ che calcola l'ascissa
dell'$i$-esimo punto di campionatura $a + ih$ ed applica $f$ per
ottenere lo $z_i$ corrispondente. Si noti che nel codice Haskell è
necessario usare [`fromIntegral`] per promuovere $i$ di tipo intero a
[`Double`]. Chiamiamo `zs` la lista $[z_0, z_1, \dots, z_n]$ di
campioni ottenuta e osserviamo che, in questa prima fase, siamo
stati facilitati dal fatto che c'è una relazione diretta tra i
numeri naturali nella lista $[0,1,\dots,n]$ ed i campioni $z_i$ in
`zs`.

Per il calcolo delle aree $A_i$ la situazione è leggermente più
complicata in quanto ogni area $A_i$ è determinata non da *uno*
bensì da *due* campioni $z_{i-1}$ e $z_i$. Non essendoci una
relazione diretta tra gli elementi di `zs` e le aree $A_i$ che
vogliamo ottenere, non è chiaro come esprimere questa trasformazione
usando [`map`], che trasforma singoli elementi di una lista in modo
indipendente uno dall'altro.  L'osservazione fondamentale in questo
caso è che gli elementi $z_{i-1}$ e $z_i$ che servono per
determinare $A_i$ sono sempre **adiacenti** in `zs`. In particolare,
possiamo usare la funzione di libreria [`zip`].

``` haskell
:type zip
```

per accoppiare gli elementi delle liste `zs` e `tail zs`, ottenendo
una lista $[(z_0, z_1), (z_1, z_2), \dots, (z_{n-1}, z_n)]$ di
coppie di elementi adiacenti in `zs`. Notiamo che tale lista ha solo
$n$ elementi, mentre `zs` ne ha $n + 1$, in quanto [`zip`] "tronca" il
risultato se una delle due liste che vengono accoppiate ha meno
elementi dell'altra. Questo comportamento di [`zip`] fa al caso nostro
perché ora possiamo mettere in corrispondenza ogni coppia $(z_{i-1},
z_i)$ con un'area $A_i$ e le aree sono proprio $n$.

Ottenere la lista delle aree $[A_1, A_2, \dots, A_n]$ ora è facile
applicando [`map`] alla trasformazione $\lambda(x,y).(x + y)h/2$ che
calcola l'area di un singolo trapezio con basi $x$ e $y$ ed altezza
$h$.  Non resta che sommare tra loro tutte le aree $A_i$, somma che
si può ottenere con una singola applicazione della funzione di
libreria [`sum`].

## Esercizi

Per la risoluzione dei seguenti esercizi può essere d'aiuto usare la
funzione di libreria [`uncurry`].

1. Senza fare uso esplicito della ricorsione, definire le seguenti funzioni:
   1. `match :: Eq a => [a] -> [a] -> Bool` per determinare se due
	  liste contengono lo stesso elemento nella stessa posizione.
	  ```haskell
	  match :: Eq a => [a] -> [a] -> Bool
	  match xs ys = any (uncurry (==)) (zip xs ys)
	  ```
	  {:.solution}
   2. `adiacenti :: Eq a => [a] -> Bool` per determinare se una
	  lista contiene elementi adiacenti uguali.
	  ```haskell
	  adiacenti :: Eq a => [a] -> Bool
	  adiacenti xs = any (uncurry (==)) (zip xs (tail xs))
	  ```
	  {:.solution}
   3. `polinomio :: [Float] -> Float -> Float` per calcolare
	  $\sum_{i=1}^n a_i x^i$ dati una lista $[a_0, a_1, \dots, a_n]$
	  ed un valore $x$.
	  ```haskell
	  polinomio :: [Float] -> Float -> Float
	  polinomio cs x = sum (map (uncurry (*)) (zip cs (map (x ^) [0..])))
	  ```
	  {:.solution}
   4. `perfetto :: Int -> Bool` per determinare se un numero
      naturale è perfetto, cioè se è pari alla somma dei suoi
      divisori propri.
	  ```haskell
	  perfetto :: Int -> Bool
	  perfetto n = n == sum (filter ((== 0) . (n `mod`)) [1 .. n - 1])
	  ```
	  {:.solution}
   5. `ordinata :: Ord a => [a] -> Bool` per determinare se una
      lista è ordinata.
	  ```haskell
	  ordinata :: Ord a => [a] -> Bool
	  ordinata xs = all (uncurry (<=)) (zip xs (tail xs))
	  ```
	  {:.solution}
2. Usando la definizione di `ordinata` data nelle soluzioni si
   osserva che la valutazione di `ordinata []` produce
   (correttamente) [`True`], nonostante `ordinata` applichi [`tail`]
   alla lista vuota. Come si spiega questo fenomeno?
   ^

   > Occorre tenere presente che Haskell è un linguaggio pigro, cioè
   > in cui gli argomenti di una funzione vengono valutati solo se
   > necessario. Consultando la documentazione di [`zip`] o
   > esaminandone la
   > [definizione](http://hackage.haskell.org/package/base-4.10.0.0/docs/src/GHC.List.html#zip)
   > si evince che [`zip`] è "pigra a destra", ovvero valuta il
   > secondo argomento solo se il primo è diverso da `[]`. Per
   > questo motivo, la valutazione di `ordinata []` non produce un
   > errore nonostante la definizione di `ordinata` contenga
   > un'applicazione `tail []`, in quanto questa espressione compare
   > proprio come secondo argomento di zip e non è necessario
   > valutarla per determinare che `zip [] (tail []) = []`.
   > {:.solution}

