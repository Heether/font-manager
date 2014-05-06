/* CompareControls.vala
 *
 * Copyright © 2009 - 2014 Jerry Casiano
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Jerry Casiano <JerryCasiano@gmail.com>
 */

namespace FontManager {

    public class CompareControls : Gtk.EventBox {

        public signal void add_selected ();
        public signal void remove_selected ();
        public signal void foreground_set (Gdk.RGBA fg_color);
        public signal void background_set (Gdk.RGBA bg_color);

        public Gtk.ColorButton fg_color_button { get; set; }
        public Gtk.ColorButton bg_color_button { get; set; }

        Gtk.Button add_compare;
        Gtk.Button remove_compare;

        construct {
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.border_width = 2;
            add_compare = new Gtk.Button();
            add_compare.set_image(new Gtk.Image.from_icon_name("list-add-symbolic", Gtk.IconSize.MENU));
            add_compare.set_tooltip_text("Add selected font to comparison");
            remove_compare = new Gtk.Button();
            remove_compare.set_image(new Gtk.Image.from_icon_name("list-remove-symbolic", Gtk.IconSize.MENU));
            remove_compare.set_tooltip_text("Remove selected font from comparison");
            var context = get_style_context();
            fg_color_button = new Gtk.ColorButton.with_rgba(context.get_color(Gtk.StateFlags.NORMAL));
            bg_color_button = new Gtk.ColorButton.with_rgba(context.get_background_color(Gtk.StateFlags.NORMAL));
            fg_color_button.get_style_context().add_class(Gtk.STYLE_CLASS_ENTRY);
            fg_color_button.set_tooltip_text("Select text color");
            bg_color_button.get_style_context().add_class(Gtk.STYLE_CLASS_ENTRY);
            bg_color_button.set_tooltip_text("Select background color");
            box.pack_start(add_compare, false, false, 0);
            box.pack_start(remove_compare, false, false, 0);
            box.pack_end(bg_color_button, false, false, 0);
            box.pack_end(fg_color_button, false, false, 0);
            set_default_button_relief(box);
            box.show_all();
            add(box);
            connect_signals();
        }

        internal void connect_signals () {
            add_compare.clicked.connect((w) => { add_selected(); });
            remove_compare.clicked.connect(() => { remove_selected(); });
            fg_color_button.color_set.connect((w) => { foreground_set(w.get_rgba()); });
            bg_color_button.color_set.connect((w) => { background_set(w.get_rgba()); });
            return;
        }

    }

}