window.MathJax = {
    options: {
	skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre'],
	ignoreHtmlClass: 'tex2jax_ignore',
	processHtmlClass: 'tex2jax_process',
	includeHtmlTags: {
	    br: '\\\\',
	},
    },
    tex: {
	inlineMath: [['$','$'], ['\\(','\\)']],
	processEscapes: true,
	macros: {
	    PUSH:     ["\\mathtt{PUSH}~{#1}", 1],
	    LOAD:     ["\\mathtt{LOAD}~{#1}", 1],
	    STORE:    ["\\mathtt{STORE}~{#1}", 1],
	    OP:       ["\\mathtt{OP}~{#1}", 1],
	    IF:       ["\\mathtt{IF}~{#1}~{#2}", 2],
	    RETURN:   "\\mathtt{RETURN}",
	    lcal:     "\\mathcal{L}",
	    set:      ["\\{#1\\}", 1],
	    nullable: "\\mathit{null}",
	    derive:   ["#2[#1]", 2],
	},
	autoload: {
	    color: [],
	    colorV2: ['color']
	},
	packages: {'[+]': ['noerrors', 'html']}
    },
    loader: {
	load: ['[tex]/noerrors', '[tex]/html']
    }
};
