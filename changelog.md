CHANGELOG
=========

## 1.0.1
* Removed toJava conversions, too experimental and too slow
* Added ability to render templates from modules on-demand: `render( template="", module="" )`
* Added ability to render templates from content variables via `renderContent( content="", context="" )`, this leverages file writing at the java tmp dir until pebble supports it on demand.

## 1.0.0
* Create first module version