"""
This module is just a convenient place to group re-usable functions.
.
"""
# Font Manager, a font management application for the GNOME desktop
#
# Copyright (C) 2009, 2010 Jerry Casiano
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to: Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
# Suppress errors related to gettext
# pylint: disable-msg=E0602
# Suppress messages related to missing docstrings
# pylint: disable-msg=C0111

import os
import re
import gtk
import subprocess

from os.path import exists, join

from config import USER_FONT_DIR, HOME, PACKAGE_DIR, AUTOSTART_DIR


README = \
_("""* This file was placed here by Font Manager because this directory
did not exist, feel free to delete, it will not be generated again.


This is a per-user font directory.


Any fonts ( or folders containing fonts ) present in this directory are
automatically picked up by the system and available, but only to you.


Please note that not only can you specify other directories to scan for
fonts from the applications preferences dialog, but you can also set the
default folder that's opened when 'Open fonts folder' is selected.


If you wish to make fonts available to everyone using the system they will
need to be placed in /usr/share/fonts

""")

STARTME = \
_("""[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=Font Manager
Name[en_US]=Font Manager
Comment=Preview, compare and manage fonts
Type=Application
Exec=font-manager
Terminal=false
StartupNotify=false
Icon=preferences-desktop-font
Categories=Graphics;Viewer;GNOME;GTK;Publishing;
""")


class Throbber:
    """
    A simple throbber to provide some visual feedback
    """
    pixbuf = None
    def __init__(self, builder):
        self.builder = builder
        self.throbber = self.builder.get_object("throbber")
        self.refresh = self.builder.get_object('refresh')
        self.animation = \
        gtk.gdk.PixbufAnimation(join(PACKAGE_DIR, 'ui/Throbber.gif'))
        self.pixbuf = \
        gtk.gdk.pixbuf_new_from_file(join(PACKAGE_DIR , 'ui/Throbber.png'))

    def start(self):
        # Start animation
        self.refresh.hide()
        self.throbber.show()
        self.throbber.set_from_animation(self.animation)
        while gtk.events_pending():
            gtk.main_iteration()
        return

    def stop(self):
        self.throbber.set_from_pixbuf(self.pixbuf)
        self.throbber.hide()
        self.refresh.show()
        while gtk.events_pending():
            gtk.main_iteration()
        return


def have_bin(bin):
    """
    Returns if a program exists in /usr/bin or /usr/local/bin
    """
    return (exists('/usr/bin/%s' % bin) or exists('/usr/local/bin/%s' % bin))

def natural_sort(l):
    """
    Sort the given list in the way that humans expect
    """
    alphanum = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    l.sort( key=alphanum )
    return l

def convert(t):
    """
    Make sure certain characters don't affect sort order

    So that a doesn't end up under a-a for example.
    """
    if t.isdigit():
        return int(t)
    else:
        t = t.replace('-', '')
        t = t.replace('_', '')
        return t.upper()

def reset_fontconfig_cache():
    """
    Clears all fontconfig cache files in users home directory
    """
    fc_dir = join(HOME, '.fontconfig')
    if exists(fc_dir):
        for path in os.listdir(fc_dir):
            if path.endswith('cache-2'):
                os.unlink(join(fc_dir, path))
    return

def match(model, treeiter, data):
    """
    Tries to match a value with those in the given treemodel
    """
    column, key = data
    value = model.get_value(treeiter, column)
    return value == key

def search(model, treeiter, func, data):
    """
    Used in combination with match to find a particular value in a
    gtk.ListStore or gtk.TreeStore.

    Usage:
    search(liststore, liststore.iter_children(None), match, ('index', 'foo'))
    """
    while treeiter:
        if func(model, treeiter, data):
            return treeiter
        result = search(model, model.iter_children(treeiter), func, data)
        if result:
            return result
        treeiter = model.iter_next(treeiter)
    return None

def shell_escape(data):
    """
    Escape or remove special shell characters
    """
    special = {
    "'" : "\'",
    '"' : '\"',
    '/' : ' ',
    '$' : '\$',
    ',' : '\,'
    }
    for normal, escaped in special.iteritems():
        if data.find(normal) > 0:
            data = data.replace(normal, escaped)
    return data

def xml_escape(data):
    """
    Replaces characters that are illegal or discouraged in xml
    with a proper escape sequence.
    """
    entities = {
    '<' : '&lt;',
    '>' : '&gt;',
    "'" : "&apos;",
    '"' : '&quot;'
    }
    data = data.replace('&', '&amp;')
    for illegal, legal in entities.iteritems():
        if data.find(illegal) > 0:
            data = data.replace(illegal, legal)
    return data

def strip_fc_family(family):
    """
    Remove alt name, get rid of escape characters
    """
    comma = family.find(',')
    if comma > 0:
        family = family[:comma]
    family = family.replace("\\", "")
    #family = family.strip()
    return family

def get_cli_output(cmd):
    """
    os.popen is deprecated.

    This replaces os.popen(cmd).readline()
    """
    result = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, shell=True)
    output = result.communicate()[0].split('\n')
    for line in output:
        if not line:
            break
        yield line
    return

def install_readme():
    """
    Install a readme into ~/.fonts if it didn't previously exist

    Really just intended for users new to linux ;-)
    """
    with open(join(USER_FONT_DIR, 'Read Me.txt'), 'w') as readme:
        readme.write(README)
    return

def autostart(startme=True):
    """
    Install or remove a .desktop file when requested
    """
    if startme:
        if not exists(AUTOSTART_DIR):
            os.makedirs(AUTOSTART_DIR, 0744)
        with open\
        (join(AUTOSTART_DIR, 'font-manager.desktop'), 'w') as startup:
            startup.write(STARTME)
    else:
        if exists(join(AUTOSTART_DIR, 'font-manager.desktop')):
            os.unlink(join(AUTOSTART_DIR, 'font-manager.desktop'))
    return
