---
title: Funzioni
---

{% include links.md %}

## Definizione e applicazione di funzioni

Una **funzione** rappresenta una particolare trasformazione da un
**dominio** (l’insieme dei dati che la funzione può accettare) a un
**codominio** (l’insieme dei dati che la funzione può produrre). Il
seguente esempio definisce la funzione _successore_, ovvero quella
funzione che, applicata a un numero intero $x$ (di tipo [`Int`]),
produce $x + 1$.

```haskell
successore :: Int -> Int
successore x = x + 1
```

Come per le definizioni di valori semplici, anche la definizione di
una funzione è (solitamente) preceduta da una dichiarazione che ne
stabilisce il **tipo**.  Il tipo di una funzione ha la forma $T \to
S$ dove $T$ rappresenta il dominio ed $S$ il codominio. In questo
caso, dominio e codominio sono [`Int`] a indicare il fatto che la
funzione accetta e produce numeri interi (di tipo [`Int`]).  La
funzione vera e propria è definita da una **equazione** `successore
x = x + 1` che si può leggere come “la funzione `successore`
applicata all’argomento `x` produce il valore `x + 1`”.

Usare una funzione significa applicarla a un argomento. I seguenti
sono esempi di utilizzo della funzione `successore` appena definita:

```haskell
successore 0
successore 1
successore 2 * 3
(successore 2) * 3
successore (2 * 3)
```

Al solito, l’applicazione di funzione ha priorità rispetto a tutti
gli altri operatori, dunque l’espressione `successore 2 * 3` deve
essere interpretata `(successore 2) * 3` e non `successore (2 * 3)`.

## Predicati

Una funzione che ha come codominio il tipo [`Bool`] dei valori di
verità può essere pensata come a un **predicato** che stabilisce se
il suo argomento soddisfa o meno una certa proprietà. Per esempio,
la seguente funzione determina se un numero intero è pari o no:

```haskell
pari :: Int -> Bool
pari n = n `mod` 2 == 0
```

Il valore prodotto dall’applicazione di `pari` a `n` è il booleano
[`True`] se il resto della divisione di `n` per 2 è 0 (dunque se `n` è
pari) e [`False`] altrimenti. Ad esempio:

```haskell
pari 0
pari 2
pari 3
```

## Operatore di composizione funzionale

Possiamo **comporre** due funzioni usando l’operatore di
composizione funzionale [`.`] (il punto). Per esempio, abbiamo appena
definito al funzione `pari` che determina se un numero è pari. Il
predicato “essere un numero dispari” può essere espresso come la
negazione del predicato “essere un numero pari”, nel seguente modo:

```haskell
dispari :: Int -> Bool
dispari = not . pari
```

Come in matematica, la funzione composta `f . g` trasforma il
proprio argomento _da destra verso sinistra_. In altre parole, `f
. g` è la funzione che, applicata a un argomento _x_, calcola `f (g
x)`. Dunque, `not . pari` applicata a un numero `n` calcola `not
(pari n)`.  Notare che l’equazione `dispari = not . pari` che
definisce `dispari` non dà alcun nome all’argomento della funzione,
ma si limita a dire che `dispari` è la funzione ottenuta dalla
composizione di [`not`] e `pari`.

## Esercizi

1. Ridefinire la funzione `dispari` senza fare uso dell’operatore di
   composizione funzionale.
   ```haskell
   dispari :: Int -> Bool
   dispari n = n `mod` 2 /= 0
   ```
   {:.solution}
2. Un anno è bisestile se è multiplo di 4 ma non di 100, oppure se è
   multiplo di 400. Definire un predicato `bisestile :: Int -> Bool`
   che, applicato a un numero $n$, determini se $n$ è un anno
   bisestile.
   ```haskell
   bisestile :: Int -> Bool
   bisestile n = (n `mod` 4 == 0 && n `mod` 100 /= 0) || n `mod` 400 == 0
   ```
   {:.solution}
3. È noto che la somma dei primi $n$ numeri naturali è data dalla
   formula $\frac{n(n + 1)}2$.  Definire una funzione `somma :: Int
   -> Int` che, applicata a un numero interno $n$ non negativo,
   calcoli la somma dei primi $n$ numeri naturali usando questa
   formula.
   ```haskell
   somma :: Int -> Int
   somma n = (n * (n + 1)) `div` 2
   ```
   {:.solution}
4. Definire una funzione `area :: Float -> Float` che, applicata a
   un numero floating-point `n` non negativo, calcoli l’area del
   cerchio di raggio `n`.
   ```haskell
   area :: Float -> Float
   area n = n ** 2 * pi
   ```
   {:.solution}
5. Che funzione è `not . not`?
   > La funzione identità su valori di tipo [`Bool`].
   {:.solution}
