---
title: Caratteri e stringhe
---

## Caratteri

In Haskell le costanti carattere si introducono scrivendo i
caratteri direttamente tra singoli apici.

``` haskell
'a'
'b'
'a' == 'A'
```

Le costanti per i caratteri "invisibili" si specificano facendo uso
delle stesse *sequenze di escape* riconosciute da altri linguaggi di
programmazione. Le più comuni sono:

``` haskell
'\n' -- ritorno a capo
'\t' -- tabulazione
'\\' -- backslash
'\'' -- apice singolo
'\"' -- doppi apici
```

È possibile specificare caratteri anche specificandone direttamente
il codice Unicode.

``` haskell
'\32'   -- spazio
'\48'   -- cifra decimale 0
'λ'     -- lettera greca λ
'\x3BB' -- lettera greca λ
```

Nell'ultimo esempio la `x` indica che il codice Unicode è scritto in
base 16, mentre di norma (come nei primi due esempi) è in base 10.

Il **tipo dei caratteri** si chiama `Char` ed è distinto dal (e
incompatibile con il) tipo dei numeri interi.

``` haskell
:type '0'
```

Non esistono conversioni implicite da caratteri a numeri interi e
viceversa. Queste conversioni sono realizzate dalle funzioni `ord` e
`chr` della libreria standard. Per utilizzare queste funzioni è
necessario **importarle** dal modulo `Data.Char` in cui sono
definite, scrivendo la seguente clausola all'*inizio* dello script
nel quale si intende utilizzarle.

``` haskell
import Data.Char (ord, chr)
```

``` haskell
ord '0'
chr 48
```

## Stringhe

In Haskell le stringhe si introducono scrivendone i caratteri
racchiusi tra doppi apici.

``` haskell
""
"Haskell"
"Questa è una stringa con spazi"
```

Il **tipo delle liste** si chiama `String` e in Haskell tale tipo è
solo un alias per il tipo `[Char]`. In altre parole, le stringhe
sono rappresentate come liste di caratteri.

``` haskell
['H', 'a', 's', 'k', 'e', 'l', 'l']
[] == ""
['x', 'y', 'z'] /= "xyz"
```

Tutte le funzioni definite sulle liste sono applicabili anche alle
stringhe. Per esempio, è possibile usare la funzione `length` per
calcolare la lunghezza di una stringa e l'operatore `++` per
concatenare due stringhe.

``` haskell
length "xyz"
"Has" ++ "kell"
```

## Esercizi

Il simbolo <i class="fas fa-skull"></i> indica una potenziale
difficoltà.

1. Definire una funzione `showHex :: Int -> String` che, applicata a
   un numero intero, ne restituisca la rappresentazione in
   base 16. Fare attenzione alla possibilità che il numero sia
   negativo. Suggerimento: definire una funzione ausiliaria per
   convertire un numero intero compreso tra 0 e 15 (estremi inclusi)
   nel carattere corrispondente in base 16.
   ^
   ``` haskell
   showHex :: Int -> String
   showHex n | n < 0     = '-' : showHex (negate n)
             | n < 16    = [aux n]
             | otherwise = showHex (n `div` 16) ++ [aux (n `mod` 16)]
     where
       aux n | n < 10    = chr (ord '0' + n)
             | otherwise = chr (ord 'A' + n - 10)
   ```
   {:.solution}
2. <i class="fas fa-skull"></i>
   Senza fare uso di funzioni della libreria standard ad eccezione
   di `ord` e `chr`, definire una funzione `readHex :: String ->
   Int` che, applicata a una stringa di cifre esadecimali,
   restituisca il numero intero (non negativo)
   corrispondente. Prestare attenzione alla possibilità che le cifre
   decimali siano minuscole o maiuscole.
   ^
   ``` haskell
   readHex :: String -> Int
   readHex = aux 0
     where
       aux res [] = res
       aux res (c : cs) = aux (res * 16 + readChar c) cs

       readChar c | c >= '0' && c <= '9' = ord c - ord '0'
                  | c >= 'a' && c <= 'f' = ord c - ord 'a' + 10
                  | c >= 'A' && c <= 'F' = ord c - ord 'A' + 10
   ```
   {:.solution}
3. <i class="fas fa-skull"></i>
   Ripetere l'esercizio precedente, questa volta senza fare uso
   esplicito della ricorsione ma potendo usare tutte le funzioni
   della libreria standard.
   ^
   ``` haskell
   readHex :: String -> Int
   readHex = foldl (\res c -> res * 16 + readChar c) 0
     where
       readChar c | c >= '0' && c <= '9' = ord c - ord '0'
                  | c >= 'a' && c <= 'f' = ord c - ord 'a' + 10
                  | c >= 'A' && c <= 'F' = ord c - ord 'A' + 10
   ```
   {:.solution}
