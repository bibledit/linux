man_MANS = bibledit.1

applicationdir = $(datadir)/applications
application_DATA = bibledit.desktop

pixmapsdir = $(datadir)/pixmaps
pixmaps_DATA = bibledit.xpm

iconsdir = $(datadir)/icons
icons_DATA = bibledit.png

install-data-hook:
	rsync --archive --delete --exclude "*.h" --exclude "*.c" --exclude "*.cpp" --exclude "*.o" --exclude "*.a" --exclude "*.deps*" --exclude "*autom4te.cache*" --exclude ".dirstamp" --exclude ".DS_Store" --exclude "bibledit" --exclude "xcode*" --exclude "unittest*" $(srcdir) $(DESTDIR)$(pkgdatadir)

uninstall-local:
	rm -rf $(DESTDIR)$(pkgdatadir)/*

