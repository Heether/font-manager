/* UserSourceList.vala
 *
 * Copyright (C) 2009 - 2015 Jerry Casiano
 *
 * This file is part of Font Manager.
 *
 * Font Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Font Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Font Manager.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *        Jerry Casiano <JerryCasiano@gmail.com>
*/

namespace FontManager {

    private const string w1 = _("Font Sources");
    private const string w2 = _("Easily add or preview fonts without actually installing them.");
    private const string w3 = _("To add a new source simply drag a folder onto this area or click the add button in the toolbar.");
    private const string welcome_tmpl = "<span size=\"xx-large\" weight=\"bold\">%s</span>\n<span size=\"large\">\n\n%s\n</span>\n\n\n<span size=\"x-large\">%s</span>";


    public class FontSourceRow : LabeledSwitch {

        public weak FontConfig.FontSource source { get; set; }

        public FontSourceRow (FontConfig.FontSource source) {
            Object(source: source);
            source.bind_property("active", toggle, "active", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
            source.bind_property("available", toggle, "sensitive", BindingFlags.SYNC_CREATE);
            source.bind_property("icon-name", image, "icon-name", BindingFlags.SYNC_CREATE);
            source.bind_property("name", label, "label", BindingFlags.SYNC_CREATE);
        }

    }

    public class UserSourceList : Gtk.Overlay {

        public weak FontConfig.Sources sources {
            get {
                return _sources;
            }
            set {
                _sources = value;
                if (initial_call) {
                    foreach (var s in _sources) {
                        var w = new FontSourceRow(s);
                        w.show();
                        list.add(w);
                    }
                    if (list.get_row_at_index(0) != null) {
                        list.select_row(list.get_row_at_index(0));
                        welcome.hide();
                    }
                }
                initial_call = false;
            }
        }

        private bool initial_call = true;
        private Gtk.ListBox list;
        private Gtk.Label welcome;
        private Gtk.ScrolledWindow scroll;
        private weak FontConfig.Sources _sources;

        construct {
            scroll = new Gtk.ScrolledWindow(null, null);
            welcome = new Gtk.Label(null);
            welcome.wrap = true;
            welcome.hexpand = true;
            welcome.valign = Gtk.Align.START;
            welcome.halign = Gtk.Align.FILL;
            welcome.justify = Gtk.Justification.CENTER;
            welcome.margin = 48;
            welcome.margin_top = 96;
            string welcome_message = welcome_tmpl.printf(w1, w2, w3);
            welcome.set_markup(welcome_message);
            welcome.set_sensitive(false);
            welcome.get_style_context().add_class(Gtk.STYLE_CLASS_VIEW);
            list = new Gtk.ListBox();
            list.get_style_context().add_class(Gtk.STYLE_CLASS_VIEW);
            scroll.add(list);
            add(scroll);
            add_overlay(welcome);
            get_style_context().add_class(Gtk.STYLE_CLASS_VIEW);
            Gtk.drag_dest_set(this, Gtk.DestDefaults.ALL, AppDragTargets, AppDragActions);
        }

        public override void show () {
            welcome.show();
            scroll.show();
            list.show();
            base.show();
            return;
        }

        public void on_add_source () {
            var new_sources = FileSelector.source_selection((Gtk.Window) this.get_toplevel());
            if (new_sources.length < 1)
                return;
            foreach (var uri in new_sources)
                add_source_from_uri(uri);
            return;
        }

        private void add_source_from_uri (string uri) {
            var file = File.new_for_uri(uri);
            var filetype = file.query_file_type(FileQueryInfoFlags.NONE);
            if (filetype != FileType.DIRECTORY && filetype != FileType.MOUNTABLE) {
                warning("Adding individual font files is not supported");
                return;
            }
            var source = new FontConfig.FontSource(file);
            _sources.add(source);
            _sources.save();
            var row = new FontSourceRow(source);
            list.add(row);
            row.show();
            debug("Added new font source : %s", source.path);
            if (welcome.visible)
                welcome.hide();
            return;
        }

        public void on_remove_source () {
            var selected_row = list.get_selected_row();
            if (selected_row == null)
                return;
            var selected_source = ((FontSourceRow) selected_row.get_child()).source;
            if (!_sources.remove(selected_source))
                return;
            _sources.save();
            list.remove(selected_row);
            debug("Removed font source : %s", selected_source.path);
            if (list.get_row_at_index(0) != null)
                welcome.hide();
            else
                welcome.show();
            return;
        }

        public override void drag_data_received (Gdk.DragContext context,
                                                    int x,
                                                    int y,
                                                    Gtk.SelectionData selection_data,
                                                    uint info,
                                                    uint time)
        {
            switch (info) {
                case DragTargetType.EXTERNAL:
                    add_sources(selection_data.get_uris());
                    break;
                default:
                    warning("Unsupported drag target.");
                    return;
            }
            return;
        }

        private void add_sources(string [] arr) {
            foreach (var uri in arr)
                add_source_from_uri(uri);
            return;
        }

    }

}
