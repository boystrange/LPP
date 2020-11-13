---
title: Esercizi di riepilogo
---

{% include links.md %}

## Insiemi come liste

Si supponga di utilizzare **liste ordinate** in modo crescente e
**senza elementi ripetuti** per rappresentare insiemi finiti.  Senza
fare uso di funzioni della libreria standard di Haskell, definire le
funzioni

1. `union :: Ord a => [a] -> [a] -> [a]`
2. `intersection :: Ord a => [a] -> [a] -> [a]`
3. `difference :: Ord a => [a] -> [a] -> [a]`

per calcolare rispettivamente l'unione, l'intersezione e la
differenza di due insiemi. Alcuni esempi:

* `union [1,2,3] [3,4,5] ~~> [1,2,3,4,5]`
* `intersection [1,2,3,4,5] [3,5,7] ~~> [3,5]`
* `difference [1,2,3,4,5] [3,5,7] ~~> [1,2,4]`
* `difference [3,5,7] [1,2,3,4,5] ~~> [7]`

``` haskell
union :: Ord a => [a] -> [a] -> [a]
union [] ys = ys
union xs [] = xs
union (x : xs) (y : ys) | x == y    = x : union xs ys
                        | x < y     = x : union xs (y : ys)
                        | otherwise = y : union (x : xs) ys

intersection :: Ord a => [a] -> [a] -> [a]
intersection [] _  = []
intersection _  [] = []
intersection (x : xs) (y : ys) | x == y    = x : intersection xs ys
                               | x < y     = intersection xs (y : ys)
                               | otherwise = intersection (x : xs) ys

difference :: Ord a => [a] -> [a] -> [a]
difference [] _  = []
difference xs [] = xs
difference (x : xs) (y : ys) | x == y    = difference xs ys
                             | x < y     = x : difference xs (y : ys)
                             | otherwise = difference (x : xs) ys
```
{:.solution}

## Monade [`IO`]

