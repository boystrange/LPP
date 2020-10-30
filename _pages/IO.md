---
title: La monade di Input/Output
---

{% include links.md %}

In un linguaggio di programmazione lazy come Haskell, in cui
l'ordine di valutazione delle espressioni è difficile da prevedere,
non è possibile equipaggiare il linguaggio con funzioni "impure",
cioè che hanno effetti collaterali. Per esempio, supponiamo che
`print :: Show a => a -> ()` sia una "funzione" che, applicata a un
argomento di tipo `a` istanza di [`Show`], stampi sul terminale la
rappresentazione testuale di `a` (ottenuta con [`show`]) e restituisca
[`()`]. Funzioni analoghe a questa sono disponibili in molti linguaggi
di programmazione. Si pensi a `printf` nel C o al metodo `println`
in Java. Cosa verrebbe stampato sul terminale come effetto della
valutazione delle seguente espressioni, e in quale ordine?

``` haskell
length [print 2, print True, print "ciao"]
```

La risposta corretta è che non verrebbe stampato nulla. Il motivo è
che la funzione [`length`] non usa gli elementi di una lista per
calcolarne la lunghezza, e dunque tutte le applicazioni di [`print`]
rimarrebbero sospese in virtù della valutazione lazy.

Nella libreria standard di Haskell troviamo invece la seguente
*funzione* che, applicata a un valore di tipo `a` istanza di [`Show`],
crea un'**azione** che, **se eseguita** (da un qualche esecutore),
stampa il valore sul terminale e produce [`()`].

``` haskell
:type print
```

Il costruttore di tipo [`IO`] è un esempio di **monade**, una
struttura che serve a descrivere computazioni/azioni che possono
avere effetti collaterali se eseguite.

## Elementi di una monade generica

In sintesi, una monade consiste dei seguenti elementi:

* Un costruttore di tipo `m` istanza della classe [`Monad`].
* Una funzione `return :: Monad m => a -> m a` che, applicata a un
  valore $v$ di tipo `a`, crea un'azione `m a` della monade che, *se
  eseguita*, non ha alcun effetto e produce $v$ come risultato.
* Un operatore di **composizione** `(>>=) :: Monad m => m a -> (a ->
  m b) -> m b` storicamente chiamato **bind** che, applicato a
  un'azione $p$ di tipo `m a` e a una funzione $f$ di tipo `a -> m
  b`, crea un'azione composta che, *se eseguita*, causa
  l'esecuzione di $p$ e poi dell'azione ottenuta applicando $f$ al
  risultato dell'esecuzione di $p$.
* Altre funzioni/azioni specifiche che dipendono dalla monade
  particolare.

Inoltre, le funzioni [`return`] e [`>>=`] devono soddisfare le seguenti
condizioni, dove usiamo il simbolo `<~>` per indicare
un'equivalenza *semantica*:

1. [`return`] deve essere **identità sinistra** di [`>>=`], ovvero
   `return v >>= f <~> f v`.
2. [`return`] deve essere **identità destra** di [`>>=`], ovvero `m >>=
   return <~> m`.
3. [`>>=`] deve essere **associativo** nel senso che `(m >>= f) >>= g
   <~> m >>= (\x.f x >>= g)`.

Le condizioni 1 e 2 catturano l'intuizione che l'azione `return v`,
se eseguita, non ha alcun effetto e produce come risultato `v`. La
condizione 3 cattura l'intuizione che eseguire `A` e `B` e poi `C`
ha lo stesso effetto di eseguire `A` e poi `B` e `C`. Il modo in cui
le azioni sono associate non modifica l'effetto della loro
composizione.

Per ogni monade è inoltre disponibile l'operatore [`>>`],
tradizionalmente pronunciato **and then**, che consiste in una
variante di [`>>=`] in cui il valore prodotto dalla prima azione è
ignorato. In altri, termini, [`>>`] è definito così:

``` haskell
(>>) :: Monad m => m a -> m b -> m b
(>>) m₁ m₂ = m₁ >>= const m₂
```

L'operatore [`>>`] rappresenta a tutti gli effetti la **composizione
sequenziale**. L'associatività di [`>>=`] descritta sopra si traduce
nell'equivalenza `(A >> B) >> C <~> A >> (B >> C)`.

## La monade [`IO`]

Il tipo `IO a` descrive azioni che, se eseguite, possono causare
operazioni di input/output (per esempio la stampa di caratteri sul
terminale) e poi producono come risultato un valore di tipo `a`.
Un'immagine mentale utile a cogliere il significato del tipo `IO a`
è la distinzione tra l'*azione* "correre" e l'*intenzione* di
"correre".

![](assets/images/monad.png){: style="display: block; margin-left: auto; margin-right: auto" width="33%"}

Un valore di tipo `IO a` rappresenta l'intenzione di eseguire una
particolare azione ma non implica l'esecuzione della stessa. È
necessario fornire il valore a un esecutore affinché l'azione venga
davvero eseguita. Nel caso della monade [`IO`], l'esecutore delle
azioni è il **sistema operativo**. Per indicare al sistema operativo
quale azione eseguire è necessario darle nome `main`.

## Output

Siccome [`IO`] è istanza di [`Monad`], è possibile usare le funzioni
[`return`] e [`>>=`] per costruire e comporre azioni di input/output.
In aggiunta, è disponibile la seguente funzione che, applicata a un
carattere, crea un'azione che, se eseguita, stampa quel carattere
sul terminale e produce [`()`] come risultato.

``` haskell
:type putChar
```

Usando opportunamente [`putChar`] è possibile definire funzioni che
creano azioni più complesse. Per esempio, la seguente funzione crea
l'azione che, se eseguita, stampa un'intera stringa e un ritorno a
capo sul terminale componendo sequenzialmente le azioni che, se
eseguite, causano la stampa dei singoli caratteri che compongono la
stringa.

``` haskell
putStrLn :: String -> IO ()
putStrLn []       = return '\n'
putStrLn (c : cs) = putChar c >> putStrLn cs
```
{: #putStrLn}

Usando [`putStrLn`] possiamo (finalmente!) scrivere il più piccolo
programma Haskell che stampa un saluto sullo schermo:

``` haskell
main :: IO ()
main = putStrLn "Hello, world!"
```

Nota: [`putStrLn`] e la variante [`putStr`] che non causa la stampa del
ritorno a capo sono già definite nella libreria standard di Haskell.

## Input

Le azioni [`getChar`] e [`getLine`] possono essere usate per leggere dal
terminale un singolo carattere e un'intera riga di testo.

``` haskell
:type getChar
:type getLine
```

In particolare, [`getChar`] è un'azione che, se eseguita, legge un
carattere dal terminale e produce quel carattere come risultato.

A titolo di esempio, scriviamo un programma che ripete ogni riga di
testo letta dal terminale convertita in maiuscolo. Il programma
termina la sua esecuzione nel momento in cui viene letta la riga
vuota.

``` haskell
import Data.Char (toUpper) -- converte caratteri minuscoli in maiuscoli

