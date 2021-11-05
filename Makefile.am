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
	$(PREFIX1).autogen.bin	\
	$(PREFIX1).autopgen.bin	\
	$(PREFIX1).t1x.bin	\
	$(PREFIX1b).t1x.bin	\
	$(PREFIX1).t2ax.bin	\
	$(PREFIX1).t2bx.bin	\
	$(PREFIX1).t2cx.bin	\
	$(PREFIX1).t3x.bin	\
	$(PREFIX1).t4x.bin	\
	$(PREFIX1b).t4x.bin	\
	$(PREFIX2).automorf.bin	\
	$(PREFIX2b).automorf.bin	\
	$(PREFIX2).prob		\
	$(PREFIX2).rlx.bin	\
	$(PREFIX2).autobil.bin	\
	$(PREFIX2b).autobil.bin	\
	$(PREFIX2).autolex.bin	\
	$(PREFIX2).autogen.bin	\
	$(PREFIX2b).autogen.bin	\
	$(PREFIX2).autoprepgen.bin	\
	$(PREFIX2).autopgen.bin	\
	$(PREFIX2b).autopgen.bin	\
	$(PREFIX2).t1x.bin	\
	$(PREFIX2b).t1x.bin	\
	$(PREFIX2).t2x.bin	\
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

.deps/%.metalrx: %.metalrx .deps/.d
	apertium-metalrx $< $@

.deps/%.lrx: .deps/%.metalrx
	apertium-metalrx-to-lrx $< $@

$(PREFIX1).autolex.bin: .deps/$(BASENAME).$(PREFIX1).lrx
	lrx-comp $< $@

$(PREFIX2).autolex.bin: .deps/$(BASENAME).$(PREFIX2).lrx
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

$(PREFIX1).t2cx.bin: $(BASENAME).$(PREFIX1).t2cx
	apertium-validate-interchunk $<
	apertium-preprocess-transfer $< $@

$(PREFIX1).t3x.bin: $(BASENAME).$(PREFIX1).t3x
	apertium-validate-postchunk $<
	apertium-preprocess-transfer $< $@

.deps/$(PREFIX1).t4x: $(BASENAME).$(PREFIX1).t4x
	apertium-filter-rules oci $(BASENAME).$(PREFIX1).t4x >$@

.deps/$(PREFIX1b).t4x: $(BASENAME).$(PREFIX1).t4x
	apertium-filter-rules oci@gascon $(BASENAME).$(PREFIX1).t4x >$@

$(PREFIX1).t4x.bin: .deps/$(PREFIX1).t4x
	apertium-validate-transfer $<
	apertium-preprocess-transfer $< $@

$(PREFIX1b).t4x.bin: .deps/$(PREFIX1b).t4x
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

$(PREFIX2).t2x.bin: $(BASENAME).$(PREFIX2).t2x
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
		.deps/$(BASENAME).$(PREFIX1).lrx	\
		$(BASENAME).$(PREFIX1).dix	\
		.deps/$(BASENAME).$(PREFIX2).lrx	\
		$(BASENAME).$(PREFIX1).t1x	\
		$(BASENAME).$(PREFIX1).t2ax	\
		$(BASENAME).$(PREFIX1).t2bx	\
		$(BASENAME).$(PREFIX1).t2cx	\
		$(BASENAME).$(PREFIX1).t3x	\
		$(BASENAME).$(PREFIX1).t4x	\
		$(BASENAME).$(PREFIX2).t1x	\
		$(BASENAME).$(PREFIX2).t2x	\
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
	$(BASENAME).$(PREFIX1).t3x			\
	$(BASENAME).$(PREFIX1).t4x			\
	$(BASENAME).$(PREFIX2).t1x			\
	$(BASENAME).$(PREFIX2).t2x			\
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
