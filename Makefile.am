PKGNAME=@PACKAGE_NAME@
VERSION=@PACKAGE_VERSION@

default: all

all:
	-find . -name '.svn' -exec rm -rf '{}' \;
	-find . -name '.svn' -exec rm -rf '{}' \;
	@cp -f src/ui/main.ui src/ui/main.glade
	@cp -f src/ui/preferences.ui src/ui/preferences.glade
	@cp -f src/ui/remove.ui src/ui/remove.glade
	python po/compile_translations.py
	-rm -f src/ui/*.glade
	$(MAKE) -C src
	
clean:
	$(MAKE) -C src clean
	find po -maxdepth 1 -regextype posix-basic -regex "po/[^.]*" -type d -exec rm -rf {} \;

distclean: clean
	$(MAKE) -C src distclean
	-rm -f config.log config.status Makefile

install: all
	$(MAKE) -C src install
	cp -Rf src/doc $(DESTDIR)$(prefix)/share/font-manager/
	for f in `find po -name font-manager.mo` ; do \
	  install -d -m 755 \
		`echo $$f | sed "s|^po|$(DESTDIR)$(prefix)/share/locale|" | \
		  xargs dirname` && \
	  install -m 644 $$f \
		`echo $$f | sed "s|^po|$(DESTDIR)$(prefix)/share/locale|"` ; \
	  done

uninstall:
	$(MAKE) -C src uninstall
	find $(DESTDIR)$(prefix)/share/locale -name font-manager.mo -exec rm -f {} \;

EXTRA_DIST = src/doc po src/config.py.in.in src/*.py src/font-manager.in.in\
			 src/font-manager.desktop src/Makefile.in src/Makefile.am src/ui

dist-hook:
	-find . -name '.svn' -exec rm -rf '{}' \;
	-find . -name '.svn' -exec rm -rf '{}' \;	
	@if [ -e 'src/Font Manager' ]; then mv 'src/Font Manager' 'src/FontManager.py'; fi
	-rm -f po/messages.pot
	find po -maxdepth 1 -regextype posix-basic -regex "po/[^.]*" -type d -exec rm -rf {} \;

.PHONY: check clean install uninstall