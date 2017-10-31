/*-
 * Copyright (c) 2015 Erasmo Marín <erasmo.marin@gmail.com>
 * Copyright (c) 2017-2017 Artem Anufrij <artem.anufrij@live.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * The Noise authors hereby grant permission for non-GPL compatible
 * GStreamer plugins to be used and distributed together with GStreamer
 * and Noise. This permission is above and beyond the permissions granted
 * by the GPL license by which Noise is covered. If you modify this code
 * you may extend this exception to your version of the code, but you are not
 * obligated to do so. If you do not wish to do so, delete this exception
 * statement from your version.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

namespace Webpin {
    public class WebApp : Gtk.Stack {

        public WebKit.WebView app_view;
        public string ui_color = "none";
        private string app_url;
        private GLib.DesktopAppInfo info;
        private DesktopFile file;
        private WebKit.CookieManager cookie_manager;
        private Gtk.Box container;
        Granite.Widgets.Toast app_notification;
        GLib.Icon icon_for_notification;

        public signal void external_request (WebKit.NavigationAction action);
        public signal void request_begin ();
        public signal void request_finished ();
        public signal void desktop_notification (string title, string body, GLib.Icon icon);


        public WebApp (string app_url) {

            this.app_url = app_url;

            //configure cookies settings
            cookie_manager = WebKit.WebContext.get_default ().get_cookie_manager ();
            cookie_manager.set_accept_policy (WebKit.CookieAcceptPolicy.ALWAYS);

            string cookie_db = Environment.get_user_cache_dir () + "/webpin/cookies/";

            var dir = GLib.File.new_for_path (cookie_db);

            if (!dir.query_exists (null)) {
                try {
                    dir.make_directory_with_parents (null);
                    GLib.debug ("Directory '%s' created", dir.get_path ());
                } catch (Error e) {
                    GLib.error ("Could not create caching directory.");
                }
            }

            cookie_manager.set_persistent_storage (cookie_db + "cookies.db", WebKit.CookiePersistentStorage.SQLITE);

            //load app viewer
            app_view = new WebKit.WebView.with_context (WebKit.WebContext.get_default ());
            app_view.load_uri (app_url);

            container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            container.halign = Gtk.Align.FILL;
            container.valign = Gtk.Align.FILL;

            app_notification = new Granite.Widgets.Toast ("");

            //overlay trick to make snapshot work even with the spinner
            var overlay = new Gtk.Overlay ();
            overlay.add (app_view);
            overlay.add_overlay (app_notification);

            add_named (container, "splash");
            add_named (overlay, "app");

            transition_duration = 350;
            transition_type = Gtk.StackTransitionType.SLIDE_UP;

            app_view.create.connect ((action) => {
                print("external request");
                app_notification.title = _("Open request in an external application…");
                app_notification.send_notification ();

                external_request (action);
                return new WebKit.WebView ();
            });

            info = DesktopFile.get_app_by_url(app_url);
            file = new DesktopFile.from_desktopappinfo(info);

            var icon_file = File.new_for_path (file.icon);

            Gtk.Image icon;
            if (icon_file.query_exists ()) {
                try {
                    icon = new Gtk.Image.from_pixbuf (new Gdk.Pixbuf.from_file_at_scale (file.icon, 48, 48, true));
                    icon_for_notification = GLib.Icon.new_for_string (file.icon);
                } catch (Error e) {
                    warning (e.message);
                    icon = new Gtk.Image.from_icon_name ("artemanufrij.webpin", Gtk.IconSize.DIALOG);
                }
            } else {
                icon = new Gtk.Image.from_icon_name (file.icon, Gtk.IconSize.DIALOG);
                icon_for_notification = new GLib.ThemedIcon (file.icon);
            }
            container.pack_start(icon, true, true, 0);

            Gdk.RGBA background = {};
            if (!background.parse (ui_color)){
                background = {1,1,1,1};
            }
            container.override_background_color (Gtk.StateFlags.NORMAL, background);

            app_view.load_changed.connect ( (load_event) => {
                request_begin ();
                if (load_event == WebKit.LoadEvent.FINISHED) {
                    visible_child_name = "app";
                    
                    // TODO: Hier Logik für Favicon einfügen.
                    // https://valadoc.org/webkit2gtk-4.0/WebKit.WebView.save.html
                    // https://wiki.gnome.org/Projects/Vala/Tutorial#Asynchronous_Methods
                    
                    if (app_notification.reveal_child) {
                        app_notification.reveal_child = false;
                    }
                    
                    var pathfile = File.new_for_path ("/home/snowparrot/Dokumente/test.html");
                    app_view.save_to_file (pathfile, WebKit.SaveMode.MHTML, null);
                    
                    
                    request_finished ();
                }
            });

            app_view.show_notification.connect ((notification) => {
                desktop_notification (notification.title, notification.body, icon_for_notification);
                return true;
            });

            app_view.permission_request.connect ((permission) => {
                var permission_type = permission as WebKit.NotificationPermissionRequest;
                if (permission_type != null) {
                    permission_type.allow ();
                }
                return false;
            });
        }

        public DesktopFile get_desktop_file () {
            return this.file;
        }
    }
}
