---
layout: home
title: Linguaggi e Paradigmi di Programmazione
---

Queste pagine contengono le **tracce** di laboratorio del corso
Linguaggi e Paradigmi di Programmazione. Ogni lezione di laboratorio
copre una o più tracce, che possono essere di due tipi:

* **Schede**: illustrano sinteticamente e per mezzo di piccoli
  esempi i costrutti fondamentali del linguaggio di programmazione
  Haskell e servono per acquisire gradualmente familiarità con il
  linguaggio;
* **Casi di studio**: illustrano in maniera estesa e dettagliata la
  risoluzione di un problema (relativamente) complesso nel paradigma
  di programmazione funzionale, mettendo in luce le principali
  differenze della soluzione rispetto ad altre per paradigmi di
  programmazione differenti.

## Introduzione

* [Installazione](Installazione.md)
* [Legature](Legature.md)

## Laboratorio 1

* [Caso di studio: contatore di accessi Web](HitCounter.md)
* [Espressioni aritmetiche](Espressioni.md)
* [Espressioni logiche](Proposizioni.md)
* [Script](Script.md)
* [Definizione e applicazione di funzioni](Funzioni.md)

## Laboratorio 2

* [Funzioni con guardie](Guardie.md)
* [Funzioni ricorsive](Ricorsione.md)
* [Funzioni anonime e sezioni](Lambda.md)
* [Funzioni a più argomenti](Currying.md)
* [Caso di studio: dall'iterazione alla ricorsione](Iterazione.md)

## Laboratorio 3

* [Tipi e classi](Tipi.md)
* [Coppie e tuple](Tuple.md)
* [Liste](Liste.md)
* [Pattern matching di liste](PatternMatching.md)
* [Caso di studio: Fibonacci logaritmico](FastFibonacci.md)
* [Caso di studio: Insertion Sort e Merge Sort](Ordinamento.md)

## Laboratorio 4

* [Polimorfismo](Polimorfismo.md)
* [Approfondimento sulle classi](PolimorfismoLimitato.md)
* [Caso di studio: trasformazioni di liste e Quick Sort](QuickSort.md)
* [List comprehension](ListComprehension.md)
* [Caso di studio: integrazione numerica](Trapezi.md)

## Laboratorio 5

* [Caso di studio: la lista infinita dei numeri primi](NumeriPrimi.md)
* [Enumerazioni](Enumerazioni.md)
* [Costruttori con argomenti](CostruttoriArgomenti.md)
* [Caso di studio: implementazione della JVM](JVM.md)

{{ jekyll.environment }}

{% if jekyll.environment == "development" %}

## Laboratorio 6

{% endif %}
