---
title: Contatore di accessi Web
category: case study
tags: map
---

Lo scopo del programma che vogliamo sviluppare in questo caso di
studio è quello di contare il numero di accessi unici a un
determinato sito Web, del quale supponiamo di avere a disposizione il
log file del relativo server. Un tipico esempio di log file è
mostrato qui sotto:

```
66.249.65.36 - - [25/Jun/2017:06:37:37 +0200] "GET /robots.txt HTTP/1.1" 404 208 "-" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
66.249.65.38 - - [25/Jun/2017:06:37:37 +0200] "GET /favicon.ico HTTP/1.1" 404 209 "-" "Googlebot-Image/1.0"
93.41.213.192 - - [25/Jun/2017:09:05:18 +0200] "GET / HTTP/1.1" 200 2475 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
93.41.213.192 - - [25/Jun/2017:09:05:18 +0200] "GET /style.css HTTP/1.1" 200 667 "http://tlt2017.di.unito.it/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
93.41.213.192 - - [25/Jun/2017:09:05:20 +0200] "GET /favicon.ico HTTP/1.1" 404 209 "http://tlt2017.di.unito.it/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
93.41.213.192 - - [25/Jun/2017:09:05:19 +0200] "GET /background.jpg HTTP/1.1" 200 4645992 "http://tlt2017.di.unito.it/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
93.88.113.130 - - [26/Jun/2017:07:32:40 +0200] "GET / HTTP/1.1" 200 2475 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
93.88.113.130 - - [26/Jun/2017:07:32:40 +0200] "GET /style.css HTTP/1.1" 200 667 "http://tlt2017.di.unito.it/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
79.226.254.210 - - [26/Jun/2017:08:04:58 +0200] "GET / HTTP/1.1" 200 2475 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.79 Safari/537.36 Edge/14.14393"
```

