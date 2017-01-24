man_MANS = bibledit.1

applicationdir = $(datadir)/applications
application_DATA = bibledit.desktop

appicondir = $(datadir)/pixmaps
appicon_DATA = bibledit.xpm

install-data-hook:
	rsync --archive -v --delete --exclude "*.h" --exclude "*.c" --exclude "*.cpp" --exclude "*.o" --exclude "*.deps*" --exclude "*autom4te.cache*" --exclude ".dirstamp" --exclude ".DS_Store"  $(srcdir) $(DESTDIR)$(pkgdatadir)

uninstall-local:
	rm -rf $(DESTDIR)$(pkgdatadir)/*

