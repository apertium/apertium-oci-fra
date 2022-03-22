###############################################################################
## Makefile for Occitan--French
###############################################################################

LANG1=oci
LANG1b=oci@gascon
LANG2=fra
PREFIX1=$(LANG1)-$(LANG2)
PREFIX1b=$(LANG1b)-$(LANG2)
PREFIX2=$(LANG2)-$(LANG1)
PREFIX2b=$(LANG2)-$(LANG1b)

BASENAME=apertium-$(PREFIX1)

TARGETS_COMMON =		\
	$(PREFIX1).automorf.bin	\
	$(PREFIX1b).automorf.bin	\
	$(PREFIX1).prob		\
	$(PREFIX1).rlx.bin	\
	$(PREFIX1).autobil.bin	\
	$(PREFIX1b).autobil.bin	\
	$(PREFIX1).autolex.bin	\
	$(PREFIX1b).autolex.bin	\
        $(PREFIX1).autosep1.bin \
        $(PREFIX1).autosep2.bin \
	$(PREFIX1).autogen.bin	\
	$(PREFIX1).autopgen.bin	\
	$(PREFIX1).t1x.bin	\
	$(PREFIX1b).t1x.bin	\
	$(PREFIX1).t1x			\
	$(PREFIX1b).t1x			\
	$(PREFIX1).t2ax.bin	\
	$(PREFIX1).t2bx.bin	\
	$(PREFIX1).t2cx.bin	\
	$(PREFIX1b).t2cx.bin	\
	$(PREFIX1).t2cx			\
	$(PREFIX1b).t2cx			\
	$(PREFIX1).t2dx.bin	\
	$(PREFIX1).t2ex.bin	\
	$(PREFIX1).t3x.bin	\
	$(PREFIX1).t4x.bin	\
	$(PREFIX1b).t4x.bin	\
	$(PREFIX1).t4x			\
	$(PREFIX1b).t4x			\
	$(PREFIX2).automorf.bin	\
	$(PREFIX2b).automorf.bin	\
	$(PREFIX2).prob		\
	$(PREFIX2).rlx.bin	\
	$(PREFIX2).autobil.bin	\
	$(PREFIX2b).autobil.bin	\
	$(PREFIX2).autolex.bin	\
	$(PREFIX2b).autolex.bin	\
	$(PREFIX2).autogen.bin	\
	$(PREFIX2b).autogen.bin	\
	$(PREFIX2).autoprepgen.bin	\
	$(PREFIX2).autopgen.bin	\
	$(PREFIX2b).autopgen.bin	\
	$(PREFIX2).t1x.bin	\
	$(PREFIX2b).t1x.bin	\
	$(PREFIX2).t1x			\
	$(PREFIX2b).t1x			\
	$(PREFIX2).t2x.bin	\
	$(PREFIX2b).t2x.bin	\
	$(PREFIX2).t2x	\
	$(PREFIX2b).t2x	\
	$(PREFIX2).t2x_bis.bin	\
	$(PREFIX2b).t2x_bis.bin	\
	$(PREFIX2).t2x_bis	\
	$(PREFIX2b).t2x_bis	\
	$(PREFIX2).t2x_pas.bin	\
	$(PREFIX2).t2x_pro.bin	\
	$(PREFIX2b).t2x_supersn.bin	\
	$(PREFIX2b).t2x_enon.bin	\
	$(PREFIX2).t3x.bin	\
	$(PREFIX2).t4x.bin


# This include defines goals for install-modes, .deps/.d and .mode files:
@ap_include@

###############################################################################
## Monolingual transducers
###############################################################################

# -------------------
# Occitan analysis:
# -------------------

$(PREFIX1).automorf.bin: $(AP_SRC1)/$(LANG1).automorf.bin $(PREFIX1).autobil.bin
	lt-trim $^ $@

$(PREFIX1b).automorf.bin: $(AP_SRC1)/$(LANG1b).automorf.bin $(PREFIX1b).autobil.bin
	lt-trim $^ $@

# -------------------
# Occitan generation:
# ---------------------


