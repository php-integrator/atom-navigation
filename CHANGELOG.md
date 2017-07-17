## 1.2.1
* Attempt to fix apm not picking new release.

## 1.2.0 (base 3.0.0)
* Upgrade to base 3.0.0.

## 1.1.2
* Fix hyperclick providers triggering in other languages than PHP. (https://github.com/php-integrator/atom-navigation/issues/37)

## 1.1.1
* Fix deprecations.

## 1.1.0 (base 2.0.0)
### Features and enhancements
* The dependency on SubAtom and jQuery has been removed.
* Hyperclick is now used as back end, which allowed a lot of code to be replaced with a single, consistent, implementation.
  * You can now attach a shortcut to navigation (see also hyperclick's settings).
  * The default modifier key is now the control key, hyperclick fixes the issue where it created an additional cursor.
    * You can modify the modifier key via hyperlick's settings. Support for this was added in version 0.0.39.
* The `ClassProvider` will no longer continuously scan the entire buffer, creating markers in the buffer to properly handle comment ranges. Instead, this scanning is performed only when trying to navigate to something inside a comment block.
  * This should improve editor responsiveness, during editing as well as when starting Atom.

### Bugs fixed
* Fix navigation to unqualified global constants not working.
* Fix navigation to unqualified global functions not working.
* Fix navigation to qualified global constants with namespace prefix not working.
* Fix navigation to qualified global functions with namespace prefix not working.
* Fix navigation to global constants imported using use statements not working.
* Fix navigation to global functions imported using use statements not working.
* Fix not being able to navigate to the PHP documentation for built-in classes with longer FQCN's, such as classes from MongoDB.
* Fix not being able to navigate to method names with leading slashes, such as `__toString`, because PHP's URL endpoints are terrifically consistent.
* Fix built-in classes sometimes navigating to the wrong page, e.g. `DateTime` was navigating to the overview page instead of the class documentation page.

## 1.0.3
* Rename the package and repository.

## 1.0.2
* Fix not being able to navigate to annotation classes (e.g. Doctrine or Symfony annotations).
* Fix not being able to navigate to types if they were suffixed with square brackets, i.e. `Foo[]`.

## 1.0.1
* Fix the version specifier not being compatible with newer versions of the base service.

## 1.0.0 (base 1.0.0)
* Update to use the most recent version of the base service.

## 0.7.1
* It is now possible to navigate to the PHP documentation by clicking methods from built-in classes.

## 0.7.0 (base 0.9.0)
* Navigation is now asynchronous (i.e. it uses the asynchronous method calls from the base service rather than synchronous calls).

## 0.6.2 (base 0.8.0)
* Update to use the most recent version of the base service.

## 0.6.1
* Fixed issues occurring when deactivating and reactivating the package.

## 0.6.0 (base 0.7.0)
* Update to use the most recent version of the base service.

## 0.5.0 (base 0.6.0)
* The dependency on fuzzaldrin was removed.
* Fixed class constants being underlined as if no navigation was possible, while it was.
* It is now possible to alt-click built-in functions and classes to navigate to the PHP documentation in your browser.

## 0.4.0 (base 0.5.0)
* The modifier keys that are used in combination with a mouse click are now modifiable as settings.
* Show a dashed line if an item is recognized, but navigation is not possible (i.e. because the item wasn't found).

## 0.3.0 (base 0.4.0)
* Added navigation to the definition of global constants.
* Fixed navigation not working in corner cases where a property and method existed with the same name.

## 0.2.4
* Don't try to navigate to items that don't have a filename set. Fixes trying to alt-click internal classes such as 'DateTime' opening an empty file.

## 0.2.3
* Fixed markers not always registering on startup because the language-php package was not yet ready.

## 0.2.2
* Simplified class navigation and fixed it not working in some rare cases.

## 0.2.1
* Stop using maintainHistory to be compatible with upcoming Atom 1.3.

## 0.2.0
* Added navigation to the definition of class constants.
* Added navigation to the definition of (user-defined) global functions.

## 0.1.0
* Initial release.
