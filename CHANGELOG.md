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
