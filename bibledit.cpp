/*
** Copyright (©) 2003-2015 Teus Benschop.
**  
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 3 of the License, or
** (at your option) any later version.
**  
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**  
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
**  
*/


#include <config.h>
#include <executable/bibledit.h>
#include <libgen.h>
#include <iostream>
#include "library/bibledit.h"
#include <webkit2/webkit2.h>


int main (int argc, char *argv[])
{
  application = gtk_application_new ("org.bibledit.linux", G_APPLICATION_FLAGS_NONE);

  g_signal_connect (application, "activate", G_CALLBACK (activate), NULL);

  // Derive the webroot from the $HOME environment variable.
  string webroot;
  const char * home = g_getenv ("HOME");
  if (home) webroot = home;
  if (!webroot.empty ()) webroot.append ("/");
  webroot.append ("bibledit");
  
  // Read the package directory from config.h.
  
  // The $make install will copy the relevant files to /usr/share/bibledit.
  // That is the package data directory.
  // Bibledit will then copy this to the webroot upon first run for a certain version number.
  bibledit_initialize_library (PACKAGE_DATA_DIR, webroot.c_str());
  // In case the app is installed from source, through the "install.sh" script,
  // on first run it will try to copy the package data from /usr/share/bibledit,
  // find nothing there, and continue normally.
  // This will work when the app is unpacked in folder ~/bibledit.
  
  bibledit_start_library ();

  status = g_application_run (G_APPLICATION (application), argc, argv);

  g_object_unref (application);
  
  bibledit_stop_library ();

  while (bibledit_is_running ()) { };
  
  bibledit_shutdown_library ();

  return status;
}


void activate (GtkApplication *app)
{
  GList *list = gtk_application_get_windows (app);

  if (list) {
    // Activate existing live app.
    gtk_window_present (GTK_WINDOW (list->data));
    return;
  }

  // The top-level window.
  window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  gtk_window_set_title (GTK_WINDOW (window), "Bibledit");
  gtk_window_set_default_size (GTK_WINDOW (window), 800, 600);
  gtk_window_set_position (GTK_WINDOW (window), GTK_WIN_POS_CENTER);
  gtk_window_set_application (GTK_WINDOW (window), application);

  // The icon.
  gchar * iconfile = g_build_filename ("bibledit.xpm", NULL);
  gtk_window_set_default_icon_from_file (iconfile, NULL);
  g_free (iconfile);

  // Prepare for program quit.
  g_signal_connect (window, "destroy", G_CALLBACK (on_signal_destroy), NULL);

  // Create a browser instance.
  WebKitWebView * webview = WEBKIT_WEB_VIEW (webkit_web_view_new ());
  
  // Signal handler.
  g_signal_connect (webview, "key-press-event", G_CALLBACK (on_key_press), NULL);
  
  // Put the browser area into the main window.
  gtk_container_add (GTK_CONTAINER (window), GTK_WIDGET (webview));
  
  // Load a web page into the browser instance
  webkit_web_view_load_uri (webview, "http://localhost:8080");
  
  // Ensure it will get mouse and keyboard events.
  gtk_widget_grab_focus (GTK_WIDGET (webview));
  
  // Make sure the main window and all its contents are visible
  gtk_widget_show_all (window);

  // Run the main GTK+ event loop.
  gtk_main();
}


void on_signal_destroy (gpointer user_data)
{
  (void) user_data;
  gtk_main_quit ();
}


// Handle key presses.
gboolean on_key_press (GtkWidget *widget, GdkEvent *event, gpointer data)
{
  if (event->type == GDK_KEY_PRESS) {
    GdkEventKey * event_key = (GdkEventKey *) event;
    // The web view does not handle the keys for undo and redo of its own.
    // Handle them here.
    if ((event_key->keyval == GDK_KEY_z) || (event_key->keyval == GDK_KEY_Z)  ) {
      if (event_key->state & GDK_CONTROL_MASK) {
        const gchar *command;
        if (event_key->state & GDK_SHIFT_MASK) {
          command = WEBKIT_EDITING_COMMAND_REDO;
        } else {
          command = WEBKIT_EDITING_COMMAND_UNDO;
        }
        WebKitWebView * web_view = WEBKIT_WEB_VIEW (widget);
        webkit_web_view_execute_editing_command (web_view, command);
        // Key press handled.
        return true;
      }
    }
  }
  (void) data;
  // Key press not handled.
  return false;
}
