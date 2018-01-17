applicationdir = $(datadir)/applications
application_DATA = bibledit.desktop

pixmapsdir = $(datadir)/pixmaps
pixmaps_DATA = bbe48x48.xpm bbe512x512.png

iconsdir = $(datadir)/icons
icons_DATA = bbe48x48.xpm bbe512x512.png

## It should be sufficient to put the icon for the .desktop file
## in the icons folder only,
## but a Debian package somehow did not install those.
## That is why the icon is also put in pixmaps folder.
