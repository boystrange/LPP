---
layout: home
title: Indice
---

Queste pagine contengono le **tracce** di laboratorio del corso
Linguaggi e Paradigmi di Programmazione. Ogni lezione di laboratorio
copre una o più tracce, che possono essere di due **tipi**:

<ul class="fa-ul">
  <li>
    <span class="fa-li">
	  <i class="far fa-file"></i>
	</span>
	<strong>Schede</strong>: illustrano sinteticamente e per mezzo di piccoli
	esempi i costrutti fondamentali del linguaggio di programmazione
	Haskell e servono per acquisire gradualmente familiarità con il
	linguaggio;
  </li>
  <li>
    <span class="fa-li">
	  <i class="fas fa-file"></i>
	</span>
	<strong>Casi di studio</strong>: illustrano in maniera estesa e dettagliata la
	risoluzione di un problema nel paradigma
	di programmazione funzionale, mettendo in luce le principali
	differenze della soluzione rispetto ad altre per paradigmi di
	programmazione differenti.
  </li>
</ul>

{% for block in site.data.navigation.blocks %}
  {% if jekyll.environment == "development" or block.public %}
  <h2>
    {{ block.title }}
    {% unless block.public %}
	<i class="fas fa-cog fa-spin"></i>
	{% endunless %}
  </h2>
  <ul class="fa-ul">
    {% for track in block.children %}
    <li>
      <span class="fa-li">
        {% if track.case %}
          <i class="fas fa-file"></i>
        {% else %}
          <i class="far fa-file"></i>
        {% endif %}
      </span>
	  {% if track.name %}
      <a href="{{ track.name }}">{{ track.title }}</a>
	  {% else %}
	  {{ track.title }}
	  {% endif %}
    </li>
    {% endfor %}
  </ul>
  <p/>
  {% endif %}
{% endfor %}
