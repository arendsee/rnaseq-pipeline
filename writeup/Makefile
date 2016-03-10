TARGET=report

${TARGET}.pdf: ${TARGET}.Rnw images/* ${TARGET}.bib
	latexmk -bibtex -pdf ${TARGET}.Rnw

.PHONY: clean
clean:
	latexmk -c ${TARGET}.Rnw
