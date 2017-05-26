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
			strictVariables 	= false,
			autoEscaping 		= true,
			cacheActive 		= true,
			defaultLocale 		= "en_US",
			newLineTrimming 	= true
		}
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