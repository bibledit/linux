man_MANS = bibledit.1

applicationdir = $(datadir)/applications
application_DATA = bibledit.desktop

pixmapsdir = $(datadir)/pixmaps
pixmaps_DATA = bibledit.xpm

iconsdir = $(datadir)/icons
icons_DATA = bibledit.png

install-data-hook:
	$(srcdir)/installdata.sh $(srcdir) $(DESTDIR) $(pkgdatadir)

uninstall-local:
	rm -rf $(DESTDIR)$(pkgdatadir)/*