$(PREFIX2).autogen.bin: $(AP_SRC1)/$(LANG1).autogen.bin
	cp $< $@

$(PREFIX2b).autogen.bin: $(AP_SRC1)/$(LANG1b).autogen.bin
	cp $< $@

# -------------------
# French analysis:
# -------------------

$(PREFIX2).automorf.bin: $(AP_SRC2)/$(LANG2).automorf.bin $(PREFIX2).autobil.bin
	lt-trim $^ $@

$(PREFIX2b).automorf.bin: $(AP_SRC2)/$(LANG2).automorf.bin $(PREFIX2b).autobil.bin
	lt-trim $^ $@

# -------------------
# French generation:
# ---------------------


$(PREFIX1).autogen.bin: $(AP_SRC2)/$(LANG2).autogen.bin
	cp $< $@

###############################################################################
## Multiwords
###############################################################################

$(PREFIX1).autosep1.bin: $(BASENAME).$(PREFIX1).l1x
	lsx-comp lr $< $@
$(PREFIX1).autosep2.bin: $(BASENAME).$(PREFIX1).l2x
	lsx-comp lr $< $@

$(PREFIX2).autosep1.bin: $(BASENAME).$(PREFIX2).l1x
	lsx-comp lr $< $@
$(PREFIX2).autosep2.bin: $(BASENAME).$(PREFIX2).l2x
	lsx-comp lr $< $@

###############################################################################
## Tagger models
###############################################################################

$(PREFIX1).prob: $(AP_SRC1)/$(LANG1).prob
	cp $< $@

$(PREFIX2).prob: $(AP_SRC2)/$(LANG2).prob
	cp $< $@

###############################################################################
## Disambiguation rules
###############################################################################

$(PREFIX1).rlx.bin: $(AP_SRC1)/apertium-$(LANG1).$(LANG1).rlx
	cg-comp $< $@

$(PREFIX2).rlx.bin: $(AP_SRC2)/apertium-$(LANG2).$(LANG2).rlx
	cg-comp $< $@

###############################################################################
## Bilingual dictionaries
###############################################################################

.deps/$(PREFIX2).dix: $(BASENAME).$(PREFIX1).dix .deps/.d
	xsltproc --stringparam alt $(LANG1) alt.xsl $(BASENAME).$(PREFIX1).dix >$@

.deps/$(PREFIX2b).dix: $(BASENAME).$(PREFIX1).dix .deps/.d
	xsltproc --stringparam alt $(LANG1b) alt.xsl $(BASENAME).$(PREFIX1).dix >$@

$(PREFIX1).autobil.bin: .deps/$(PREFIX2).dix .deps/.d
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX1b).autobil.bin: .deps/$(PREFIX2b).dix .deps/.d
	apertium-validate-dictionary $<
	lt-comp lr $< $@

$(PREFIX2).autobil.bin: .deps/$(PREFIX2).dix .deps/.d
	apertium-validate-dictionary $<
	lt-comp rl $< $@

$(PREFIX2b).autobil.bin: .deps/$(PREFIX2b).dix .deps/.d
	apertium-validate-dictionary $<
	lt-comp rl $< $@

###############################################################################
## Lexical selection rules
###############################################################################

.deps/$(PREFIX1).ini.metalrx: $(BASENAME).$(PREFIX1).metalrx .deps/.d
	apertium-filter-rules oci $(BASENAME).$(PREFIX1).metalrx >$@

.deps/$(PREFIX1b).ini.metalrx: $(BASENAME).$(PREFIX1).metalrx .deps/.d
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX1).metalrx >$@

.deps/$(PREFIX2).ini.metalrx: $(BASENAME).$(PREFIX2).metalrx .deps/.d
	apertium-filter-rules oci $(BASENAME).$(PREFIX2).metalrx >$@

.deps/$(PREFIX2b).ini.metalrx: $(BASENAME).$(PREFIX2).metalrx .deps/.d
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX2).metalrx >$@

.deps/%.lrx: .deps/%.ini.metalrx .deps/.d
	apertium-metalrx $< $@

