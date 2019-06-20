.RECIPEPREFIX := >
.PHONY: clean full-clean check

SED=sed$(shell { sed v </dev/null >/dev/null 2>&1 && echo " -r" ; } || echo " -E" )

export TEXINPUTS := .//:

%.pdf: %.md
> pandoc -t beamer --template=etc/beamer-pandoc.tex --slide-level=2 --wrap=preserve -s $< -o $@

%.pdf: %.tex
> pandoc -t beamer --template=etc/beamer-pandoc.tex --slide-level=2 --wrap=preserve -s $< -o $@

img/%.pdf: img/%.svg
> inkscape -z -d 2400 -A $@ -T $<

help:                           ## liste les cibles disponibles
> @eval $$($(SED) -n '/^[a-zA-Z0-9_-]+:/ s/^(.*):([^#]*)(## |)(.*)$$/printf "\\033[36m%-10s\\033[0m %s\\n" "\1" "\4";/ ; ta; b; :a p' $(MAKEFILE_LIST))

prez: images libertes.pdf partage.pdf ## génère la présentation

IMG-SVG := $(wildcard img/*.svg)
IMG-PDF := $(addsuffix .pdf,$(basename $(IMG-SVG)))
images: $(IMG-PDF)              ## regénère les versions PDF des images

clean:                          ## supprime les fichiers inutiles (*~)
> @find . -name "*~" -delete -print

full-clean: clean               ## supprime tous les fichier regénérables
> -rm libertes.pdf partage.pdf $(IMG-PDF)

check:                          ## vérifier la présence des outils nécessaires
> @bin/md2pdf -c
> @which inkscape || echo inkscape inacessible
