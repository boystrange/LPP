
NULL =

all:
	bundle exec jekyll serve --incremental

serve:
	bundle exec jekyll serve

links:
	( \
		NAMES=$$(grep -o -e "\[\`[^\`]*\`\]" *.md | cut -d\` -f2 | sort -u); \
		rm -f _includes/links.md; \
		for i in $$NAMES; do \
		  K=$$(./assets/bash/mdencode $$i); \
                  I=$$(./assets/bash/urlencode $$i); \
		  set -f; \
		  echo "Processing " $$i $$K $$I; \
		  echo [\`$$K\`]: https://hoogle.haskell.org/?hoogle=$$I%20is%3Aexact\&scope=set%3Aincluded-with-ghc >>_includes/links.md; \
		done \
	)

clean:
	bundle exec jekyll clean
