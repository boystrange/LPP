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
