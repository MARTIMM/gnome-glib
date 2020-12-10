![gtk logo][logo]

# Gnome Glib - C-based object and type system with signals and slots

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/gnome-glib?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/gnome-glib/branch/master) [![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description

# Documentation

| Pdf from pod | Link to Gnome Developer |
|-------|--------------|
| Gnome::Glib::Error |
| Gnome::Glib::List |  [Doubly-Linked Lists][List]
| Gnome::Glib::Main |  [The Main Event Loop][Main]
| Gnome::Glib::SList |  [Singly-Linked Lists][SList]

## Release notes
* [Release notes][changes]

# Installation
Do not install this package on its own. Instead install `Gnome::Gtk3`.

`zef install Gnome::Gtk3`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my Gnome::Gtk3 github project][issues].

# Attribution
* The inventors of Raku, formerly known as Perl 6, of course and the writers of the documentation which helped me out every time again and again.
* The builders of the GTK+ library and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/gnome-glib/blob/master/CHANGES.md
[logo]: https://github.com/MARTIMM/gnome-glib/blob/master/doc/images/gtk-logo-100.png
[issues]: https://github.com/MARTIMM/gnome-gtk3/issues

[Error]: https://developer.gnome.org/glib/stable/glib-Error-Reporting.html
[List]: https://developer.gnome.org/glib/stable/glib-Doubly-Linked-Lists.html
[Main]: https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html
[SList]: https://developer.gnome.org/glib/stable/glib-Singly-Linked-Lists.html

[//]: # (https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.pdf)
