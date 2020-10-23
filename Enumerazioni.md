---
title: Enumerazioni
---

Una **enumerazione** è un nuovo tipo di dato i cui valori sono
definiti dall'utente. In questa scheda motiviamo l'esigenza di
definire nuovi tipi di dato e illustriamo il meccanismo base per
definire e usare enumerazioni.

## Motivazione all'introduzione di nuovi tipi di dato

Supponiamo di voler realizzare una funzione `morra` che determini il
vincitore di due giocatori che si sfidano alla [morra
cinese](https://it.wikipedia.org/wiki/Morra_cinese). La funzione ha
due argomenti con le **mosse** dei due giocatori e restituisce un
numero tra 0, 1 o 2 a seconda che la partità finisca in parità (le
due liste sono uguali) o che vinca uno dei due giocatori.  Si pone
immediatamente il problema di come **rappresentare** le mosse del
gioco, che nel caso specifico sono di **tre tipi**: **sasso** <i
class="far fa-hand-rock"></i>, **carta** <i class="far
fa-hand-paper"></i> e **forbice** <i class="far
fa-hand-scissors"></i>.

La soluzione più ovvia -- quella di utilizzare i numeri interi 0,
1 e 2 -- ha diversi svantaggi:

1. Il codice è **complesso**. Per esempio, siccome ci sono molti più
   numeri che mosse, occorre considerare ogni numero diverso da 0, 1
   e 2 come una "mossa non valida" e gestire questa eventualità
   nella funzione `morra`.
2. Il codice è **fragile** poiché c'è il rischio di confondere
   numeri che rappresentano "numeri" con numeri che rappresentano
   "mosse". In particolare, diventa possibile "sommare mosse" e
   usare "somme di numeri" nelle liste passate alla funzione `morra`
   anche se queste operazioni difficilmente hanno senso logico.
3. Il programma è **difficile da leggere** in quanto per distinguere
   un "numero vero" da un "numero mossa" occorre considerare del
   contesto in cui il numero compare.

## Definizione di un nuovo tipo di dato

Il programmatore può definire un nuovo tipo di dato per
rappresentare esplicitamente le mosse nel gioco della morra cinese.

```haskell
data Mossa = Sasso | Carta | Forbici
```

La definizione è introdotta dalla parola chiave `data` seguita dal
nome del tipo, dal simbolo `=` e dall'elenco dei **costruttori** del
tipo di dato. Il nome del tipo definito (nell'esempio, `Mossa`) deve
iniziare con una lettera maiuscola e può essere usato ovunque possa
comparire un tipo. I costruttori devono iniziare con una lettera
maiuscola e possono essere usati per costruire *valori* di tipo
`Mossa`. Nel caso specifico, `Sasso`, `Carta` e `Forbici` sono
**tutti e soli** i valori di tipo `Mossa`.

``` haskell
:type Sasso
:type Carta
:type Forbici
```

Il nuovo tipo di dato si integra automaticamente con quelli già
definiti. Per esempio, è possibile scrivere tuple e liste al cui
interno si trovano valori di tipo `Mossa`.

``` haskell
:type [Sasso, Carta, Forbici]
length [Sasso, Carta, Forbici]
```

Il tipo `Mossa` è "nuovo" nel senso che è incompatibile con tutti
gli altri tipi già esistenti. In particolare, non è possibile
confondere numeri e mosse:

``` haskell
[Sasso, 0]
```

## Visualizzazione

Senza alcuna dichiarazione aggiuntiva, Haskell non sa cosa voglia
dire "visualizzare" il valore di un nuovo tipo di dato. Se si tenta
di farlo, Haskell segnala un errore:

``` haskell
Sasso
```

Come si evince dal messaggio di errore che si ottiene in questo
caso, Haskell si lamenta del fatto che il tipo `Mossa` non è istanza
della classe `Show`, ovvero la classe dei tipi di dato
"visualizzabili".

È possibile chiedere ad Haskell di introdurre una visualizzazione di
*default* per un nuovo tipo di dato aggiungendo una apposita
clausola alla definizione del tipo stesso:

``` haskell
data Mossa = Sasso | Carta | Forbici
  deriving Show
```

Usando la clausola `deriving Show`, Haskell fa in modo che la
visualizzazione di un costruttore sia il nome del costruttore
stesso:

``` haskell
Sasso
[Sasso, Carta, Forbici]
```

## Pattern matching

Una volta definito un nuovo tipo di dato, è possibile usare il
*pattern matching* per analizzarne i valori. Per esempio, la
seguente funzione `vince` accetta le mosse di due giocatori e
stabilisce chi vince o se le due mosse sono uguali:

``` haskell
vince :: Mossa -> Mossa -> Int
vince Sasso   Carta   = 2 -- vince il giocatore 2
vince Sasso   Forbici = 1 -- vince il giocatore 1
vince Carta   Sasso   = 1
vince Carta   Forbici = 2
vince Forbici Sasso   = 2
vince Forbici Carta   = 1
vince _       _       = 0 -- in tutti gli altri casi, parità
```

A questo punto è possibile completare la definizione di `morra`
analizzando la struttura delle due liste di mosse dei due giocatori:

``` haskell
gioco :: [Mossa] -> [Mossa] -> Int
gioco [] [] = 0
gioco _  [] = 1
gioco [] _  = 2
gioco (x : xs) (y : ys) | vincitore /= 0 = vincitore
                        | otherwise      = gioco xs ys
  where
    vincitore = vince x y
```

La prima equazione considera il caso in cui entrambe le liste sono
vuote, che significa che i giocatori hanno smesso di giocare allo
stesso momento, e si ha parità. Le due equazioni successive
considerano il caso in cui uno dei due giocatori fa una mossa e
l'altro no, determinando la vittoria del giocatore attivo. L'ultima
equazione confronta la prima mossa fatta dai due giocatori. Se
questa mossa determina la vittoria di uno dei giocatori, il gioco
termina. In caso contrario, la funzione analizza le mosse
successive. Si noti la dichiarazione locale di `vincitore`, comoda
in questo caso per evitare di calcolare due volte il valore di
`vince x y`.

``` haskell
morra [Sasso,Carta,Carta] [Sasso,Carta]
morra [Sasso,Carta,Carta] [Sasso,Carta,Forbici]
morra [Sasso,Carta,Sasso] [Sasso,Carta,Forbici]
```

## Il tipo unitario

L'enumerazione più semplice che può essere definita è quella con un
costruttore solo e prende il nome di "tipo unitario". Haskell usa la
sintassi `()` per indicare sia il tipo unitario che il suo unico
costruttore. In altre parole, il tipo unitario sarebbe definito così:

``` haskell
data () = ()
```

``` haskell
:type ()
```

Il valore unitario è privo di informazione. Infatti, sapendo che un
valore **è di tipo** `()` si sa anche che il valore **è** `()`.  In
generale, la valutazione di un'espressione è di tipo `()` o non
termina o produce `()`.

## Esercizi

1. Il tipo `Bool` non è altro che un'enumerazione! Definirla
   esplicitamente come tale.
   ^
   ``` haskell
   data Bool = False | True
   ```
   {:.solution}
2. Definire un tipo `PuntoCardinale` con i costruttori `Nord`,
   `Sud`, `Ovest` ed `Est`. Definire le funzioni `sinistra ::
   PuntoCardinale -> PuntoCardinale`, `destra :: PuntoCardinale ->
   PuntoCardinale` e `indietro :: PuntoCardinale -> PuntoCardinale`
   in modo tale che solo una di queste funzioni usi il *pattern matching*.
   ^
   ``` haskell
   data PuntoCardinale = Nord | Sud | Ovest | Est
     deriving Show

   sinistra :: PuntoCardinale -> PuntoCardinale
   sinistra Nord  = Est
   sinistra Est   = Sud
   sinistra Sud   = Ovest
   sinistra Ovest = Nord

   destra :: PuntoCardinale -> PuntoCardinale
   destra = indietro . sinistra

   indietro :: PuntoCardinale -> PuntoCardinale
   indietro = sinistra . sinistra
   ```
   {:.solution}
3. Definire un tipo `Giorno` i cui costruttori sono i giorni della
   settimana `Lun`, `Mar`, `Mer`, `Gio`, `Ven`, `Sab`, `Dom` poi
   definire le seguenti funzioni:
   * `domani :: Giorno -> Giorno`.
   * `fra :: Int -> Giorno -> Giorno` che, applicata a un numero non
	 negativo $n$ e a un giorno $g$, calcoli il giorno della
	 settimana corrispondente a $n$ giorni dopo $g$.
   * Usando la funzione di libreria `replicate`, ridefinire la
	 funzione `fra :: Int -> Giorno -> Giorno` dell'esercizio
	 precedente senza fare uso esplicito della ricorsione.
   ^
   ```haskell
   data Giorno = Lun | Mar | Mer | Gio | Ven | Sab | Dom
     deriving Show

   domani :: Giorno -> Giorno
   domani Lun = Mar
   domani Mar = Mer
   domani Mer = Gio
   domani Gio = Ven
   domani Ven = Sab
   domani Sab = Dom
   domani Dom = Lun

   fra :: Int -> Giorno -> Giorno
   fra 0 = id
   fra n = domani . fra (n - 1)

   fra_replicate :: Int -> Giorno -> Giorno
   fra_replicate n = foldr (.) id (replicate n domani)
   ```
   {:.solution}
4. La classe `Ord` ha anche una funzione `compare` che restituisce
   un valore di tipo `Ordering`. Esaminando il tipo di `compare` e
   la definizione di `Ordering` (con `:info Ordering`) descrivere
   comportamento e utilità di `compare`.
   ^
   > La funzione `compare` restituisce il risultato del confronto di
   > due valori $x$ ed $y$ il cui tipo è istanza di `Ord`, dunque
   > per i quali esiste una relazione d'ordine totale: se il
   > risultato è `LT` allora $x$ è "più piccolo" di $y$; se il
   > risultato è `GT` allora $x$ è "più grande" di $y$; se il
   > risultato è `EQ` allora $x$ ed $y$ sono uguali. È conveniente
   > usare `compare` laddove il confronto di due valori può essere
   > "costoso" (ad esempio, se $x$ ed $y$ sono liste) ed è
   > preferibile confrontarli una volta sola (con `compare`) invece
   > che più volte (prima con `<`, poi con `>` e infine con `==`)
   > per capire in che relazione sono.
   {:.solution}
5. In un linguaggio di programmazione *puro* come Haskell, in cui le
   funzioni non possono avere effetti collaterali, il tipo `()` è
   apparentemente inutile. Perché? Si pensi ad esempio a funzioni di
   tipo `() -> T` o `T -> ()`.
   ^
   > Una funzione di tipo `() -> T` è necessariamente una *funzione
   > costante* perché "sa" che sarà applicata a `()`, l'unico valore
   > di tipo `()`. Dunque anziché scriverla come funzione costante è
   > sufficiente definire la costante di tipo `T`.  Una funzione di
   > tipo `T -> ()` applicata a un argomento di tipo `T` non termina
   > o produce `()`, l'unico valore di tipo `()`. Dunque tanto vale
   > scrivere direttamente `()` invece di applicare la funzione.
   {:.solution}
