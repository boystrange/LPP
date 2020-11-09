---
title: Derivata simbolica di funzioni
---

## Descrizione del problema
{: id="problema"}

La seguente tabella riporta alcune derivate fondamentali di funzioni
in una variabile $x$:

$$
  \begin{array}{@{}|l|l|@{}}
    \hline
    h(x) & h'(x) \\
    \hline\hline
    n & 0 \\
    \hline
    x & 1 \\
    \hline
    f(x) + g(x) & f'(x) + g'(x) \\
    \hline
    f(x) - g(x) & f'(x) - g'(x) \\
    \hline
    f(x)\cdot g(x) & f'(x)\cdot g(x) + f(x)\cdot g'(x) \\
    \hline
    f(x)^n & n\cdot f(x)^{n-1}\cdot f'(x) \\
    \hline
  \end{array}
$$

In questo caso di studio sviluppiamo un programma Haskell in grado
di calcolare la derivata di una funzione in una variabile $x$. In
particolare, consideriamo le funzioni generate dalla grammatica

$$
  F, G ~~::=~~ n ~~\mid~~ x ~~\mid~~ F + G ~~\mid~~ F - G ~~\mid~~ F \cdot G ~~\mid~~ F / G ~~\mid~~ F^n
$$

dove $n$ è un numero intero.

## Rappresentazione di funzioni in una variabile

La grammatica delle funzioni suggerisce una rappresentazione delle
stesse per mezzo di un tipo di dato ricorsivo con tanti costruttori
quante sono le produzioni della grammatica. Per economizzare la
definizione del tipo di dato e di tutte le funzioni che operano su
di esso scegliamo di **non** rappresentare esplicitamente una
funzione della forma $F/G$, dal momento che questa è rappresentabile
internamente come la funzione $F \cdot G^{-1}$.  Otteniamo il tipo
di dato algebrico `Fun` definito nel modo seguente:

``` haskell
data Fun = X
         | Con Int
         | Fun :+: Fun
         | Fun :-: Fun
         | Fun :*: Fun
         | Fun :^: Int
```

in cui i costruttori `X :: Fun` e `Con :: Int -> Fun` servono per
rappresentare la variabile $x$ e una costante, rispettivamente. Ai
restanti costruttori, che rappresentano le operazioni di somma,
sottrazione, moltiplicazione ed esponenziazione, diamo
rispettivamente i **nomi simbolici** `:+:`, `:-:`, `:*:` e
`:^:`. Questo ci consente di usarli in notazione infissa non solo
nella definizione stessa di `Fun` e per creare valori di tipo `Fun`,
ma anche nei pattern di valori di tipo `Fun`. Ad esempio, possiamo
rappresentare la funzione $f(x) = 1 + x^2$ con il termine

``` haskell
Con 1 :+: X :^: 2
```

invece che con il termine

``` haskell
(:+:) (Con 1) ((:^:) X 2)
```

che è sicuramente meno leggibile. In Haskell, i costruttori con nomi
simbolici devono obbligatoriamente iniziare con il simbolo `:`.

Riguardando il termine `Con 1 :+: X :^: 2` può sorgere un dubbio
riguardo alla sua interpretazione, visto che ce ne sono due
possibili. L'interpretazione desiderata è

``` haskell
Con 1 :+: (X :^: 2)
```

in cui l'operatore di esponenziazione ha priorità maggiore della
somma. L'altra interpretazione è

``` haskell
(Con 1 :+: X) :^: 2
```

che, sebbene violi le normali convenzioni sulla precedenza degli
operatori, per Haskell è del tutto plausibile dal momento che non vi
è, in linea di principio, alcuna semantica intrinseca nei simboli
`:+:` e `:^:` che abbiamo scelto. Per essere sicuri che Haskell dia
a questi operatori la precedenza convenzionale, possiamo aggiungere
allo script le seguenti **fixity declarations**:

``` haskell
infixr 2 :+:, :-:
infixr 3 :*:
infixl 4 :^:
```

Ogni dichiarazione assegna a uno o più simboli una associatività (a
destra nel caso di `infixr` e a sinistra nel caso di `infixl`) e una
priorità indicata con un numero da 0 a 9. In questo caso stiamo
dichiarando `:+:` e `:-:` come operatori associativi a destra
con priorità 2, dunque inferiore a quella dell'operatore `:*:`,
anch'esso associativo a destra ma con priorità 3. L'operatore
`:^:` ha priorità maggiore di tutti ed è associativo a sinistra,
in modo che il termine

``` haskell
X :^: 2 :^: 3
```

rappresenti $(x^2)^3$ e non $x^{2^3}$ che non è nemmeno
sintatticamente corretto in base alla grammatica data in precedenza.

Seguono un paio di esempi di termini ben tipati, il primo che
rappresenta $1 + x^2$ ed il secondo che rappresenta $(1 + x)^2$.

``` haskell
:type Con 1 :+: X :^: 2
:type (Con 1 :+: X) :^: 2
```

## Visualizzazione di funzioni

Prima di affrontare il problema principale di questo caso di studio
ci poniamo il problema di convertire valori di tipo `Fun` in
stringhe, in modo da poter visualizzare tali valori.

