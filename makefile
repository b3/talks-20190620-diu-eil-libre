QUOI := libertes partage

# on se débarrase des tabulations
.RECIPEPREFIX := >

# GNU et BSD n'ont pas les mêmes options pour utiliser les ERE
SED := sed$(shell { sed v </dev/null >&0 2>&1 && echo " -r" ; } || echo " -E" )

# configuration des transformations
PANDOC := pandoc -t beamer --template=etc/beamer-pandoc.tex --slide-level=2 --wrap=preserve -s --lua-filter=etc/latex-pandoc.lua
export TEXINPUTS := .//:


# diapositives - pour projection
%-ecran.pdf: %.md images $(wildcard etc/*)
> $(PANDOC) -V aspectratio=169 $< -o $@

# diapositives - pour impression
%-papier.pdf: %.md images $(wildcard etc/*)
> $(PANDOC) -V aspectratio=141 -V handout=handout $< -o $@
> pdfjam --nup 2x2 --landscape --frame=true --keepinfo --quiet --outfile $@- $@
> mv $@- $@

# svg -> pdf
img/%.pdf: img/%.svg
> inkscape -z -d 2400 -A $@ -T $<


help:                           ## liste les cibles disponibles
> @eval $$($(SED) -n '/^[[:alnum:]_-]+:/ s/^(.*):[^#]*(## |)(.*)$$/printf "\\033[31m\\033[1m%-15s\\033[0m %s\\n" "\1" "\3";/ ; ta; b; :a p' $(MAKEFILE_LIST))

PDFS := $(foreach f,$(QUOI),$(addprefix $(f),-ecran.pdf -papier.pdf))
build: $(PDFS)                  ## génère les présentations

IMG-SVG := $(wildcard img/*.svg)
IMG-PDF := $(addsuffix .pdf,$(basename $(IMG-SVG)))
images: $(IMG-PDF)              ## génère les versions PDF des images

.PHONY: clean full-clean check
clean:                          ## supprime les fichiers inutiles
> @find . -name "*~" -delete -print

full-clean: clean               ## supprime tous les fichier regénérables et inutiles
> -$(RM) $(PDFS) $(IMG-PDF)

check:                          ## vérifie la présence des outils nécessaires
> @which pandoc
> @kpsewhich beamer.cls
> @which inkscape
> @which pdfjam
