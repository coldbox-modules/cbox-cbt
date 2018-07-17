# CHANGELOG

## 2.0.0

* Removed server bindings, too problematic with serializations
* Added slf4j 1.8 beta to avoid class loading issues with Adobe and Lucee engines
* Upgraded literal template parsing by leveraging the new `getLiteralTemplate()` method on the new engine
* Upgraded to Pebble 3.0.0 which introduces new features (https://github.com/PebbleTemplates/pebble/releases), below are the major features:
  * Add support for 'as' and 'from' in import statement 
  * Macros have access to all variables within the template and are no longer restricted to a "local scope"
  * String Interpolation
  * Render content on demand. Expose getLiteralTemplate(String templateName)

## 1.1.0

* Updated to latest dependencies
* Refactor `/cbt/models/tmp` to leverage the internal engine temp directories with tests
* Renamed `render` to `renderTemplate` to avoid engine bifs collisions
* Removed `toJava` conversions, too experimental and too slow
* Added ability to render templates from modules on-demand: `renderTemplate( template="", module="" )`
* Added ability to render templates from content variables via `renderContent( content="", context="" )`, this leverages file writing at the java tmp dir until pebble supports it on demand.
* cleanup of servlet jar, this is not needed

## 1.0.0

* Create first module version