1. Scrivere un programma `wc` che realizzi le funzionalità di base
   dell'[omonimo programma
   Unix](https://it.wikipedia.org/wiki/Wc_(Unix)). Il programma deve
   visualizzare il numero di righe, di parole e di caratteri letti
   dal terminale. Per "parola" si intende una qualsiasi sequenza non
   vuota di caratteri diversi dallo spazio.

   Suggerimento: può essere utile (ma non è necessario) usare
   [`isEOF`](https://hoogle.haskell.org/?hoogle=isEOF).

   ``` haskell
   -- SOLUZIONE 1: uso di getContents per accedere all'intero stream di
   -- caratteri proveniente da stdin

   main :: IO ()
   main = do s <- getContents
             putStrLn $
               " " ++ (show $ length $ lines s) ++
               " " ++ (show $ length $ words s) ++
               " " ++ (show $ length s)

   -- SOLUZIONE 2: definizione di un'azione IO per la lettura dello
   -- stream di caratteri da stdin

   import System.IO (isEOF)

   getInput :: IO String
   getInput = do eof <- isEOF
                 if eof
                   then return []
                   else do c <- getChar
                           cs <- getInput
                           return (c : cs)

   main :: IO ()
   main =
     do s <- getInput
        putStrLn $
          " " ++ (show $ length $ lines s) ++
          " " ++ (show $ length $ words s) ++
          " " ++ (show $ length s)
   ```
   {:.solution}
2. Scrivere un programma `palindrome` che elimini tutte le
   righe non palindrome lette dal terminale, ignorando ogni carattere
   che non sia una lettera dell'alfabeto (inclusi spazi) e non
   facendo distinzione tra lettere minuscole e maiuscole. Ad esempio,
   se vengono lette le righe

   ```
   Aro un autodromo o mordo tua nuora
   Eva, Can I Stab Bats?
   Eva, Can I Stab Bats In A Cave?
   ```

   l'output dovrà contenere le righe

   ```
   Aro un autodromo o mordo tua nuora
   Eva, Can I Stab Bats In A Cave?
   ```

   Suggerimento: può essere utile usare la funzione di libreria
   [`interact`](https://hoogle.haskell.org/?hoogle=interact&scope=set%3Aincluded-with-ghc).

   ``` haskell
   -- Esempio d'uso della funzione interact

   import Data.Char (isAlpha, toLower)

   palindroma :: String -> Bool
   palindroma s = s == reverse s

   process :: String -> String
   process s | palindroma t = s
			 | otherwise    = ""
	 where
	   t = map toLower (filter isAlpha s)

   main :: IO ()
   main = interact (concat . map process . lines)
   ```
   {:.solution}

## Rappresentazione di $\lambda$-espressioni <i class="fas fa-skull"></i>

Data la seguente rappresentazione di $\lambda$-espressioni

``` haskell
type Name = String
data Term = Var Name | Lam Name Term | App Term Term
```

e usando solo funzioni del modulo `Prelude` implementare le
funzioni:

1. `fv :: Term -> [Name]` per calcolare le variabili libere di un
   $\lambda$-termine. Assicurarsi che la lista restituita non
   contenga elementi duplicati. A tal fine può essere utile
   riutilizzare la funzione `union` definita in precedenza.
2. `normal :: Term -> Bool` per determinare se un termine è in forma
   normale, ovvero se non contiene né $\beta$-redex né $\eta$-redex.

``` haskell
occurs :: Name -> Term -> Bool
occurs x t = x `elem` fv t

-- calcola le variabili libere di una λ-espressione
fv :: Term -> [Name]
fv (Var x)     = [x]
fv (Lam x t)   = filter (/= x) (fv t)
fv (App t₁ t₂) = fv t₁ `union` fv t₂

-- controlla l'assenza di β-redex ed η-redex in una λ-espressione
normal :: Term -> Bool
normal (Var _) = True
normal (Lam x (App t (Var y))) | x == y && not (occurs x t) = False
normal (Lam _ t) = normal t
normal (App (Lam _ _) _) = False
normal (App t₁ t₂) = normal t₁ && normal t₂
```
{:.solution}

## Alberi binari di ricerca <i class="fas fa-skull"></i> <i class="fas fa-skull"></i>

Usando il tipo di dato

``` haskell
data Tree a = Leaf | Branch a (Tree a) (Tree a)
```

per rappresentare alberi binari, definire una funzione
`binarySearchTree :: Ord a => Tree a -> Bool` che determini se un
albero è un albero binario di ricerca facendo **una sola visita**
dell'albero. Suggerimento: definire un tipo di dato per
rappresentare la risposta alla domanda "sei un albero binario di
ricerca e, se sì, in quale intervallo sono compresi i tuoi
elementi?"

``` haskell
-- si definisce un tipo algebrico Answer per rappresentare la risposta
-- alla domanda "sei un albero binario di ricerca?". In caso di
-- risposta affermativa, è utile sapere se l'albero è vuoto (nel qual
-- caso la risposta è Trivial) e in quale intervallo [x, y] sono
-- compresi tutti i suoi elementi se l'albero è un albero binario di
-- ricerca non vuoto (nel qual caso la risposta è Yes x y)

data Answer a = No | Trivial | Yes a a

binarySearchTree :: Ord a => Tree a -> Bool
binarySearchTree t = case aux t of
                       No -> False
                       _  -> True
  where
    aux :: Ord a => Tree a -> Answer a
    aux Leaf = Trivial
    aux (Branch x t₁ t₂) =
      case (aux t₁, aux t₂) of
        (Trivial, Trivial) -> Yes x x
        (Trivial, Yes c d) | x < c -> Yes x d
        (Yes a b, Trivial) | b < x -> Yes a x
        (Yes a b, Yes c d) | b < x && x < c -> Yes a d
        _ -> No
```
{:.solution}
