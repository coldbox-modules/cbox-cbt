[![Build Status](https://travis-ci.org/coldbox-modules/cbox-cbt.svg?branch=development)](https://travis-ci.org/coldbox-modules/cbox-cbt)

# Welcome to the ColdBox Templating Language

The ColdBox templating language is inspired by [Twig](https://twig.symfony.com/) and implemented on top of the Java Engine Pebble - https://pebbletemplates.io/.  This templating language will allow you to leverage the ColdBox conventions and MVC methodology to your view layer and completely decouple yourself from any CFML in your views.

The ColdBox Templating Engine is fully featured and adheres to the Twig syntax and Pebble Extensions. Please follow the templating language documentation here: https://pebbletemplates.io/

## Sponsorship

This project was sponsored by **IDG Media Services** as one of our ColdBox Sponsors.  So thank you so much for your patronage and continued support: https://www.idg.de

## LICENSE

Apache License, Version 2.0.

## IMPORTANT LINKS

- Source: https://github.com/coldbox-modules/cbox-cbt
- Issues: https://github.com/coldbox-modules/cbox-cbt/issues
- ForgeBox: http://forgebox.io/view/cbt
- Language Documentation: https://pebbletemplates.io/

## SYSTEM REQUIREMENTS

- Lucee 4.5+
- ColdFusion 11+

---

# Instructions
Just drop into your `modules` folder or use the box-cli to install

`box install cbt`

## Settings

Create a `moduleSettings` structure with a `cbt` element with the following settings:

```js
moduleSettings = {
    cbt = {
        // If in strict mode, exceptions will be thrown for variables that do not exist, else it prints them out as empty values
        strictVariables     = false,
        // Sets whether or not XSS escaping should be performed automatically, defaults to true.
        autoEscaping        = true,
        // Enable/disable all templating cache
        cacheActive         = false,
        // Activate localization or not, default is false
        i18nActive          = false,
        // Sets the default Locale passed to all templates constructed by the pebble engine.
        defaultLocale       = "en_US",
        // By default, Pebble will trim a newline that immediately follows a Pebble tag
        // For example, {{key1}}\n{{key2}} will have the newline removed.
        newLineTrimming     = true,
        // Bind the ColdBox Flash scope
        bindFlash           = true,
        // Bind the session scope to templates
        bindSession         = true,
        // Bind the cgi scope to templates
        bindCGI             = true,
        // Bind the request scope to templates
        bindRequest         = true,
        // Bind to the request's HTTP Request Data elements
        bindHTTPRequestData = true,
        // The default cbt templating language template extension
        templateExtension   = ".cbt"
    }
};
```


## IDE Support

The following packages will give you twig syntax highlighting support. We recommend you install them to support cbt natively in your IDE.  Just make sure you associate the `.cbt` extension with the Twig language:

* Sublime: https://packagecontrol.io/packages/Twig
* Atom: https://atom.io/packages/language-twig
* VSCode: https://marketplace.visualstudio.com/items?itemName=bajdzis.vscode-twig-pack
* CFBuilder: http://twig.dubture.com/

<img src="https://github.com/Bajdzis/vscode-twig-pack/raw/master/readme/emmet.gif">


## Usage

This module will register the templating engine in WireBox as `engine@cbt` which you can use to inject it anywhere you would like rendering to occur. 

```js
property name="cbt" inject="engine@cbt";
```

The main rendering methods in the engine are `renderTemplate( template, context, module )` and `renderContent( content, context)`:

```js
/**
* Render out a template using the templating language
* 
* @template The template to render. By convention we will look in the views convention of the current application or running module. This can be also an absolute path.
* @context A structure of data to bind the rendering with, so you can access it within the `{{ }}` or `{{{ }}}` notations.
* @module If passed, then we will bypass lookup for templates and go to the specified module to render the template from.
*/
string function renderTemplate( 
    string template='', 
    struct context={},
    string module=''
);

/**
* Render out from a-la-carte content instead of from files.  Internally, we will use the RAM file resource
* to stream the intermediate content
* @content The twig content convert
* @context A structure of data to bind the rendering with, so you can access it within the `{{ }}` or `{{{ }}}` notations.
*/
string function renderContent( required string content, struct context={} );
```

> Note: You can optionally bind a `context` structure to the template, which will allow you to access data/objects in the top level scope of the templates.

Your twig compatible templates will be binded with a structure called `context`
 that will contain all the top-level variables the cbt module exposes plus all custom variables you pass into the templates.  By default, the cbt module will bind many ColdBox conventions and variable scopes.  Please see the next section for more information.

### Rendering by Conventions

You can skip to the ColdBox Conventions section below for further in-depth review, but using the `renderTemplate()` method allows you to pass in a template name and internally we will discover it using the same ColdBox conventions as `event.setView()` and `renderView()`.  The only difference, is that you can also pass in an absolute path `template` and we will bypass the lookups and just use the template for rendering:

```
// By Convention
return cbt.renderTemplate( "main/index" );

// By Absolute Path
return cb.renderTemplate( "/my/path/long" );
```

### Rendering From Modules

You can use the `module` argument to render templates directly from any ColdBox module.  This is the same as using the `module` argument in `event.setView()` and `renderView()` methods in ColdBox.  This bypasses the lookup procedures and renders directly from a module.

### Rendering On Demand

You can also render on-demand templating by passing the content as a variable instead as a file.  Internally, we will stream your content uniquely to file in the `cbt/models/tmp` directory and then sent to the pebble engine for conversion.


```js
savecontent variable="local.onDemand"{
    writeOutput("
        <h2>On-Demand Renderings</h2>
        {{ 'Rendering from OnDemand Baby' | upper }}
        <br>
        {{ max( 20, 100 ) }}
        <br>
        Today is {{ now | date( 'yyyy-MMM-dd HH:mm:ss' ) }}
        <br>
        BaseURL: {{ baseURL }}
    ")
}

prc.onDemandContent = cbt.renderContent(
    content = onDemand
);
```


### Including/Inheritance with Relative Paths

The templating language allows you to include or extend from other templates.  You can use relative pathing or absolute pathing.  All relative paths will start with `.\` or going back a level `..\`.

```html
Top Content
{% include "./advertisement.cbt" %}

Bottom Content
{% include "../tags/footer.cbt" %}

{% extends "./parent.cbt" %}
```

Please note that when you are in the templates, you MUST specify the `.cbt` or whatever the file extension is.  In a future version, we might improve this.

### Engine Access

If you would like access to the main Pebble rendering engine, you can call the `getEngine()` method:

```
pebble = cbt.getEngine();
```

Then go nuts with the Java Engine!

### `.cbt` extension

By default, the extension we will look for in the templates is `.cbt`.  This is configurable via the `templateExtension` settings.  You do not need to append the `.cbt` extension when calling the `renderTemplate()` method.

```js
cb.renderTemplate( "main/index" );
```

> Important: You MUST use the extension when doing includes or template inheritance in the templates.

### ColdBox Conventions

The cbt engine has been configured to work with your ColdBox MVC applications in many enhanced ways.

#### Rendering Conventions
By convention, the cbt language knows about your layouts/views and module views.  So when you call the `renderTemplate( template )` method it will take into account the context of execution: parent application or a module just like calling the `event.setView()` and `renderView()` methods in ColdBox.

```js
function index( event, rc, prc ){
    // Get data
    prc.data = service.getData();
    // Render the main/index.cbt template
    return cbt.renderTemplate( "main/index" );
}
```

#### Template Bindings

By convention, the cbt language will bind the following variables into the templates:

```js
// ColdBox Scopes
"rc"            = event.getCollection(),
"prc"           = event.getPrivateCollection(),
"flash"         = moduleSettings.bindFlash ? flash.getScope() : {},

// ColdBox Context
"now"                    = now(),
"baseURL"                = event.buildLink( '' ),
"currentAction"          = event.getCurrentAction(),
"currentEvent"           = event.getCurrentEvent(),
"currentHandler"         = event.getcurrentHandler(),
"currentLayout"          = event.getCurrentLayout(),
"currentModule"          = event.getCurrentModule(),
"currentRoute"           = event.getCurrentRoute(),
"currentRoutedURL"       = event.getCurrentRoutedURL(),
"currentRoutedNamespace" = event.getCurrentRoutedNamespace(),
"currentView"            = event.getCurrentView(),
"moduleRoot"             = event.getModuleRoot(),

// ColdFusion Scopes
"cgi"           = moduleSettings.bindCGI ? cgi : {},
"session"       = moduleSettings.bindSession ? session : {},
"request"       = moduleSettings.bindRequest ? request : {},
"httpData"      = moduleSettings.bindHTTPRequestData? getHTTPRequestData() : {},

// ColdBox Pathing Prefixes
"appPath"           = variables.appPath,
"layoutsPath"       = variables.appPath & "layouts/",
"viewsPath"         = variables.appPath & "views/",
"modulePath"        = "",
"modulesLayoutsPath" = "",
"modulesViewsPath"  = ""
```

This means that you can use `{{ varname }}` notation to access them in your templates.  Please refer to the [Basic Usage](https://pebbletemplates.io/wiki/guide/basic-usage/) help page for further examples.

Since your cbt templates have no access AT ALL to CFML, this will force your templates to just do the view layer. All your event handlers must make sure to put in prc or rc the necessary variables for your views to use.  Including content variables, other renderings, messageboxes, etc.

### Including/Extending Dyanmically

As you can see from the bindings above, the templates are binded with several pathing locations which are essential for the templating language to find your templates when doing inheritance or includes:

* `appPath`     : The root path of the application
* `layoutsPath` : The layouts path
* `viewsPath`   : The views path
* `modulePath`  : The current executing module's root path
* `modulesLayoutsPath` : The current executing module's layouts path
* `modulesViewsPath` :  The current executing module's views path

You can then use them in your templates:

```html
{% extends layoutsPath + "Main.cbt" %}

{% include modulesViewspath + "/tags/header.cbt" %}
``` 


## Examples

This repository has different examples for renderings.  Just look at them here: https://github.com/coldbox-modules/cbox-cbt

********************************************************************************
Copyright Since 2005 ColdBox Framework by Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
#### HONOR GOES TO GOD ABOVE ALL
Because of His grace, this project exists. If you don't like this, then don't read it, it's not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the 
Holy Ghost which is given unto us. ." Romans 5:5

### THE DAILY BREAD
 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
