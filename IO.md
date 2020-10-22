---
title: La monade di Input/Output
---

In un linguaggio di programmazione lazy come Haskell, in cui
l'ordine di valutazione delle espressioni è pressoché impossibile da
prevedere, è difficile equipaggiare il linguaggio con "funzioni" che
abbiano effetti collaterali. Per esempio, supponiamo 

## Una monade

In sintesi, una monade consiste dei seguenti elementi:

* Un costruttore di tipo `m`
* Una funzione di **iniezione** `return :: Monad m => a -> m a` che,
  applicata a un valore $v$ di tipo `a`, crea un'azione `m a` della
  monade che, se eseguita, non ha alcun effetto e produce $v$ come
  risultato.
* Un operatore di **combinazione** `(>==) :: Monad m => m a -> (a ->
  m b) -> m b` storicamente detto **bind** che, data un'azione $p$
  di tipo `m a` della monade e una funzione $f$ di tipo `a -> m b`,
  crea un'azione combinata che, se eseguita, esegue prima $p$ e poi
  l'azione ottenuta applicando $f$ al risultato dell'esecuzione di
  $p$.

## Monade di Input/Output

Un valore di tipo `IO a` è un'**azione** che, **se eseguita**, può
effettuare delle operazioni di input/output e alla fine produce un
risultato di tipo `a`. Ci sono due operazioni fondamentali per
creare e combinare valori 

* `return :: a -> IO a`
* `(>==)  :: IO a -> (a -> IO b) -> IO b`
