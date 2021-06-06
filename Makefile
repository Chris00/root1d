# This Makefile is intended for developers.  Users simply use dune.
PKGVERSION = $(shell git describe --always --dirty)

build byte native:
	dune build @install

test runtest: build
	dune runtest --force

install uninstall:
	dune $@

pin:
	opam pin add -k path root1d.dev .
unpin:
	opam pin remove root1d

doc:
	sed -e 's/%%VERSION%%/$(PKGVERSION)/' src/Root1D.mli \
	  > _build/default/src/Root1D.mli
	dune build @doc
	echo '.def { background: #f9f9de; }' >> _build/default/_doc/odoc.css

lint:
	opam lint root1d.opam

clean:
	dune clean
	$(RM) $(PKG_TARBALL)
	$(RM) $(wildcard *~ *.pdf *.ps *.png *.svg)

.PHONY: build byte native test runtest install uninstall pin unpin \
	doc lint clean