$(PREFIX1).autolex.bin: .deps/$(PREFIX1).lrx
	lrx-comp $< $@

$(PREFIX1b).autolex.bin: .deps/$(PREFIX1b).lrx
	lrx-comp $< $@

$(PREFIX2).autolex.bin: .deps/$(PREFIX2).lrx
	lrx-comp $< $@

$(PREFIX2b).autolex.bin: .deps/$(PREFIX2b).lrx
	lrx-comp $< $@

###############################################################################
## Structural transfer rules
###############################################################################

$(PREFIX1).t1x: $(BASENAME).$(PREFIX1).t1x
	apertium-filter-rules oci $(BASENAME).$(PREFIX1).t1x >$@

$(PREFIX1b).t1x: $(BASENAME).$(PREFIX1).t1x
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX1).t1x >$@

$(PREFIX1).t1x.bin: $(PREFIX1).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX1b).t1x.bin: $(PREFIX1b).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t2ax.bin: $(BASENAME).$(PREFIX1).t2ax
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t2bx.bin: $(BASENAME).$(PREFIX1).t2bx
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t2cx: $(BASENAME).$(PREFIX1).t2cx
	apertium-filter-rules oci $(BASENAME).$(PREFIX1).t2cx >$@

$(PREFIX1b).t2cx: $(BASENAME).$(PREFIX1).t2cx
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX1).t2cx >$@

$(PREFIX1).t2cx.bin: $(PREFIX1).t2cx
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1b).t2cx.bin: $(PREFIX1b).t2cx
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t2dx.bin: $(BASENAME).$(PREFIX1).t2dx
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t2ex.bin: $(BASENAME).$(PREFIX1).t2ex
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t3x.bin: $(BASENAME).$(PREFIX1).t3x
	apertium-validate-postchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t4x: $(BASENAME).$(PREFIX1).t4x
	apertium-filter-rules oci $(BASENAME).$(PREFIX1).t4x >$@

$(PREFIX1b).t4x: $(BASENAME).$(PREFIX1).t4x
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX1).t4x >$@

$(PREFIX1).t4x.bin: $(PREFIX1).t4x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX1b).t4x.bin: $(PREFIX1b).t4x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t1x: $(BASENAME).$(PREFIX2).t1x
	apertium-filter-rules oci $(BASENAME).$(PREFIX2).t1x >$@

$(PREFIX2b).t1x: $(BASENAME).$(PREFIX2).t1x
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX2).t1x >$@

$(PREFIX2).t1x.bin: $(PREFIX2).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX2b).t1x.bin: $(PREFIX2b).t1x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t2x: $(BASENAME).$(PREFIX2).t2x
	apertium-filter-rules oci $(BASENAME).$(PREFIX2).t2x >$@

$(PREFIX2b).t2x: $(BASENAME).$(PREFIX2).t2x
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX2).t2x >$@

$(PREFIX2).t2x.bin: $(PREFIX2).t2x
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2b).t2x.bin: $(PREFIX2b).t2x
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t2x_bis: $(BASENAME).$(PREFIX2).t2x_bis
	apertium-filter-rules oci $(BASENAME).$(PREFIX2).t2x_bis >$@

$(PREFIX2b).t2x_bis: $(BASENAME).$(PREFIX2).t2x_bis
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX2).t2x_bis >$@

$(PREFIX2).t2x_bis.bin: $(PREFIX2).t2x_bis
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2b).t2x_bis.bin: $(PREFIX2b).t2x_bis
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t2x_pas.bin: $(BASENAME).$(PREFIX2).t2x_pas
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t2x_pro.bin: $(BASENAME).$(PREFIX2).t2x_pro
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2b).t2x_supersn.bin: $(BASENAME).$(PREFIX2).t2x_supersn
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2b).t2x_enon.bin: $(BASENAME).$(PREFIX2).t2x_enon
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t3x.bin: $(BASENAME).$(PREFIX2).t3x
	apertium-validate-postchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX2).t4x.bin: $(BASENAME).$(PREFIX2).t4x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

