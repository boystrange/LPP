---
title: Installazione
toc: false
---

Per lo svolgimento delle esercitazioni di laboratorio è necessario
installare l’interprete Haskell GHCi ed il compilatore Haskell
GHC. I passaggi specifici per farlo dipendono strettamente dal
sistema operativo utilizzato, la pagina [The Glasgow Haskell
Compiler](https://www.haskell.org/ghc/) contiene link ai pacchetti
per tutti i sistemi operativi.

Laddove il proprio sistema operativo è dotato di un *package
manager*, è solitamente preferibile usare quest'ultimo per
installare Haskell invece di scaricare direttamente i pacchetti
disponibili al link qui sopra. Per esempio, quasi tutte le
distribuzioni di **Linux** forniscono dei pacchetti preconfezionati
per GHC. Nel caso di **MacOS**, se si utilizza
[Homebrew](https://brew.sh) è possibile installare
l’interprete/compilatore Haskell con il comando

``` bash
brew install ghc
```

Una volta ultimata l’installazione, deve essere possibile eseguire
il compilatore Haskell eseguendo il comando `ghc` dal terminale
(`cmd.exe` in Windows)

``` bash
$ ghc
ghc: no input files
Usage: For basic information, try the `--help' option.
```

e l’interprete Haskell eseguendo il comando `ghci`:

``` bash
$ ghci
GHCi, version 8.10.1: https://www.haskell.org/ghc/  :? for help
Prelude>
```

Il **prompt** `Prelude>` indica che l’interprete è pronto ad
accettare espressioni Haskell da valutare. Si può uscire
dall’interprete in vari modi:

* Premendo `CTRL-D` in Linux o MacOS.
* Premendo `CTRL-Z` in Windows.
* Digitando `:quit` oppure l'abbreviazione `:q`.

## Esercizi

1. Installare ed eseguire l’interprete/compilatore Haskell,
   verificarne il funzionamento eseguendo i comandi `ghc` e `ghci`
   come illustrato qui sopra.
