![gtk logo][logo]

# Gnome Glib - C-based object and type system with signals and slots

[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description

# Documentation

| Pdf from pod | Link to Gnome Developer |
|-------|--------------|
| Gnome::GObject::GError |
| Gnome::GObject::GList |  [Doubly-Linked Lists][GList]
| Gnome::GObject::GMain |  [The Main Event Loop][GMain]
| Gnome::GObject::GSList |  [Singly-Linked Lists][GSList]

## Release notes
* [Release notes][changes]

# Installation of Gnome::GObject

`zef install Gnome::GObject`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my github project](https://github.com/MARTIMM/perl6-gnome-glib/issues).

# Attribution
* The inventors of Perl6 of course and the writers of the documentation which help me out every time again and again.
* The builders of the GTK+ library and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/perl6-gnome-glib/blob/master/CHANGES.md
[logo]: https://github.com/MARTIMM/perl6-gnome-glib/blob/master/doc/images/gtk-logo-100.png

[glist]: https://developer.gnome.org/glib/stable/glib-Doubly-Linked-Lists.html
[gmain]: https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html
[gslist]: https://developer.gnome.org/glib/stable/glib-Singly-Linked-Lists.html
[gerror]: https://developer.gnome.org/glib/stable/glib-Error-Reporting.html


[//]: # (https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.pdf)
[//]: # (Pod documentation rendered with)
[//]: # (pod-render.pl6 --pdf --g=github.com/MARTIMM/perl6-gnome-glib lib)
