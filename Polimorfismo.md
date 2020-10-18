---
title: Polimorfismo
---

In questa scheda esaminiamo più in dettaglio il **polimorfismo**,
ovvero la proprietà di alcune funzioni di essere applicabili ad
argomenti di tipo diverso.

## Funzioni polimorfe

Ci sono funzioni che non dipendono da nessuna proprietà particolare
del loro argomento. L'esempio più semplice è quello della funzione
**identità**, che si limita a restituire il proprio argomento
invariato:

```haskell
id x = x
```

In questa definizione della funzione identità abbiamo volutamente
omesso la dichiarazione che ne stabilisce il tipo. In effetti,
è concepibile dare a `id` una moltitudine di tipi diversi:

```haskell
id :: Int -> Int
id :: Bool -> Bool
id :: Float -> Float
...
```

In questo senso `id` è una funzione polimorfa, e questa proprietà la
si può rendere palese dandole il **tipo più generale** facendo uso
di **variabili di tipo**:

```haskell
id :: a -> a
id x = x
```

La dichiarazione indica che `id` è una funzione che può essere
applicata ad argomenti di un qualunque tipo `a` (nome scelto dal
programmatore), e che restituisce un valore dello stesso tipo
`a`. Notiamo in particolare che tutti i tipi elencati in precedenza
(`Int -> Int`, `Bool -> Bool`, `Float -> Float`, ecc.) sono
**istanze** del tipo `a -> a` ottenute sostituendo la variabile di
tipo `a` con un tipo più specifico (`Int`, `Bool`, `Float`,
rispettivamente).

Il polimorfismo di `id` è evidente applicando la funzione ad
argomenti di tipo diverso:

```haskell
id 2
id True
id 2.5
id id
```

Nell'ultimo esempio, notiamo che il polimorfismo permette
addirittura di applicare `id` a se stessa. Evidentemente le due
occorrenze di `id` sono trattate in modo distinto: se l'occorrenza
di `id` più a destra ha tipo `a -> a`, l'occorrenza più a sinistra
può avere tipo `(a -> a) -> (a -> a)`, in modo che l'applicazione
sia ben tipata.

## Polimorfismo e vincoli di tipo

Nella sezione precedente abbiamo visto che è possibile usare le
variabili di tipo per esprimere dei **vincoli** tra dominio e
codominio di una funzione. In particolare, la funzione `id` è
vincolata ad avere dominio e codominio uguali. In generale, è
possibile imporre dei vincoli sul tipo di argomenti diversi di una
funzione usando la **stessa variabile di tipo** più volte. Ad
esempio, il tipo più generale della funzione di concatenazione tra
liste

``` haskell
(++) :: [a] -> [a] -> [a]
(++) []       ys = ys
(++) (x : xs) ys = x : (++) xs ys
```

specifica che le due liste da concatenare possono avere elementi di
tipo arbitrario, purché il tipo sia lo stesso nelle due liste.

Analogamente, l'operatore di composizione funzionale `.`, definito
come

``` haskell
(.) :: (b -> c) -> (a -> b) -> a -> c
(.) f g x = f (g x)
```

indica che una composizione `f . g` è ben tipata purché il codominio
di `g` coincida con il dominio di `f`. Il tipo di `.` indica anche
che `f . g` è una funzione che ha lo stesso dominio di `g` e lo
stesso codominio di `f`.

## Esercizi

1. Determinare il tipo più generale delle seguenti funzioni della
   libreria standard.
   ``` haskell
   fst (x, _)       = x
   snd (_, y)       = y
   const x _        = x
   curry f x y      = f (x, y)
   uncurry f (x, y) = f x y
   ```

   ```haskell
   fst     :: (a, b) -> a
   snd     :: (a, b) -> b
   const   :: a -> b -> a
   curry   :: ((a, b) -> c) -> a -> b -> c
   uncurry :: (a -> b -> c) -> (a, b) -> c
   ```
   {:.solution}
2. La funzione seguente è apparentemente "magica", nel senso che è
   in grado di produrre un risultato di *qualsiasi tipo*. Come si
   spiega?
   ``` haskell
   magia :: Int -> a
   magia n = magia (n - 1)
   ```

   > La funzione `magia` non termina mai.
   {:.solution}
3. Sapendo che le funzioni Haskell sono "pure" (non hanno effetti
   collaterali), è possibile dedurre molte informazioni e a volte
   indovinare esattamente il comportamento di una funzione
   guardandone solo il tipo. Speculare sul comportamento delle
   funzioni che hanno i tipi seguenti tenendo presente che, a parità
   di tipo, sono possibili comportamenti diversi. Consultare la
   documentazione delle funzioni nelle risposte usando il [motore di
   ricerca Hoogle](https://hoogle.haskell.org), che consente di
   ricercare funzioni nella libreria standard di Haskell anche per
   mezzo del loro tipo.

   1. `[a] -> Int`
   2. `[a] -> Bool`
   3. `[a] -> a`
   4. `[a] -> [a]`
   5. `[[a]] -> [a]`
   6. `[a] -> Int -> a`
   7. `Int -> [a] -> [a]`
   8. `[a] -> [b] -> [(a, b)]`
   9. `[(a, b)] -> ([a], [b])`
   ^
   10. `length xs` restituisce la lunghezza di `xs`
   11. `null xs` determina se `xs` è vuota
   12. `head xs` restituisce il primo elemento di `xs`
   13. `tail xs` restituisce la coda di `xs` mentre `reverse xs` inverte
	  l'ordine degli elementi di `xs`
   14. `concat xs` concatena tutte le liste in `xs`
   15. `xs !! n` restituisce l'elemento di `xs` in posizione `n`
   16. `take n xs` restituisce i primi `n` elementi di `xs` mentre
	  `drop n xs` rimuove i primi `n` elementi di `xs`
   17. `zip xs ys` crea una lista di coppie di elementi
	  corrispondenti in `xs` e `ys`
   18. `unzip xs` operazione inversa di `zip`
   {:.solution}
