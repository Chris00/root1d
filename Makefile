WEB = shell.forge.ocamlcore.org:/home/groups/optimization1d/htdocs

PKGNAME = $(shell oasis query name)
PKGVERSION = $(shell oasis query version)
PKG_TARBALL = $(PKGNAME)-$(PKGVERSION).tar.gz

DISTFILES = AUTHORS.txt INSTALL.txt README.txt _oasis _tags myocamlbuild.ml \
  setup.ml Makefile src/META src/API.odocl \
  $(wildcard $(addprefix src/, *.ml *.mli *.mllib *.mlpack *.ab)) \
  $(wildcard tests/*.ml tests/*.ab)  $(wildcard examples/*.ml)

.PHONY: all byte native configure doc install uninstall reinstall upload-doc

all byte native: configure
	ocaml setup.ml -build

configure: setup.data
setup.data: setup.ml
	ocaml $< -configure

setup.ml: _oasis
	oasis.dev setup

doc install uninstall reinstall: all
	ocaml setup.ml -$@

upload-doc: doc
	scp -C -r _build/src/API.docdir/ $(WEB)/

# Make a tarball
.PHONY: dist tar
dist tar: $(DISTFILES)
	mkdir $(PKGNAME)-$(PKGVERSION)
	cp --parents -r $(DISTFILES) $(PKGNAME)-$(PKGVERSION)/
	tar -zcvf $(PKG_TARBALL) $(PKGNAME)-$(PKGVERSION)
	$(RM) -rf $(PKGNAME)-$(PKGVERSION)

.PHONY: clean distclean dist-clean
clean:
	ocaml setup.ml -clean
	$(RM) $(PKG_TARBALL)
	$(RM) $(wildcard *~ *.pdf *.ps *.png *.svg) setup.data

distclean dist-clean::
	ocaml setup.ml -distclean
	$(RM) $(wildcard *.ba[0-9] *.bak *~ *.odocl) setup.log