Un modo automatico (e dunque rapido) di risolvere il problema è
quello di aggiungere una clausola `deriving Show` alla definizione
del tipo `Fun`, come abbiamo già fatto in altre occasioni. Così
facendo, però, ci dovremmo accontentare della sintassi usata nella
definizione di `Fun`. Per ottenere una notazione il più possibile
familiare, limitatamente a quanto è possibile con sequenze di
caratteri, definiamo una istanza della classe `Show`. In
particolare, forniamo una implementazione della funzione `show` che
faccia il "pretty printing" di un valore di tipo `Fun` usando la
notazione convenzionale. L'unico aspetto critico che complica
leggermente la definizione di `show` è che vogliamo minimizzare il
numero di parentesi utilizzate senza generare ambiguità
nell'interpretazione di una funzione. Per questo motivo abbiamo
bisogno di definire una funzione ausiliaria "contestuale" che decide
se generare o meno parentesi a seconda del contesto in cui viene
applicata:

``` haskell
instance Show Fun where
  show = auxU
    where
      auxU X = "x"
      auxU (Con n) = show n
      auxU (f :+: g) = auxG 2 f ++ " + " ++ auxG 2 g
      auxU (f :-: g) = auxG 2 f ++ " - " ++ auxG 2 g
      auxU (f :*: g) = auxG 3 f ++ " * " ++ auxG 3 g
      auxU (f :^: n) = auxG 4 f ++ "^" ++ show n

      auxG p f@(_ :+: _) | p > 2 = parens (auxU f)
      auxG p f@(_ :-: _) | p > 2 = parens (auxU f)
      auxG p f@(_ :*: _) | p > 3 = parens (auxU f)
      auxG _ f = auxU f

      parens s = "(" ++ s ++ ")"
```

La funzione `show` è definita in termini di due funzioni ausiliarie
e mutuamente ricorsive `auxU` (per "unguarded", che non produce mai
parentesi) e `auxG` (per "guarded", che produce parentesi laddove
necessario). La funzione `auxG` ha un argomento aggiuntivo `p` che
rappresenta la priorità dell'operatore che compare nel contesto in
cui viene stampata una funzione `f` e che serve a decidere se le
parentesi servono oppure no. Se tale priorità risulta essere
maggiore di quella dell'operatore principale di `f` occorre
proteggere `f` all'interno di una coppia di parentesi. In caso
contrario, `f` viene visualizzata senza parentesi dalla funzione
ausiliaria `auxU`. Notare che tutte le applicazioni ricorsive di
`auxG` all'interno di `auxU` hanno come priorità quella
dell'operatore principale della funzione.

Avendo definito questa istanza della classe `Show` possiamo
visualizzare valori di tipo `Fun`:

``` haskell
Con 1 :+: X :^: 2
(Con 1 :+: X) :^: 2
Con 2 :*: X :+: Con 1
Con 2 :*: (X :+: Con 1)
```

## Derivata e semplificazione di funzioni

Il calcolo della derivata di una funzione si realizza con una
semplice funzione ricorsiva `derive` che, in base al costruttore
principale usato per rappresentare la funzione, produce una nuova
funzione secondo la tabella mostrata [qui sopra](#problema). In
codice Haskell:

``` haskell
derive :: Fun -> Fun
derive X         = Con 1
derive (Con _)   = Con 0
derive (f :+: g) = derive f :+: derive g
derive (f :-: g) = derive f :-: derive g
derive (f :*: g) = f :*: derive g :+: derive f :*: g
derive (f :^: n) = Con n :*: f :^: (n - 1) :*: derive f
```

Verifichiamo il comportamento di `derive` sugli esempi considerati
in precedenza:

``` haskell
derive (Con 1 :+: X :^: 2)
derive ((Con 1 :+: X) :^: 2)
derive (Con 2 :*: X :+: Con 1)
derive (Con 2 :*: (X :+: Con 1))
```

Anche se i risultati sono semanticamente corretti, la prima cosa che
si nota è la loro complessità sintattica. Il punto è che la funzione
`derive` si limita ad applicare meccanicamente le regole per il
calcolo della derivata di una funzione, ma non opera alcuna
semplificazione del risultato. Una parziale ma efficace
semplificazione si può ottenere applicando alcune note regole
dell'aritmetica, come il fatto che l'1 è neutro per la
moltiplicazione e l'esponenziazione mentre lo 0 è assorbente e
neutro per moltiplicazione e addizione, rispettivamente.  È
possibile realizzare questa semplificazione con una funzione
`simplify`, la cui definizione è lasciata come esercizio.

In conclusione, notiamo che è possibile ottenere la funzione che
calcola la derivata seconda (e, in generale, la derivata $n$-esima)
tramite la composizione funzionale di `derive` con se stessa:

``` haskell
derive2 :: Fun -> Fun
derive2 = derive . derive
```

``` haskell
derive2 (Con 2 :*: (X :+: Con 1))
derive2 (Con 2 :*: (X :+: Con 1) :^: 3)
```

## Esercizi

1. Definire una funzione `eval :: Fun -> Float -> Float` che,
   applicata a un termine `f` di tipo `Fun` che rappresenta una
   funzione $f(x)$ e a un valore $v$, restituisca $f(v)$.
2. Estendere il tipo `Fun` con nuovi costruttori per rappresentare
   la costante $e$, le funzioni trigonometriche $\sin$ e $\cos$ e la
   funzione logaritmica $\log_n$. Apportare le modifiche necessarie
   alla definizione dell'istanza di `Show` e di `derive` per gestire
   i nuovi costruttori.
3. Implementare la funzione `simplify`. Suggerimento: è
   utile usare il costrutto `case`.

Le soluzioni sono incluse nel file
[Derivata.hs](assets/haskell/Derivata.hs) che contiene il codice
discusso in questo caso di studio.
