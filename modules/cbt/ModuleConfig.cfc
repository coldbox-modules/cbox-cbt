/**
*********************************************************************************
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
********************************************************************************
*/
component {

	// Module Properties
	this.title 				= "ColdBox Templating Lanaguage";
	this.author 			= "Ortus Solutions, Corp";
	this.webURL 			= "https://www.ortussolutions.com";
	this.description 		= "Leverages the Pebble library for Twig templating language capabilities";
	this.version			= "@build.version@+@build.number@";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "cbt";
	// CF Mapping
	this.cfmapping			= "cbt";
	// Module Dependencies That Must Be Loaded First, use internal names or aliases
	this.dependencies		= [ "cbjavaloader" ];

	function configure(){
		// Custom Declared Interceptors
		interceptors = [
		];

		// Settings
		settings = {
			// The library path
			libPath 			= modulePath & "/lib",
			// If in strict mode, exceptions will be thrown for variables that do not exist, else it prints them out as empty values
			strictVariables 	= false,
			// Sets whether or not escaping should be performed automatically, defaults to true.
			autoEscaping 		= true,
			// Enable/disable all cache
			cacheActive 		= false,
			// Activate localization or not, default is false
			i18nActive			= false,
			// Sets the default Locale passed to all templates constructed by the pebble engine.
			defaultLocale 		= "en_US",
			// By default, Pebble will trim a newline that immediately follows a Pebble tag
			// For example, {{key1}}\n{{key2}} will have the newline removed.
			newLineTrimming 	= true,
			// Bind the ColdBox Flash scope
			bindFlash 			= true,
			// Bind the session scope to templates
			bindSession 		= true,
			// Bind the cgi scope to templates
			bindCGI 			= true,
			// Bind the request scope to templates
			bindRequest 		= true,
			// Bind to the request's HTTP Request Data elements
			bindHTTPRequestData = true,
			// The default cbt templating language template extension
			templateExtension 	= ".cbt"
		};
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		// Class loading of Java templating engine
		controller.getWireBox()
			.getInstance( "loader@cbjavaloader" ).appendPaths( settings.libPath );
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}