parrot :: IO ()
parrot = getLine >>= \s ->
         if null s then return ()
         else putStrLn (map toUpper s) >> parrot

main :: IO ()
main = parrot
```
{:#parrot}

Si noti l'uso di [`>>=`] per comporre l'azione [`getLine`], che produce
come risultato la riga di testo letta dal terminale, con la funzione
che elabora tale riga.

## Conclusione

* Le funzioni Haskell sono pure. Quelle che hanno come codominio `IO
  a` si limitano a **creare** azioni di input/output senza
  eseguirle.
* L'ordine di esecuzione delle azioni di input/output è specificato
  esplicitamente dal programmatore per mezzo degli operatori [`>>=`] e
  [`>>`].
* Il compito di **eseguire** le operazioni di input/output spetta al
  sistema operativo.

## Esercizi

1. Definire [`putStrLn`] usando solo [`return`] e [`>>`], ma senza
   ricorsione.
   ^
   ``` haskell
   putStrLn :: String -> IO ()
   putStrLn = foldr ((>>) . putChar) (return '\n')
   ```
   {:.solution}
2. Senza fare uso esplicito della ricorsione, definire una funzione
   `putLines :: [String] -> IO ()` che, applicata a una lista di
   stringhe, crei l'azione di input/output che, se eseguita, stampa
   sul terminale tutte le stringhe della lista, ognuna in una riga
   per conto suo.
   ^
   ``` haskell
   putLines :: [String] -> IO ()
   putLines = foldr ((>>) . putStrLn) (return ())
   ```
   {:.solution}
3. Definire un'azione `getLines :: IO [String]`{:#getLines} che legga da
   terminale una sequenza di righe terminata dalla riga vuota e
   produca come risultato la lista delle righe lette. La riga vuota
   non deve far parte del risultato.
   ^
   ``` haskell
   getLines :: IO [String]
   getLines = getLine >>= \l ->
              if null l then return []
              else getLines >>= \ls -> return (l : ls)
   ```
   {:.solution}
4. Definire un'azione `getInt :: IO Int` che legga una riga di
   testo, che si suppone contenga un numero intero, e produca il
   valore corrispondente di tipo [`Int`]. Suggerimento: usare [`read`].
   ^
   ``` haskell
   getInt :: IO Int
   getInt = getLine >>= return . read
   ```
   {:.solution}
5. Definire un'azione `somma :: IO ()`} che legga un numero intero
   $n$ seguito da ulteriori $n$ numeri e ne stampi la somma.
   ^
   ``` haskell
   somma :: IO ()
   somma = getInt >>= aux 0
     where
       aux res 0 = putStrLn (show res)
       aux res n = getInt >>= \k -> aux (res + k) (n - 1)
   ```
   {:.solution}
