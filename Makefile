
all:
	bundle exec jekyll serve --incremental

serve:
	bundle exec jekyll serve

links:
	( \
		NAMES=$$(grep -o -e "\[\`[^\`]*\`\]" *.md  | cut -d'`' -f2 | sort -u); \
		rm -f _includes/links.md; \
		for i in $$NAMES; do \
		  echo [\`$$i\`]: https://hoogle.haskell.org/?hoogle=$$i\&scope=set%3Aincluded-with-ghc >>_includes/links.md; \
		done \
	)

clean:
	bundle exec jekyll clean

