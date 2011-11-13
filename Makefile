# Makefile for LaTeX files

# Original Makefile from http://www.math.psu.edu/elkin/math/497a/Makefile

# Please check http://www.acoustics.hut.fi/u/mairas/UltimateLatexMakefile
# for new versions.

# Copyright (c) 2005,2006 (in order of appearance):
#	Matti Airas <Matti.Airas@hut.fi>
# 	Rainer Jung
#	Antoine Chambert-Loir
#	Timo Kiravuo

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions: 

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software. 

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

# $Id: Makefile,v 1.18 2006-06-19 10:58:11 mairas Exp $

LATEX	= latex
BIBTEX	= bibtex
MAKEINDEX = makeindex
MAKEGLOSSARIES = makeglossaries
XDVI	= xdvi -gamma 4
DVIPS	= dvips
DVIPDF  = dvipdft
L2H	= latex2html
GH	= gv

RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"
MAKEIDX = "^[^%]*\\makeindex"
MAKEGLS = "^[^%]*\\makeglossaries"
MPRINT = "^[^%]*print"
USETHUMBS = "^[^%]*thumbpdf"

DATE=$(shell date +%Y-%m-%d)

COPY = if test -r $(<:%.tex=%.toc); then cp $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak); fi 
RM = rm -f
OUTDATED = echo "EPS-file is out-of-date!" && false

# These are OK

SRC	:= $(shell egrep -l '^[^%]*\\begin\{document\}' *.tex)
TRG	= $(SRC:%.tex=%.dvi)
PSF	= $(SRC:%.tex=%.ps)
PDF	= $(SRC:%.tex=%.pdf)

# These are not

#BIBFILE := $(shell perl -ne '($$_)=/^[^%]*\\bibliography\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.bib "}' $(SRC))
#DEP     := $(shell perl -ne '($$_)=/^[^%]*\\include\{(.*?)\}/;@_=split /,/;foreach $$t (@_) {print "$$t.tex "}' $(SRC))
#EPSPICS := $(shell perl -ne '@foo=/^[^%]*\\(includegraphics|psfig)(\[.*?\])?\{(.*?)\}/g;if (defined($$foo[2])) { if ($$foo[2] =~ /.eps$$/) { print "$$foo[2] "; } else { print "$$foo[2].eps "; }}' $(SRC) $(DEP))


define run-latex
	$(COPY);$(LATEX) $<
	egrep $(MAKEGLS) $< && ($(MAKEGLOSSARIES) $(<:%.tex=%);$(COPY);$(LATEX) $<) >/dev/null; true
	egrep -c $(RERUNBIB) $(<:%.tex=%.log) && ($(BIBTEX) $(<:%.tex=%);$(COPY);$(LATEX) $<) ; true
	egrep $(RERUN) $(<:%.tex=%.log) && ($(COPY);$(LATEX) $<) >/dev/null; true
	egrep $(RERUN) $(<:%.tex=%.log) && ($(COPY);$(LATEX) $<) >/dev/null; true
	if cmp -s $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak); then true ;else $(LATEX) $< ; fi
	$(RM) $(<:%.tex=%.toc.bak)
	# Display relevant warnings
	egrep -i "(Reference|Citation).*undefined" $(<:%.tex=%.log) ; true
endef

define run-pdflatex
	LATEX=pdflatex
	@$(run-latex)
endef

define get_dependencies
	deps=`perl -ne '($$_)=/^[^%]*\\\(?:include|input)\{(.*?)\}/;@_=split /,/;foreach $$t (@_) {print "$$t.tex "}' $<`
endef

define getbibs
	bibs=`perl -ne '($$_)=/^[^%]*\\\bibliography\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.bib "}' $< $$deps`
endef

define geteps
	epses=`perl -ne '@foo=/^[^%]*\\\(includegraphics|psfig)(\[.*?\])?\{(.*?)\}/g;if (defined($$foo[2])) { if ($$foo[2] =~ /.eps$$/) { print "$$foo[2] "; } else { print "$$foo[2].eps "; }}' $< $$deps`
endef

define manconf
	mandeps=`if test -r $(basename $@).cnf ; then cat $(basename $@).cnf |tr -d '\n\r' ; fi`
endef

all 	: $(TRG)

.PHONY	: all show clean ps pdf showps veryclean

