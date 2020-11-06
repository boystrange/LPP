---
title: Matching di espressioni regolari
tex_macros: |
  \newcommand{\ling}{\mathcal{L}}
  \newcommand{\set}[1]{\{#1\}}
  \newcommand{\nullable}{\mathit{null}}
  \newcommand{\derive}[2]{#2[#1]}
---

## Descrizione del problema

Le espressioni regolari sono un formalismo conveniente per
descrivere linguaggi regolari. Fissato un alfabeto $\Sigma$ di
simboli, denotiamo gli elementi di $\Sigma$ con le lettere minuscole
$a$, $b$, ..., e le stringhe su $\Sigma$ (ovvero le sequenze finite
di simboli in $\Sigma$) con $v$ e $w$. Le espressioni regolari su
$\Sigma$ sono definite dalla seguente grammatica libera:

$$
  F, G ~~::=~~ \emptyset ~~\mid~~ \varepsilon ~~\mid~~ a ~~\mid~~ F + G ~~\mid~~ FG ~~\mid~~ F^*
$$

Il linguaggio $\ling(F)$ generato da un'espressione regolare $F$ è
definito per induzione sulla struttura di $F$ dalle seguenti
equazioni:

$$
  \begin{array}{rcl}
    \ling(\emptyset) & = & \emptyset
    \\
    \ling(\varepsilon) & = & \set\varepsilon
    \\
    \ling(a) & = & \set{a}
    \\
    \ling(F + G) & = & \ling(F) \cup \ling(G)
    \\
    \ling(FG) & = & \set{ vw \mid v \in \ling(F) \wedge w \in \ling(G) }
    \\
    \ling(F^*) & = & \set\varepsilon \cup \ling(F) \cup \ling(FF) \cup \ling(FFF) \cup \cdots
  \end{array}
$$

dove $\varepsilon$ denota la stringa vuota e la concatenazione di
due stringhe $v$ e $w$ è rappresentata, come al solito,
giustapponendo $v$ e $w$.

Il problema che vogliamo affrontare in questo caso di studio è
quello di definire una funzione che, applicata a una espressione
regolare $F$ (opportunamente rappresentata) e a una stringa $v$,
determini se $v\in\ling(F)$. Il problema è reso non banale a causa
del fatto che l'insieme $\ling(F)$ è in generale infinito (basta
osservare l'equazione per $\ling(F^*)$ per rendersene conto). Nel
corso di Linguaggi Formali e Traduttori è stato visto un metodo
finito per risolvere il problema che consiste nel generare, a
partire dall'espressione regolare $F$, un automa a stati finiti
deterministico equivalente, ovvero che riconosce lo stesso
linguaggio generato dall'espressione regolare. Ottenuto l'automa, il
problema di verificare se $v\in\ling(F)$ si riduce dunque al
problema di determinare se l'automa riconosce $v$, riconoscimento
che può essere effettuato seguendo sull'automa il percorso (unico)
etichettato con la stringa $v$ e verificando se lo stato raggiunto
al termine del percorso è finale oppure no.

La parte complessa di questo approccio è evidentemente la
generazione dell'automa a partire dall'espressione regolare. In
questo caso di studio risolviamo il problema seguendo un approccio
alternativo che consente di decidere se $v\in\ling(F)$ utilizzando
*esclusivamente* la struttura dell'espressione regolare
$F$. L'approccio fa uso di un operatore su espressioni regolari
detto [derivata di
Brzozowski](https://en.wikipedia.org/wiki/Brzozowski_derivative),
dal nome dall'informatico Janusz Brzozowski.

## Soluzione del problema

Per prima cosa dobbiamo stabilire una rappresentazione delle
espressioni regolari. Osservando attentamente la grammatica data qui
sopra, è possibile notare una certa analogia tra le produzioni della
grammatica e i costruttori di un tipo di dato algebrico. In
particolare, definiamo un tipo di dato `RegExp` dotato di tanti
costruttori quante sono le possibili forme di un'espressione
regolare. Per ottenere il tipo più generico possibile, senza fissare
a priori l'alfabeto di riferimento su cui definire le espressioni
regolari, rendiamo `RegExp` polimorfo nel tipo `a` dei simboli
dell'alfabeto.

``` haskell
data RegExp a = Nil
              | Eps
              | Atom a
              | Sum (RegExp a) (RegExp a)
              | Seq (RegExp a) (RegExp a)
              | Star (RegExp a)
  deriving Show
```

Ad esempio, l'espressione regolare $0^\ast1^\ast$ può essere
rappresentata dal seguente valore di tipo `RegExp Int`:

``` haskell
f :: RegExp Int
f = Seq (Star (Atom 0)) (Star (Atom 1))
```

Diciamo che una espressione regolare $F$ è **annullabile** se
$\varepsilon\in\ling(F)$. Osserviamo che il problema di determinare
se $F$ è annullabile è facilmente risolvibile analizzando la
struttura stessa di $F$. In particolare, possiamo definire la
seguente funzione che, applicata a un'espressione regolare $F$,
restituisce `True` se $F$ è annullabile e `False` altrimenti:

``` haskell
nullable :: RegExp a -> Bool
nullable Nil       = False
nullable Eps       = True
nullable (Atom _)  = False
nullable (Sum f g) = nullable f || nullable g
nullable (Seq f g) = nullable f && nullable g
nullable (Star _)  = True
```

``` haskell
nullable (Atom 0)
nullable f
```

Data un'espressione regolare $F$ su $\Sigma$ ed un simbolo
$a\in\Sigma$, la **derivata** di $F$ rispetto ad $a$, che denotiamo
con $\derive{a}{F}$, è un'espressione regolare con la proprietà
$\ling(\derive{a}{F}) = \set{ v \mid av \in \ling(F) }$. A parole,
$\derive{a}{F}$ genera il linguaggio dei suffissi di quelle stringhe
in $\ling(F)$ che iniziano con $a$.  L'aspetto interessante è che
possiamo definire $\ling(\derive{a}{F})$ induttivamente sulla
struttura di $F$, usando le seguenti equazioni:

$$
  \begin{array}{rcll}
    \derive{a}{\emptyset} & = & \emptyset
    \\
    \derive{a}{\varepsilon} & = & \emptyset
    \\
    \derive{a}{a} & = & \varepsilon
    \\
    \derive{a}{b} & = & \emptyset & \text{se $a\ne b$}
    \\
    \derive{a}{(F+G)} & = & \derive{a}{F} + \derive{a}{G}
    \\
    \derive{a}{(FG)} & = & (\derive{a}{F})G & \text{se $\varepsilon\not\in\ling(F)$}
    \\
    \derive{a}{(FG)} & = & (\derive{a}{F})G + \derive{a}{G} & \text{se $\varepsilon\in\ling(F)$}
    \\
    \derive{a}{(F^*)} & = & (\derive{a}{F})F^*
  \end{array}
$$

Combinando il predicato di annullabilità e la definizione di
derivata, è possibile ottenere una procedura per decidere se
$v\in\ling(F)$. Sia $v = a_1a_2\cdots a_n$. Allora $v\in\ling(F)$ se
e solo se $\varepsilon \in
\ling(\derive{a_n}{\derive{a_2}{\derive{a_1}{F}}\cdots})$.  In altre
parole, per determinare se $v\in\ling(F)$ è sufficiente calcolare
ripetutamente la derivata di $F$ rispetto ai simboli $a_1, a_2,
\dots, a_n$ che compongono $v$ e poi verificare se l'espressione
regolare risultante è annullabile.

## Esercizi

1. Definire una funzione `derive :: Eq a => RegExp a -> a -> RegExp
   a` che, applicata a un'espressione regolare $F$ e a un simbolo
   $a$, calcoli $\derive{a}{F}$.
2. Definire una funzione `match :: Eq a => RegExp a -> [a] -> Bool`
   che, applicata a un'espressione regolare $F$ e a una lista $v$ di
   simboli, restituisca `True` se $v\in\ling(F)$ e `False`
   altrimenti. Se possibile, definire `match` senza fare uso
   esplicito della ricorsione.
3. Definire una funzione `empty :: RegExp a -> Bool` che, applicata
   a un'espressione regolare $F$, restituisca `True` se $\ling(F) =
   \emptyset$ e `False` altrimenti.
4. (Variante più generale e più complessa del precedente) Diciamo
   che $F$ è in **forma normale** se $F$ è $\emptyset$ oppure se in
   $F$ non compare $\emptyset$. Usando le proprietà

   * $\emptyset F = F \emptyset = \emptyset$
   * $\emptyset + F = F + \emptyset = F$
   * $\emptyset^\ast = \varepsilon$

   è facile dimostrare che ogni espressione regolare è
   **equivalente** a una in forma normale. Definire una funzione
   `normalize :: RegExp a -> RexExp a` che, applicata a
   un'espressione regolare $F$, restituisca un'espressione in forma
   normale equivalente a $F$.

Le soluzioni sono incluse nel file
[Matching.hs](assets/haskell/Matching.hs) che contiene il codice
discusso in questo caso di studio.
