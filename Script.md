---
title: Script
---

{% include links.md %}

## Definizioni e dichiarazioni

L’uso dell’interprete `ghci` come calcolatrice va bene per la
valutazione di semplici espressioni. Quando si scrive un programma
complesso lo si inserisce in uno **script**, ovvero un file di testo
con estensione `.hs` che contiene un insieme di **definizioni**.

Una **definizione** è un’associazione tra un **nome** _N_ ed una
**espressione** _E_. All’interno di uno script, è possibile fare
riferimento al valore dell’espressione _E_ scrivendone il nome
associato _N_.

Usando un editor di testo, definiamo lo script `PrimoScript.hs` con
il seguente contenuto:

```haskell
anno_terra :: Float
anno_terra = 2 * pi * 150e6

v_terra :: Float
v_terra = anno_terra / (365 * 24)
```

Ogni **definizione** è preceduta da una **dichiarazione** della
forma `N :: T` dove `N` è il nome della definizione e `T` il suo
tipo. Qui sopra abbiamo 2 definizioni, una per il nome `anno_terra`
e una per il nome `v_terra`, entrambe di tipo [`Float`], il tipo dei
numeri in virgola mobile a precisione singola.  Ogni dichiarazione è
seguita dalla definizione vera e propria della forma `N = E`, in cui
si stabilisce che `N` è il nome per il **valore** dell’espressione
`E`.  Il valore di `anno_terra` è il valore dell’espressione `2 *
pi * 150e6` che calcola, in maniera approssimativa, la lunghezza in
chilometri dell’orbita terrestre, approssimandola a un cerchio di
raggio `150e6` chilometri (si ricordi che la notazione `150e6`
significa 150 moltiplicato per 10 elevato alla 6, ovvero 150 milioni
di chilometri).  Il nome [`pi`] corrisponde al valore (approssimato)
di pi greco.  Il valore di `v_terra` è la velocità approssimativa
della Terra nel suo moto attorno al Sole, qui determinata dividendo
la lunghezza dell’orbita per il tempo di percorrenza in ore.

## Caricamento di script

Per poter usare le definizioni contenute all’interno di uno script
occorre prima **caricarlo** all’interno di `ghci`. Supponendo di
aver aperto un terminale e di trovarsi nella stessa cartella in cui
è stato salvato lo script che si vuole caricare, questo si può
ottenere in vari modi.

Si può lanciare `ghci` indicando direttamente dalla linea di comando
il nome dello script da caricare:

```bash
ghci PrimoScript.hs
```

In alternativa, si può lanciare `ghci` senza argomenti

```bash
ghci
```

e poi caricare lo script dall’interno di `ghci` stesso:

```bash
Prelude> :load PrimoScript.hs
```

Una volta che lo script è stato caricato, è possibile usare i nomi
definiti al suo interno semplicemente scrivendone il
nome. Intuitivamente, il nome di una definizione viene sostituito
dal suo valore:

```haskell
anno_terra
v_terra
```
{:.run}

## Modifica di script

Quando si sviluppano programmi complessi è frequente che lo script
su cui si lavora contenga degli errori, o comunque che le
definizioni inserite non corrispondano sempre con quelle attese. In
generale, la programmazione in Haskell prevede l’uso di due
programmi, in due finestre diverse:
* l’editor di testo con cui si modifica lo script
* il terminale all’interno del quale si esegue `ghci`

Dopo ogni modifica, lo script deve essere **ricaricato** in`ghci`
affinché le modifiche abbiano effetto. Questo si può ottenere usando
i comandi già illustrati in precedenza, oppure semplicemente usando
il comando `:reload` o `:r` al prompt di `ghci`.

## Esercizi

1. Aggiungere a `PrimoScript.hs` le definizioni per i nomi
   `anno_mercurio` e `v_mercurio` tenendo conto che Mercurio dista
   dal Sole circa 58 milioni di chilometri e impiega circa 88 giorni
   terrestri per compiere un’orbita. Usare il comando `:r` per
   ricaricare lo script dopo averlo modificato.
   ```haskell
   anno_mercurio :: Float
   anno_mercurio = 2 * pi * 58e6

   v_mercurio :: Float
   v_mercurio = anno_mercurio / (88 * 24)
   ```
   {:.solution}
2. La sequenza di Fibonacci inizia con i numeri 0 e 1 e ogni numero
   successivo è ottenuto sommando i due immediatamente
   precedenti. Dunque, i primi otto numeri nella sequenza di
   Fibonacci sono 0, 1, 1, 2, 3, 5, 8, 13, 21. Il seguente script
   Haskell definisce i nomi `f0`, `f1`e `f2` per i primi tre numeri
   nella sequenza di Fibonacci.
   ```haskell
   f0 :: Int
   f0 = 0

   f1 :: Int
   f1 = 1

   f2 :: Int
   f2 = f0 + f1
   ```
   Si noti l’uso del tipo `Int` per la dichiarazione di nomi il cui
   tipo è un numero intero. Aggiungere allo script le definizioni
   per i nomi da `f3` a `f7`. Usare `ghci` per verificare che tali
   nomi siano effettivamente associati al corrispondente numero
   nella sequenza di Fibonacci.
   ```haskell
   f0 :: Int
   f0 = 0

   f1 :: Int
   f1 = 1

   f2 :: Int
   f2 = f0 + f1

   f3 :: Int
   f3 = f1 + f2

   f4 :: Int
   f4 = f2 + f3

   f5 :: Int
   f5 = f3 + f4

   f6 :: Int
   f6 = f4 + f5

   f7 :: Int
   f7 = f5 + f6
   ```
   {:.solution}