clean	:
#-rm -f $(TRG) $(PSF) $(PDF) $(TRG:%.dvi=%.aux) $(TRG:%.dvi=%.bbl) $(TRG:%.dvi=%.blg) $(TRG:%.dvi=%.log) $(TRG:%.dvi=%.out) $(TRG:%.dvi=%.idx) $(TRG:%.dvi=%.ilg) $(TRG:%.dvi=%.ind) $(TRG:%.dvi=%.toc) $(TRG:%.dvi=%.d) #$(TRG:%.dvi=%.glo) $(TRG:%.dvi=%.gls) $(TRG:%.dvi=%.nlo) $(TRG:%.dvi=%.nls) $(TRG:%.dvi=%.gig) #$(TRG:%.dvi=%.ist) $(TRG:%.dvi=%.lof) opdr_2_booklet.pdf 
	  -rm -f $(TRG) $(PSF) $(PDF) $(TRG:%.dvi=%.aux) $(TRG:%.dvi=%.bbl) $(TRG:%.dvi=%.blg) $(TRG:%.dvi=%.log) $(TRG:%.dvi=%.out) $(TRG:%.dvi=%.idx) $(TRG:%.dvi=%.ilg) $(TRG:%.dvi=%.ind) $(TRG:%.dvi=%.toc) $(TRG:%.dvi=%.d) $(TRG:%.dvi=%.gls) $(TRG:%.dvi=%.nlo) $(TRG:%.dvi=%.nls) $(TRG:%.dvi=%.gig) $(TRG:%.dvi=%.lof) opdr_2_booklet.pdf 

veryclean	: clean
	  -rm -f *.log *.aux *.dvi *.bbl *.blg *.ilg *.toc *.lof *.lot *.idx *.ind *.ps  *~

# This is a rule to generate a file of prerequisites for a given .tex file
%.d	: %.tex
	$(get_dependencies) ; echo $$deps ; \
	$(getbibs) ; echo $$bibs ; \
	$(geteps) ; echo $$epses ; \
	$(manconf) ; echo  $$mandeps  ;\
	echo "$*.dvi $@ : $< $$deps $$bibs $$epses $$mandeps" > $@ 

include $(SRC:.tex=.d)

# $(DEP) $(EPSPICS) $(BIBFILE)
$(TRG)	: %.dvi : %.tex
	  @$(run-latex)

$(PSF)	: %.ps : %.dvi
	  @$(DVIPS) $< -o $@

$(PDF)  : %.pdf : %.dvi glossary
	  @$(DVIPDF) -o $@ $<
# To use pdflatex, comment the two lines above and uncomment the lines below
#$(PDF) : %.pdf : %.tex
#	@$(run-pdflatex)


show	: $(TRG)
	  @for i in $(TRG) ; do $(XDVI) $$i & done

showps	: $(PSF)
	  @for i in $(PSF) ; do $(GH) $$i & done

ps	: $(PSF) 

#nomenclature : $(PSF)
#		@$(MAKEINDEX) opdr_2.nlo -s nomencl.ist -o opdr_2.nls

glossary:
		@$(MAKEGLOSSARIES) opdr_2

#glossary : $(PSF)
#		@$(MAKEINDEX) opdr_2.glo -s opdr_2.ist -t opdr_2.gig -o opdr_2.gls

booklet : $(PSF)
		@psbook ./opdr_2.ps ./out2.ps
		@psnup -2 ./out2.ps ./out2up.ps
		@ps2pdf ./out2up.ps ./opdr_2_booklet.pdf
		@rm ./out2.ps
		@rm ./out2up.ps

count:
	@cat opdr_2.tex | grep -v '{' | grep -v '%' | grep -v '}' | grep -v '^\\' | wc -w

pdf	: $(PDF) 

# TODO: This probably needs fixing
html	: @$(DEP) $(EPSPICS)
	  @$(L2H) $(SRC)



######################################################################
# Define rules for EPS source files.

# These rules probably just cause unnecessary confusion, so commenting
# them away for the time being. -- mairas 2005-01-12

#%.eps: %.sxd
#	$(OUTDATED)
#%.eps: %.sda
#	$(OUTDATED)
#%.eps: %.png
#	$(OUTDATED)
#%.eps: %.sxc
#	$(OUTDATED)
#%.eps: %.xcf
#	$(OUTDATED)
##%.eps: %.zargo
#	$(OUTDATED)
#%.eps: %.m
#	@egrep -q $(MPRINT) $< && ($(OUTDATED))