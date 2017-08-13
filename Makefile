# This Makefile is intended for developers.  Users simply use OASIS.
WEB = san@math.umons.ac.be:public_html/software

PKGVERSION = $(shell git describe --always --dirty)

DISTFILES = README.md CHANGES.md LICENSE.md Makefile src/META src/API.odocl \
  $(wildcard $(addprefix src/, *.ml *.mli *.mllib *.mlpack *.ab)) \
  $(wildcard tests/*.ml tests/*.ab)  $(wildcard examples/*.ml)

.PHONY: all build byte native test runtest doc install uninstall upload-doc lint

all build byte native:
	jbuilder build @install #--dev

test runtest:
# Force the tests to be run
	$(RM) -rf _build/default/tests/
	jbuilder runtest

install uninstall:
	jbuilder $@

doc:
	sed -e 's/%%VERSION%%/$(PKGVERSION)/' src/Root1D.mli \
	  > _build/default/src/Root1D.mli
	jbuilder build @doc
	echo '.def { background: #f9f9de; }' >> _build/default/_doc/odoc.css

upload-doc: doc
	scp -C -r _build/default/_doc/root1d/Root1D $(WEB)/doc
	scp -C _build/default/_doc/odoc.css $(WEB)/

lint:
	opam lint root1d.opam

# Make a tarball
.PHONY: dist tar
dist tar: $(DISTFILES)
	mkdir $(PKGNAME)-$(PKGVERSION)
	cp --parents -r $(DISTFILES) $(PKGNAME)-$(PKGVERSION)/
#	setup.ml independent of oasis:
	cd $(PKGNAME)-$(PKGVERSION) && oasis setup
	tar -zcvf $(PKG_TARBALL) $(PKGNAME)-$(PKGVERSION)
	$(RM) -rf $(PKGNAME)-$(PKGVERSION)

.PHONY: clean distclean dist-clean
clean:
	jbuilder clean
	$(RM) $(PKG_TARBALL)
	$(RM) $(wildcard *~ *.pdf *.ps *.png *.svg)

distclean dist-clean:: clean
	ocaml setup.ml -distclean
	$(RM) $(wildcard *.ba[0-9] *.bak *~ *.odocl)
