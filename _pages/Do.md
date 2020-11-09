---
title: Notazione do
---

{% include links.md %}

Il linguaggio Haskell fornisce una sintassi semplificata alternativa
per la composizione delle azioni di una monade che nasconde l'uso
esplicito degli operatori [`>>=`] e [`>>`] e consente la scrittura di
codice in uno stile che si avvicina a quello "imperativo".

## Composizione sequenziale

Se `A`, `B` e `C` sono azioni di tipo `IO ()`, la loro composizione

``` haskell
A >> B >> C
```

può essere scritta come

``` haskell
do A
   B
   C
```

in cui le azioni sono elencate e **allineate verticalmente** dopo la
parola chiave `do`. L'allineamento verticale delle azioni in un
blocco `do` consente ad Haskell di capire qual è l'estensione
complessiva del blocco. Naturalmente, il numero delle azioni
composte può variare a seconda dei casi. Ad esempio,

``` haskell
putStrLn :: String -> IO ()
putStrLn []       = return '\n'
putStrLn (c : cs) = do putChar c
                       putStrLn cs
```

è una realizzazione alternativa della funzione ricorsiva `putStrLn`
[descritta in precedenza]({{ site.baseurl }}{% link _pages/IO.md
%}#putStrLn).

## Composizione con passaggio del risultato

Quando si compongono due azioni `A` e `B` in cui il risultato
dell'esecuzione di `A` può servire all'esecuzione di `B` si usa
l'operatore di bind `A >>= \x -> B` in cui `x` è il nome scelto per
rappresentare il risultato di `A` in `B`. È possibile ottenere la
stessa composizione di `A` e `B` in un blocco `do` nel seguente modo

``` haskell
do x <- A
   B
```

in cui il nome scelto `x` è visibile in `B` e, in generale, in tutte
le azioni che seguono `A` nella composizione.

Ad esempio, l'azione [`parrot`]({{ site.baseurl }}{% link
_pages/IO.md %}#parrot) descritta nella traccia precedente può
essere definita con la notazione `do` nel modo seguente:

``` haskell
parrot :: IO ()
parrot = do s <- getLine
            if null s then return ()
            else do putStrLn (map toUpper s)
                    parrot
```

Si noti la presenza di due blocchi `do` annidati e di come
l'indentazione sia fondamentale per stabilire che l'azione `parrot`
fa parte del blocco più interno.

## Esercizi

1. Usando la notazione `do`, definire una funzione `for :: [a] -> (a
   -> IO ()) -> IO ()` che, applicata a una lista e a una funzione
   `f`, crei l'azione che, se eseguita, causi l'esecuzione di `f x`
   per ogni elemento `x` della lista.
   ^
   ``` haskell
   for :: [a] -> (a -> IO ()) -> IO ()
   for []       _ = return ()
   for (x : xs) f = do f x
                       for xs f
   ```
   {:.solution}
2. Ridefinire [`putStrLn`], questa volta facendo uso di `for`
   definita nell'esercizio precedente.
   ^
   ``` haskell
   putStrLn :: String -> IO ()
   putStrLn s = do for s putChar
                   putChar '\n'
   ```
   {:.solution}
3. Definire nuovamente l'azione [`getLines`]({{ site.baseurl }}{%
   link _pages/IO.md %}#getLines), questa volta usando la notazione
   `do`.
   ^
   ``` haskell
   getLines :: IO [String]
   getLines = do l <- getLines
                 if null l then return []
                 else do ls <- getLines
                         return (l : ls)
   ```
   {:.solution}
