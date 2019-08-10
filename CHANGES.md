## Release notes

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
