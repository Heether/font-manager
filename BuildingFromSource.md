# Installing Font Manager from SVN #
<br />
## Arch ##

---

See https://aur.archlinux.org/packages/font-manager-svn/
<br />
Many thanks to biloky who has maintained the Arch package builds from the start.

---

<br />
## Gentoo ##

---

See http://gpo.zugaina.org/media-gfx/font-manager

---

<br />
## Fedora ##

---

_This assumes sudo is setup for your user, if not just 'su' at the start_
#### If you already have a previous version of Font Manager installed ####
```
sudo yum remove font-manager
```
#### Install requirements ####
```
sudo yum install subversion gnome-common gcc intltool vala libxml2-devel freetype-devel fontconfig-devel glib2-devel json-glib-devel cairo-devel gtk3-devel pango-devel libgee-devel gucharmap-devel sqlite-devel gobject-introspection-devel file-roller -y
```

---

<br />
## Ubuntu ##

---

#### If you already have a previous version of Font Manager installed ####
```
sudo apt-get remove --purge font-manager
```
<br />
Ubuntu and derivative distributions can just use the PPA.
```
sudo add-apt-repository ppa:font-manager/staging
sudo apt-get update
sudo apt-get install font-manager
```
<br />
Or if you prefer to do it manually

#### Install requirements ####
```
sudo apt-get install subversion build-essential gnome-common valac libxml2-dev libfreetype6-dev libfontconfig1-dev libglib2.0-dev libjson-glib-dev libcairo2-dev libgtk-3-dev libpango1.0-dev libgee-0.8-dev libgucharmap-2-90-dev libsqlite3-dev libgirepository1.0-dev file-roller yelp-tools -y
```

---

<br />
## ALL ##

---

#### Checkout the latest revision from SVN ####
```
svn checkout http://font-manager.googlecode.com/svn/trunk/ font-manager
```
Make sure to read the README file before proceeding.
#### Build and install ####
```
cd font-manager
./autogen.sh --prefix=/usr
make
sudo make install
```
#### Run it ####
```
font-manager
```
#### Before filing an issue please ensure you are running the latest revision ####
While inside the font-manager directory
```
svn up
```
If anything is updated, please build and install the application again then verify the issue is still present.
<br />

---

<br />
#### Notes ####
Should the program not show up in Gnome Shell, restart it.
```
Alt + F2
type 'r'
hit Enter
```