###############################################################################
## Postgeneration dictionaries
###############################################################################

$(PREFIX2).autoprepgen.bin: $(AP_SRC1)/$(LANG1).autoprepgen.bin
	cp $< $@

$(PREFIX1).autopgen.bin: $(AP_SRC2)/$(LANG2).autopgen.bin
	cp $< $@

$(PREFIX2).autopgen.bin: $(AP_SRC1)/$(LANG1).autopgen.bin
	cp $< $@

$(PREFIX2b).autopgen.bin: $(AP_SRC1)/$(LANG1b).autopgen.bin
	cp $< $@

###############################################################################
## Distribution
###############################################################################

EXTRA_DIST=					\
		$(BASENAME).$(PREFIX1).dix	\
		$(BASENAME).$(PREFIX1).l1x	\
		$(BASENAME).$(PREFIX1).l2x	\
		.deps/$(BASENAME).$(PREFIX1).lrx	\
		.deps/$(BASENAME).$(PREFIX1b).lrx	\
		.deps/$(BASENAME).$(PREFIX2).lrx	\
		.deps/$(BASENAME).$(PREFIX2b).lrx	\
		$(BASENAME).$(PREFIX1).t1x	\
		$(BASENAME).$(PREFIX1).t2ax	\
		$(BASENAME).$(PREFIX1).t2bx	\
		$(BASENAME).$(PREFIX1).t2cx	\
		$(BASENAME).$(PREFIX1).t2dx	\
		$(BASENAME).$(PREFIX1).t2ex	\
		$(BASENAME).$(PREFIX1).t3x	\
		$(BASENAME).$(PREFIX1).t4x	\
		$(BASENAME).$(PREFIX2).t1x	\
		$(BASENAME).$(PREFIX2).t2x	\
		$(BASENAME).$(PREFIX2).t2x_bis	\
		$(BASENAME).$(PREFIX2).t2x_pas	\
		$(BASENAME).$(PREFIX2).t2x_pro	\
		$(BASENAME).$(PREFIX2).t2x_supersn	\
		$(BASENAME).$(PREFIX2).t2x_enon	\
		$(BASENAME).$(PREFIX2).t3x	\
		$(BASENAME).$(PREFIX2).t4x	\
		modes.xml \
		alt.xsl

###############################################################################
## Installation
###############################################################################

apertium_oci_fradir=$(prefix)/share/apertium/$(BASENAME)/

# Files which should be installed to $(prefix)/share/apertium/$(BASENAME)/:
apertium_oci_fra_DATA=	\
	$(TARGETS_COMMON)				\
	$(BASENAME).$(PREFIX1).t1x			\
	$(BASENAME).$(PREFIX1).t2ax			\
	$(BASENAME).$(PREFIX1).t2bx			\
	$(BASENAME).$(PREFIX1).t2cx			\
	$(BASENAME).$(PREFIX1).t2dx			\
	$(BASENAME).$(PREFIX1).t2ex			\
	$(BASENAME).$(PREFIX1).t3x			\
	$(BASENAME).$(PREFIX1).t4x			\
	$(BASENAME).$(PREFIX2).t1x			\
	$(BASENAME).$(PREFIX2).t2x			\
	$(BASENAME).$(PREFIX2).t2x_bis			\
	$(BASENAME).$(PREFIX2).t2x_pas			\
	$(BASENAME).$(PREFIX2).t2x_pro			\
	$(BASENAME).$(PREFIX2).t2x_supersn			\
	$(BASENAME).$(PREFIX2).t2x_enon			\
	$(BASENAME).$(PREFIX2).t3x			\
	$(BASENAME).$(PREFIX2).t4x

# All modes are created by the same goal, listing several will just give problems with make -j2
noinst_DATA=modes/$(PREFIX1).mode

install-data-local: install-modes

###############################################################################
## Cleanup
###############################################################################

CLEANFILES = $(TARGETS_COMMON)
clean-local:
	-rm -rf .deps modes

###############################################################################
## Test
###############################################################################

test: all
	apertium-regtest test
