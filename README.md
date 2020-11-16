# Laboratorio di Linguaggi e Paradigmi di Programmazione

## Installazione locale

``` bash
bundle update
make
```

## Attenzione

* Lo script che raccoglie i riferimenti alla libreria standard non
  funziona se si richiedono hyperlink per operatori che contengono
  asterischi come `*` e `**` perché questi vengono espansi dalla
  Shell.
* Non creare link al costruttore `[]` perché le parentesi quadre
  hanno un significato speciale in Markdown.
* In `kramdown` le definizioni di link sono *case insensitive* e
  dunque `show` e `Show` finiscono per puntare alla stessa pagina.