Il log file è un file di testo in cui, su ogni riga, sono riportati
alcuni dettagli relativi a una risorsa richiesta da un cliente e che
il server Web ha fornito. Nelle righe che vediamo nell'esempio qui
sopra sono facilmente riconoscibili l'indirizzo IP del cliente
(all'inizio di ogni riga), la data dell'accesso, la risorsa
richiesta (ad esempio il file `robots.txt`), ed alcune informazioni
su browser e sistema operativo del cliente (ad esempio `Mozilla` o
`Win64`).

Ciò che rende interessante il problema, e che impedisce la soluzione
semplicistica che si limita a **contare** le righe del log file, è che
in genere avvengono più accessi da parte dello stesso cliente (con
un determinato indirizzo IP), mentre noi siamo interessati a
calcolare il numero di **clienti unici** che hanno acceduto a un
determinato sito. Useremo l'indirizzo IP come chiave di
riconoscimento di un cliente. Pertanto, lo scopo del programma
diventa quello di contare il numero di indirizzi IP **distinti** che
si trovano all'inizio di ogni riga del log file.

## Una tipica realizzazione imperativa in Java

La prima soluzione che discutiamo, mostrata qui sotto, consiste di
un metodo Java che, applicato allo stream di caratteri contenente il
log file, ritorna il numero di accessi unici:

``` java
public static int counter(InputStream stream) {
    Scanner scanner = new Scanner(stream);
    Set<String> clients = new HashSet<>();
    while (scanner.hasNextLine()) {
        String line = scanner.nextLine();
        String ip = line.substring(0, line.indexOf(' ') + 1);
        clients.add(ip);
    }
    return clients.size();
}
```

La strategia è semplice: si istanzia un oggetto della classe
`Scanner` per poter analizzare lo `stream` di caratteri in ingresso
una riga alla volta.  Si crea anche un insieme di stringhe `clients`
che viene popolato con gli indirizzi IP incontrati nel log
file. Trattandosi di un insieme, esso conterrà al massimo una
occorrenza di ogni indirizzo IP. Il corpo principale del programma è
racchiuso in un ciclo `while` che esegue tre operazioni in
quest'ordine: **lettura** di una riga dal log file, **estrazione**
dell'indirizzo IP dalla riga, ed **inserimento** dell'indirizzo IP
nell'insieme `clients`.  Il metodo termina ritornando il numero di
elementi contenuti in `clients`.

Ci sono due aspetti da evidenziare che caratterizzano questa
implementazione del programma e che, come vedremo, la distinguono da
realizzazioni in stile più "funzionale".  Il primo aspetto è il
ruolo fondamentale che gioca lo **stato** degli oggetti `scanner` e
`clients`. Anche se non conosciamo i dettagli implementativi delle
classi `Scanner` e `HashSet` delle quali questi oggetti sono
istanze, è evidente che i metodi `nextLine` e `add` alterano lo
stato di questi due oggetti. Il metodo `nextLine` colleziona
l'insieme di caratteri che formano una singola riga del log file e
**fa avanzare** `scanner` alla riga successiva, in modo tale che ogni
invocazione di `nextLine` ritorni una riga diversa invece che sempre
la stessa. Il metodo `add` **aggiunge** una stringa all'insieme
`clients`, a patto che tale stringa non sia già presente
nell'insieme. In entrambi i casi notiamo che l'effetto
dell'invocazione di un metodo dipende non solo da eventuali
argomenti del metodo, ma anche dallo stato dell'oggetto
ricevente. Al programmatore è dunque richiesto uno sforzo
concettuale significativo per decidere se e quando invocare un
metodo sull'oggetto, dal momento che tale decisione dipende da
un'entità (lo stato degli oggetti) che non è direttamente
osservabile nella struttura del programma.

Il secondo aspetto chiave è che le singole istruzioni del metodo
corrispondono a operazioni molto semplici (lettura di una riga,
estrazione di un indirizzo IP, inserimento dell'indirizzo IP)
intrecciate tra loro all'interno del ciclo `while` in un ordine
ben preciso. Per questo motivo, il metodo ha poco senso se non
considerato nella sua interezza, dal momento che è difficile
riconoscere in esso ed isolare operazioni di più alto livello.

## Bash

Illustriamo ora un modo diverso di risolvere il problema oggetto di
questo caso di studio. Lo facciamo scrivendo uno script per una
tipica shell da terminale di un sistema operativo Unix-like. Lo
script ci permette di ottenere esattamente lo stesso risultato
dell'implementazione Java appena vista, ma con due differenze
sostanziali: facendo a meno della nozione di stato e seguendo un
approccio composizionale per strutturare il programma.  In mancanza
di uno stato, l'unica entità su cui il programma può lavorare è il
log file. Qui la strategia è quella di progettare una catena di
trasformazioni successive che ci consentano di elaborare il log file
dal suo formato iniziale al numero di accessi unici. Lo script che
realizza questa catena di trasformazioni è il seguente:

``` bash
cut -d' ' -f1 | sort -u | wc -l
```

Il comando `cut -d' ' -f1` ritaglia (`cut`) il **primo campo** (da
"field", `-f1`) da ogni riga di testo elaborata, dove i campi si
considerano **delimitati** da uno spazio (da "delimiter", `-d'
'`). Dunque alla fine della prima trasformazione ci ritroveremo con
una lista di indirizzi IP.  Il comando `sort -u` ordina (`sort`) la
lista in ingresso eliminando eventuali elementi duplicati (da
"unique", `-u`). Dunque, alla fine della seconda trasformazione
avremo una lista di indirizzi IP in cui ogni indirizzo compare una
volta sola.  Infine, il comando `wc -l` conta (da "word count",
`wc`) le linee in ingresso (`-l`) e ne stampa il numero.

In netto contrasto con la soluzione precedente, notiamo alcune
differenze sostanziali:
1. Non esiste una nozione implicita di stato. Tutto ciò che serve
   per comprendere il significato del programma è scritto nel
   programma.
2. Ciascuna trasformazione elabora per intero il proprio input e
   dunque ha un'identità ben definita anche se considerata
   separatamente dal resto del programma.
3. Le differenti trasformazioni sono assemblate in maniera
   composizionale per mezzo dell'operatore di pipe `|` che collega
   l'output di una trasformazione all'input della successiva.

## Haskell

La realizzazione Haskell del programma che conta gli accessi unici è
strutturata in modo simile a quella che abbiamo discusso per la shell
Bash ed è basata su principi analoghi. In pratica si tratta di
comporre in un ordine opportuno funzioni che trasformano il log file
progressivamente fino ad ottenere il risultato desiderato. Il codice
è questo:

``` haskell
import Data.List (nub);
counter :: String -> Int
counter = length . nub . map (\line -> takeWhile (/= ' ') line) . lines
```

La clausola `import` serve per rendere visibili definizioni
contenute in un particolare modulo della libreria standard di
Haskell. In questo caso specifico, siamo interessati alla funzione
`nub` del modulo `Data.List`. Solo un piccolo sottoinsieme di
funzioni di libreria sono visibili -- e dunque utilizzabili -- di
default. Si tratta delle funzioni contenute nel cosiddetto
"preludio". Tutte le altre funzioni, come `nub`, devono essere
importate esplicitamente.

Le ultime due righe rispettivamente dichiarano e definiscono una
**funzione** chiamata `counter` che, applicata a un log file
(rappresentato come stringa di caratteri), ritorna il numero di
clienti.  La funzione `counter` è definita a partire da funzioni già
esistenti composte tra loro per mezzo dell'operatore di composizione
funzionale, denotato in Haskell dal simbolo `.` e in matematica dal
simbolo $\circ$.  Notiamo innanzi tutto che la composizione
funzionale di Haskell è definita come in matematica in modo tale che
$(f \circ g)(x) = f(g(x))$. Ciò significa che, data una catena di
trasformazioni $f_1 \circ f_2 \circ \cdots \circ f_n$, l'input viene
trasformato **da destra verso sinistra** passando prima attraverso
$f_n$, poi $f_{n-1}$ e così via, fino ad $f_1$. Questo è l'opposto
di ciò che avviene con l'operatore di pipe `|` nella Bash, che
consente di costrutire catene di trasformazioni in cui l'input viene
trasformato **da sinistra verso destra**. A parte la direzione delle
trasformazioni, ci sono molte analogie tra la soluzione Haskell e
qualla Bash.

La funzione `lines` ha lo scopo di spezzare l'input (un'unica
stringa con l'intero log file) nelle sue righe, producendo una lista
di stringhe. Questo passaggio non era necessario nella soluzione
Bash dal momento che in quel caso i comandi usati assumono già di
lavorare sui file di testo una riga alla volta. Qui invece la
scomposizione dell'input in linee distinte è una trasformazione
necessaria. Si ricorda che le linee in un file di testo sono
terminate da un carattere particolare (il carattere di "nuova
linea", appunto, in Haskell rappresentato come `'\n'`) e dunque
ciò che `lines` fa non è altro che spezzare l'input in
corrispondenza di tutte le occorrenze di questo carattere.

La funzione `map (\line -> takeWhile (/= ' ') line)` realizza
l'operazione di estrazione degli indirizzi IP. La funzione `map`
applicata a funzione $f$ e a una lista trasforma **ogni**
elemento della lista usando $f$. Notiamo dunque due tratti
distintivi di un linguaggio funzionale:

* è possibile passare funzioni come argomenti di altre funzioni. Nel
  caso specifico, `map` è detta **funzione di ordine superiore**
  proprio perché ammette un'altra funzione come argomento;
* è possibile definire **funzioni anonime** "al volo", laddove ve ne
  sia bisogno. Nel caso specifico, `\line -> takeWhile (/= ' ')
  line` è una funzione anonima che, applicata a una riga `line` del
  log file, estrae il prefisso (`takeWhile`) contenente caratteri
  diversi (`/=`) dallo spazio (`' '`), che sappiamo indicare la fine
  dell'indirizzo IP. Questo costrutto prende il nome di "$\lambda$
  astrazione" per ragioni che diventeranno chiare in seguito. Il
  simbolo `\` serve proprio a richiamare la forma della lettera
  greca $\lambda$.

La terza trasformazione applicata è `nub`, la funzione
importata dal modulo `Data.List`, la quale elimina gli elementi
duplicati da una lista. Dunque, alla fine della terza trasformazione
abbiamo una lista di indirizzi IP in cui ciascun indirizzo non
compare mai più di una volta.

La quarta e ultima trasformazione è `length`, che ritorna la
lunghezza di una lista, ovvero il numero di elementi contenuti in
essa. Tale numero è proprio il numero di accessi unici al sito
Web.

Anche per la soluzione Haskell valgono le stesse osservazioni 1--3
già fatte per la soluzione Bash. In particolare, abbiamo ottenuto
una trasformazione complessa **componendo** trasformazioni più
semplici per mezzo dell'operatore `.`. Questa caratteristica di
modularità in Haskell è portata all'estremo. In particolare, anche
`map` e `takeWhile` prese in isolamento sono a loro volta
trasformazioni semplici e molto più generiche di quanto la loro
descrizione approssimativa data sopra non lasci intendere.  Abbiamo
silenziosamente composto `map` e `takeWhile` insieme al predicato
"essere un carattere diverso dallo spazio" (`/= ' '`) usando un
meccanismo detto **applicazione parziale di funzione**, un altro
ingrediente caratterizzante della programmazione funzionale che
incoraggia il riuso e la specializzazione del codice e con il quale
familiarizzeremo più avanti.

Concludiamo con due osservazioni che riguardano il ruolo dei
**tipi** in Haskell e che lo differenziano in modo sostanziale da un
linguaggio di programmazione non tipato come Bash.

Haskell è un linguaggio fortemente tipato. Ogni funzione è
dotata di un tipo della forma $t \to s$ che specifica la natura dei
valori che la funzione accetta in ingresso ($t$) e quella dei valori
che la funzione produce ($s$). Il compilatore Haskell controlla che
le funzioni siano applicate e composte rispettando il loro tipo.
Avere questo controllo effettuato dal compilatore è un grosso
aiuto che consente di individuare un gran numero di errori prima di
eseguire il programma, al punto che un programma scritto in Haskell
non potrà mai terminare in modo anomalo a causa di errori come
"null pointer exception" oppure "segmentation fault".

Il ruolo dei tipi, soprattutto in un linguaggio "senza stato" come
Haskell, va oltre la correttezza dei programmi. Per fare un esempio,
si potrebbe argomentare che è possibile arrivare a una soluzione
compatta come quella mostrata qui sopra solo sapendo dell'esistenza
di una funzione come `lines`. Tuttavia, anche non sapendo
dell'esistenza di `lines`, è facile intuire che nella progettazione
di una catena di trasformazioni come quella usata poc'anzi occorra,
come primo passo, una funzione che accetti in ingresso una stringa
(di tipo `String`) e produca una lista di stringhe (di tipo
`[String]`). A questo punto si può usare il tipo della funzione
desiderata come **chiave di ricerca** all'interno della libreria
standard di Haskell, per vedere se c'è qualche funzione che ha
questo tipo. Questa idea è stata realizzata nel [motore di ricerca
Hoogle](https://www.haskell.org/hoogle/). Se si prova a cercare una
funzione di tipo `String -> [String]` in Hoogle, il primo risultato
ottenuto è proprio `lines`.  L'utilizzo dei tipi come chiavi di
ricerca è particolarmente efficace in Haskell rispetto ad altri
linguaggi in quanto Haskell è un linguaggio puro, in cui le funzioni
non manipolano alcuno stato implicito. Questo significa che tutto
ciò che le funzioni fanno di interessante "lascia una traccia" nel
loro tipo. Per fare un paragone con `lines`, il metodo `nextLine`
della classe `Scanner`, che abbiamo usato nella soluzione Java, non
ha argomenti e ritorna un valore di tipo `String`. Tuttavia, ci sono
innumerevoli metodi nella libreria standard di Java che hanno questa
segnatura (ad esempio `toString`), proprio perché tutti questi
metodi accedono e/o manipolano uno stato implicito del sistema o
dell'oggetto su cui sono invocati, invece che lavorare
esclusivamente sui loro argomenti. Dunque, in un linguaggio come
Java, il tipo dei metodi senza argomenti e che ritornano una stringa
dice poco sul comportamento effettivo di questi metodi.

## Java 8

Concludiamo questo caso di studio analizzando una soluzione
alternativa del programma scritto ancora una volta in Java, ma
questa volta facendo uso di alcune caratteristiche introdotte a
partire dalla versione 8 di Java e ispirate alla programmazione
funzionale.

``` java
public static long counter(InputStream stream) {
    InputStreamReader reader = new InputStreamReader(stream);
    return new BufferedReader(reader)
        .lines()
        .map(line -> line.substring(0, line.indexOf(' ') + 1))
        .distinct()
        .count();
}
```

La parte interessante del metodo è l'espressione che segue il
comando `return`, in cui si istanzia la classe `BufferedReader` per
accedere allo stream di caratteri provenienti dallo standard input,
e poi si elabora questo stream per mezzo di una catena di
trasformazioni successive, ciascuna rappresentata da un metodo che
viene invocato su uno stream di input e che produce un altro stream
o, in generale, un altro valore a partire dallo stream di input.  Il
metodo `lines`, proprio come la funzione `lines` in Haskell,
trasforma lo stream di caratteri in input in uno stream di stringhe,
una per ogni riga dell'input.  Il metodo `map` trasforma ciascuna
riga dello stream di stringhe estraendo la sottostringa compresa tra
il carattere in posizione 0 e l'indice della prima occorrenza dello
spazio che, come sappiamo, marca la fine dell'indirizzo IP. La
sintassi `line -> line.substring(...)`  richiama da vicino il
costrutto `\line -> takeWhile (/= ' ') line` visto in Haskell ed
infatti indica anche qui una cosiddetta "$\lambda$ astrazione",
ovvero una funzione che, applicata a una stringa `line` (a sinistra
del simbolo `->`), produce il valore rappresentato dall'espressione
a destra del simbolo `->`.  Il metodo `distinct` gioca lo stesso
ruolo di `nub` in Haskell ed elimina elementi duplicati dallo stream
di input.  Infine, `count` restituisce il numero di elementi dello
stream di input.
