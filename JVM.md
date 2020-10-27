---
title: Implementazione della Java Virtual Mini-Machine
tex_macros: |
  \newcommand{\PUSH}[1]{\mathtt{PUSH}~{#1}}
  \newcommand{\LOAD}[1]{\mathtt{LOAD}~{#1}}
  \newcommand{\STORE}[1]{\mathtt{STORE}~{#1}}
  \newcommand{\OP}[1]{\mathtt{OP}~{#1}}
  \newcommand{\IF}[2]{\mathtt{IF}~{#1}~{#2}}
  \newcommand{\RETURN}{\mathtt{RETURN}}
---

{% include links.md %}

## Descrizione del problema

In questo caso di studio realizziamo un esecutore per la Java
Virtual Mini-Machine (JVMM), una versione minimale ma comunque
espressiva della Java Virtual Machine.  In particolare, consideriamo
il seguente insieme di istruzioni

| Istruzione             | Prima | $\to$ | Dopo     | Descrizione                                                                    |
|:-----------------------|------:|:-----:|:---------|--------------------------------------------------------------------------------|
| $\PUSH{v}$             |       | $\to$ | $v$      | Inserisce il valore $v$ sullo stack                                            |
| $\LOAD{x}$             |       | $\to$ | $v$      | Legge il valore $v$ dallo slot di $x$ e lo inserisce sullo stack               |
| $\STORE{x}$            |   $v$ | $\to$ |          | Rimuove $v$ dallo stack e lo scrive nello slot di $x$                          |
| $\OP{f}$               | $w,v$ | $\to$ | $f(v,w)$ | Rimuove $w$ e poi $v$ dallo stack e inserisce $f(v,w)$ sullo stack             |
| $\IF{\mathcal{R}}\ell$ | $w,v$ | $\to$ |          | Rimuove $w$ e poi $v$ dallo stack e salta a $\ell$ se $(v, w) \in \mathcal{R}$ |
| $\RETURN$              |   $v$ | $\to$ |          | Rimuove $v$ dallo stack e termina l'esecuzione con risultato $v$               |

in cui $v$ e $w$ rappresentano **valori** della JVMM che limitiamo
ai numeri interi, $x$ rappresenta il nome di una variabile locale,
$f$ rappresenta una funzione binaria su valori (somma, sottrazione,
moltiplicazione, ecc.)  ed $\mathcal{R}$ rappresenta una relazione
binaria tra valori (uguale a, minore di, ecc.).  Per ogni
istruzione, la tabella mostra gli eventuali argomenti, i valori che
l'istruzione si aspetta di trovare in cima allo stack prima di
essere eseguita (a sinistra del simbolo $\to$) ed i valori che
l'istruzione inserisce sullo stack durante la sua esecuzione (a
destra del simbolo $\to$). Quando più valori sono indicati, si
intende che quello più a sinistra è quello in cima allo stack.

Ad esempio, il programma

$$
  \begin{array}{rl}
    & \LOAD{x} \\
    & \LOAD{y} \\
    & \IF{<}{\ell} \\
    & \LOAD{x} \\
    & \RETURN \\
    \ell: & \LOAD{y} \\
    & \RETURN
  \end{array}
$$

calcola il massimo tra i valori memorizzati nelle variabili $x$ ed
$y$.

## Definizione delle strutture fondamentali

Nella JVMM vi sono tre strutture fondamentali:
* lo *stack*, usato come contenitore di dimensione variabile
  per valori temporanei, dal quale le istruzioni rimuovono valori e
  sul quale le istruzioni inseriscono risultati;
* il *frame*, definito come una collezione finita di
  *slot*, uno per ogni variabile usata dal programma. Uno slot
  è una cella di memoria contenente il valore della variabile
  corrispondente;
* il *codice*, ovvero la sequenza di istruzioni che
  compongono il programma da eseguire.

Implementare la JVMM significa stabilire e definire opportune
rappresentazioni per queste strutture. Iniziamo definendo alcuni
*alias* di tipo per valori, variabili, stack e frame:

``` haskell
type Value = Int
type Var   = Int
type Stack = [Value]
type Frame = [Value]
```

In questa versione della JVMM gli unici valori sono numeri interi,
dunque il tipo `Value` non è altro che un nome alternativo (e più
significativo) del tipo [`Int`]. Come nella JVM, si accede alle
variabili memorizzate in un frame attraverso il loro indice, per cui
definiamo `Var` come alias per [`Int`]. Infine, possiamo usare le
liste come comoda rappresentazine per stack e frame della JVMM, che
non sono altro che collezioni di valori.

Per quanto riguarda lo stack, usiamo del costruttore `:` per
modellare l'inserimento di un valore in cima allo stack ed il
pattern matching per rimuovere uno o più valori dallo stack. Ad
esempio, la lista

``` haskell
[2, 3]
```

rappresenta lo stack con il valore 2 in cima ed il valore 3 subito
sotto.

Per quanto riguarda il frame, stabiliamo che lo slot per la
variabile con indice $x$ è l'$x$-esimo elemento della lista. Dunque,
la lista di cui sopra rappresenta un frame con due variabili, quella
con indice 0 ha valore 2 e quella con indice 1 ha valore 3. Per
leggere e scrivere il valore di una variabile definiamo due funzione
ausiliarie `load` e `store` come segue.

``` haskell
load :: Var -> Frame -> Value
load _ [] = 0
load 0 (v : _) = v
load n (_ : vs) = load (n - 1) vs

store :: Var -> Value -> Frame -> Frame
store 0 v []       = [v]
store 0 v (_ : vs) = v : vs
store n v []       = 0 : store (n - 1) v []
store n v (w : vs) = w : store (n - 1) v vs
```

La funzione `load`, applicata a una variabile $x$ e a un frame $f$,
scorre $f$ fino a individuare lo slot in posizione $x$.  Se $x$
eccede la lunghezza del frame, viene restituito il valore di default
0 (modelliamo così il fatto che ogni variabile "nuova" è
implicitamente inizializzata con 0).  La funzione `store`, applicata
a una variabile $x$, a un valore $v$ e a un frame $f$, produce un
nuovo frame che ha la stessa struttura di $f$ ma in cui la variabile
con indice $x$ ha valore $v$. Come per `load`, realizziamo `store`
in modo da estendere opportunamente il frame qualora si scriva per
la prima volta una nuova variabile.

La rappresentazione più naturale del bytecode è come lista di
istruzioni:

``` haskell
type Code = [Instruction]
```

Per quanto riguarda le istruzioni, ci troviamo di fronte a entità
che possono essere di tipologia differente (`PUSH`, `LOAD`,
`STORE`, ecc.) e tali per cui ogni tipologia può avere zero o
più argomenti. Ad esempio, l'istruzione `PUSH` ha come argomento
un valore, sia `LOAD` che `STORE` hanno come argomento il nome
di una variabile, e `RETURN` non ha argomenti. Queste osservazioni
suggeriscono che per rappresentare una singola istruzione della JVMM
è comodo definire un nuovo tipo di dato algebrico con tanti
costruttori quante sono le istruzioni da rappresentare. Ogni
costruttore sarà dotato di tanti argomenti quanti sono gli argomenti
dell'istruzione corrispondente. In codice Haskell abbiamo:

``` haskell
data Instruction
  = PUSH Value
  | LOAD Var
  | STORE Var
  | OP (Value -> Value -> Value)
  | IF (Value -> Value -> Bool) Code
  | RETURN
```

Da notare che i costruttori `OP` e `IF` hanno un argomento di tipo
funzione che rappresenta l'operazione binaria (nel caso di `OP`) o
la relazione (nel caso di `IF`).  In particolare, modelliamo una
relazione binaria come una funzione a due argomenti e codominio
`Bool`.

## Realizzazione dell'esecutore

Modelliamo l'esecutore della JVMM come una funzione `run` che,
applicata a un frammento di codice e a un frame, restituisce il
risultato dell'esecuzione, ovvero il valore in cima alla pila al
momento dell'esecuzione dell'istruzione `RETURN`. Definiamo `run`
come specializzazione di una funzione ausiliaria `aux` che ha come
argomenti, oltre al codice da eseguire e al frame, anche lo stato
corrente dello stack.

``` haskell
run :: Code -> Frame -> Value
run = aux []
  where
    aux :: Stack -> Code -> Frame -> Value
    aux (v : [])     (RETURN : [])  _  = v
    aux vs           (PUSH v : is)  fr = aux (v : vs) is fr
    aux vs           (LOAD x : is)  fr = aux (load x fr : vs) is fr
    aux (v : vs)     (STORE x : is) fr = aux vs is (store x v fr)
    aux (w : v : vs) (OP f : is)    fr = aux (f v w : vs) is fr
    aux (w : v : vs) (IF p is : _)  fr | p v w = aux vs is fr
    aux (_ : _ : vs) (IF _ _ : is)  fr = aux vs is fr
```

La funzione ausiliaria `aux` è definita per casi sulla prima
istruzione da eseguire. Da notare l'uso simultaneo del pattern
matching sui vari argomenti di `aux` in modo da mettere in evidenza
gli eventuali operandi (sullo stack) usati dall'istruzione e la
continuazione del codice dopo l'istruzione stessa.

* Nel caso di `RETURN` l'esecuzione termina restituendo il valore
  `v` trovato in cima allo stack. Per come sono specificati i
  pattern, è necessario che `v` sia l'unico valore sullo stack e che
  `RETURN` sia l'ultima istruzione del codice.
* L'istruzione `PUSH` aggiorna lo stato dello stack inserendo in
  cima l'argomento dell'istruzione stessa. Notare l'applicazione
  ricorsiva di `aux` in cui l'argomento che rappresenta lo stack
  viene opportunamente modificato.
* Le istruzioni `LOAD` e `STORE` leggono e scrivono il frame,
  rispettivamente.
* L'istruzione `OP` applica la funzione `f` specificata come
  argomento ai primi due operandi in cima allo stack, inserendo poi
  il risultato sullo stack. Occorre prestare attenzione al fatto che
  l'operando in cima allo stack (`w`) è di fatto il secondo che è
  stato inserito, mentre l'operando immediatamente sottostante (`v`)
  è il primo. Dunque, `f` viene applicata prima a `v` e poi a
  `w`. Questo dettaglio è fondamentale per quelle operazioni non
  commutative come la sottrazione o la divisione.
* Ci sono due casi possibili per l'istruzione `IF`, a seconda che la
  condizione che determina il salto sia verificata oppure no Anche
  qui occorre mettere in evidenza i due operandi in cima allo stack
  e applicare il predicato `p` nell'ordine giusto.

A titolo di esempio riportiamo il codice di un metodo che calcola il
fattoriale del valore memorizzato nella variabile `n`:

``` haskell
fattoriale :: Code
fattoriale = init
  where
    init = PUSH 1 :
           STORE res :
           loop
    loop = LOAD n :
           PUSH 0 :
           IF (==) fine :
           LOAD n :
           LOAD res :
           OP (*) :
           STORE res :
           LOAD n :
           PUSH 1 :
           OP (-) :
           STORE n :
           loop
    fine = LOAD res :
           RETURN : []
    n    = 0
    res  = 1
```

Il codice segue la struttura classica dell'algoritmo iterativo per
il calcolo del fattoriale. Viene usata una variabile locale `res`
inizializzata a 1 per memorizzare il valore parziale del prodotto $n
\times (n - 1) \times \cdots \times 2 \times 1$. Il ciclo
dell'algoritmo inizia controllando se `n` è diventata 0. In tal
caso, `res` contiene il risultato. Altrimenti, `res` viene
aggiornato moltiplicandolo per il valore corrente di `n`, `n` viene
decrementato di 1 e si ripete il ciclo. Una caratteristica
interessante di questa definizione è che fa uso di **liste
infinite**. In particolare, si associa il nome `loop` al codice
corrispondente al ciclo dell'algoritmo e, laddove occorre effettuare
un "salto" a quel codice, si scrive semplicemente tale nome.

``` haskell
run fattoriale [10]
```

Come esempio ulteriore riportiamo anche il codice di un metodo che
calcola il `k`-esimo numero nella sequenza di Fibonacci:

``` haskell
fibonacci :: Code
fibonacci = init
  where
    init = PUSH 0 :
           STORE m :
           PUSH 1 :
           STORE n :
           loop
    loop = LOAD k :
           PUSH 0 :
           IF (==) fine :
           LOAD n :
           LOAD n :
           LOAD m :
           OP (+) :
           STORE n :
           STORE m :
           LOAD k :
           PUSH 1 :
           OP (-) :
           STORE k :
           loop
    fine = LOAD m :
           RETURN : []
    k    = 0
    m    = 1
    n    = 2
```

``` haskell
run fibonacci [10]
```

## Esercizi

1. Scrivere un frammento di bytecode per la JVMM che calcola il
   massimo comun divisore di due numeri $m$ ed $n$ usando l'algoritmo
   di Euclide.
2. Estendere la JVMM con le istruzioni `DUP`, `SWAP`, `POP` e `NOP`
   la cui semantica è descritta in [questa
   pagina](https://en.wikipedia.org/wiki/Java_bytecode_instruction_listings).
   Scrivere alcuni semplici frammenti di bytecode per verificare la
   correttezza delle estensioni realizzate.
3. Estendere la JVMM con una istruzione `UOP` per rappresentare
   operatori *unari*. Ad esempio, tale istruzione deve rendere
   possibile modellare l'istruzione `ineg` della JVM.  Scrivere un
   semplice frammento di bytecode per verificare la correttezza
   dell'estensione.

Le soluzioni degli esercizi sono incluse nel file
[JVMM.hs](assets/haskell/JVMM.hs) che contiene il codice discusso
in questo caso di studio.

