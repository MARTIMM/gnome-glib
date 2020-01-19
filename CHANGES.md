## Release notes
* 2020-01-18 0.15.5:
  * renaming calls to `*native-gobject()` and `*native-gboxed()`.
  * rename `:widget` and other likewise arguments to `:native-object`.
  * remove `:empty` and use empty options hash instead

* 2020-01-10 0.15.4.1:
  * Repo renaming. Perl6 to Raku.

* 2019-12-03 0.15.4:
  * Documentation changes

* 2019-11-28 0.15.3
  * Modified and extended List module and added tests and documentation

* 2019-11-24 0.15.2
  * Modified FALLBACK routines to change order of tests

* 2019-11-11 0.15.1
  * Issue #5 (on Gnome::Gtk3); change tests in Error.t

* 2019-10-30 0.15.0
  * Added Option module.

* 2019-10-07 0.14.4
  * changed call to test-call()

* 2019-08-10 0.14.3
  * Completing Error and Quark, documentation and test coverage

* 2019-08-10 0.14.2
  * Added documentation to SList.

* 2019-08-05 0.14.1
  * Improved documentation of Error.
  * Now one can add an undefined error object with Error.new(:$gerror) but it will set the flag $.error-is-valid to False, showing that the object is invalid. This small change makes it more easy to create an Error object and test its flag instead of returning a type object which needs different testing.

* 2019-08-01 0.14.0
  * Extended Error and created Quark. Also tests and doc is added.

* 2019-05-28 0.13.3
  * Updating docs

* 2019-05-28 0.13.2
  * Modified class names by removing the first 'G' from the name. E.g. GError becomes Error.

* 2019-05-27 0.13.1
  * Refactored from project GTK::V3 at version 0.13.1
