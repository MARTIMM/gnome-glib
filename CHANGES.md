## Release notes
* 2022-01-21 0.20.3
  * Extended module **Gnome::Glib::MainLoop** with method `timeout-add()`. With this method you can start a repeated event which a handler can process. Nice to show a clock or change pictures in a fotoviewer for example.

* 2021-12-12 0.20.2
  * Changes for renamed methods in **Gnome::N::TopLevelClassSupport**.

* 2021-05-03 0.20.1
  * Bugfixes; When initializing a new List object with the result from e.g. `.next()`, the undefined result must be explicitly set to N-GList to get a proper List object which can be tested with `.is-valid()`.

* 2021-03-03 0.20.0
  * Add **Gnome::Glib::Source**. In addition to the MailLoop and MainContext, this module provides method to run method regularly on set times or when the main loop is idle.
  * Many **Gnome::Glib::N-…** modules describing native objects are removed and replaced by **Gnome::N::N-GObject** except for those having their own structure like the list and error modules.
  * Revisited **Gnome::Glib::List** and **Gnome::Glib::SList** modules; removed deprecated methods and attributes, cleanup code, added methods for each native sub and changes in return values.

* 2021-02-22 0.19.0
  * Added **Gnome::Glib::N-GVariantDict** and **Gnome::Glib::VariantDict** modules.
  * Added `.new(:tuple)` to **Gnome::Glib::VariantType**.
  * Added `.new(:dict)` to **Gnome::Glib::Variant**.

* 2021-02-15 0.18.4
  * Added raw versions of `invoke()` and `invoke-full()`.

* 2021-02-12 0.18.3
  * Extracted **Gnome::Glib::MainContext**, **Gnome::Glib::MainLoop**, **Gnome::Glib::N-GMainContext** and **Gnome::Glib::N-GMainLoop** from the original module **Gnome::Glib::Main**.

* 2021-02-10 0.18.2
  * Change new( :type-string, :parse) init. :type-string is now optional. Format of the :parse string can be found [here](https://developer.gnome.org/glib/stable/gvariant-text.html). You can see that a type can be inserted when it is not a default.
  * Bugfixes caused by moved types from Gnome::N to Gnome::Glib.

* 2021-02-07 0.18.1
  Copied back a removed module.

* 2021-01-29 0.18.0
  * Copied N-GVariantType and N-GVariant from Gnome::N package.
  * Revisited VariantType and Variant modules and added tests.
  * VariantIter and VariantBuilder are removed till better times.

* 2020-12-01 0.17.3
  * Changes to use **Gnome::N::GlibToRakuTypes**.
  * Further doc changes and added tests.

* 2020-04-22 0.17.2
  * Added a test before freeing a list or slist. There are sometimes crashes with a message `***MEMORY-ERROR***: qa-manager.pl6[28683]: GSlice: assertion failed: sinfo->n_allocated > 0`. I am not sure if it happens here but added to make sure it doesn't.

* 2020-04-05 0.17.1
  * Removed a level of exception catching.

* 2020-03-07 0.17.0:
  * Add module VariantIter (split from GVariant source). There are some problems with this module. Reviewing the usability of all the Variant* classes it seems to be needed by Action* classes (from Gio), using it to keep some state of sorts. I think this can be solved by Raku solutions by keeping a state in the Raku objects which handle the Action classes 'activate' signals while keeping the Action objects 'stateless'. So the the Variant* classes are not yet usable and the development is put on hold for the moment.
  * Renamed Option to OptionContext.
  * All modules except Main and Quark are converted to use the **Gnome::N::TopLevelClassSupport**.

* 2020-03-07 0.16.1:
  * Removed CALL-ME() methods.
  * Improved FALLBACK methods.

* 2020-03-01 0.16.0:
  * Add modules VariantType, Variant, VariantBuilder (split from GVariant source).

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
