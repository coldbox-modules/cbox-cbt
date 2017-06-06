/**
* Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* This Engine CFC interacts with the current template processor: Pebble
*/
component accessors="true" singleton threadsafe{

	// DI
	property name="moduleSettings" 	inject="coldbox:modulesettings:cbt";
	property name="javaLoader"		inject="loader@cbjavaloader";
	property name="controller" 		inject="coldbox";
	property name="requestService" 	inject="coldbox:requestService";

	// Properties

	/**
	* The internal engine used for the markup builder, in our case this points to a Pebble Engine Builder.
	*/
	property name="engine";

	/**
	* Constructor
	*/
	function init(){
		return this;
	}

	function onDIComplete(){
		// Setup the pebble engine on startup.
		var oBuilder	= javaLoader.create( "com.mitchellbosecke.pebble.PebbleEngine$Builder" );
		
		// Setup Engine settings according to module settings
		oBuilder.strictVariables( javaCast( "boolean", moduleSettings.strictVariables ) );
		oBuilder.autoEscaping( javaCast( "boolean", moduleSettings.autoEscaping ) );
		oBuilder.cacheActive( javaCast( "boolean", moduleSettings.cacheActive ) );
		//oBuilder.defaultLocale( javaCast( "boolean", moduleSettings.defaultLocale ) );
		oBuilder.newLineTrimming( javaCast( "boolean", moduleSettings.newLineTrimming ) );

		// Build Engine out
		variables.engine = oBuilder.build();

		variables.appPath 	= controller.getSetting( "ApplicationPath" );
	}

	/**
	* Render out a template using the templating language
	* @template The template to render out using discovery
	* @context A structure of data to bind the rendering with
	*/
	string function render( string template='', struct context={} ){
	    var oWriter 	= createObject( "Java", "java.io.StringWriter" ).init();
	    var event 		= requestService.getContext();

	    // Build out arg map for rendering
	    var argMap = {
	    	"rc" 			= event.getCollection(),
	    	"prc" 			= event.getPrivateCollection(),
	    	"event"			= event,
	    	"controller" 	= controller,
	    	"cgi"			= moduleSettings.bindSession ? cgi : {},
	    	"session"		= moduleSettings.bindSession ? session : {},
	    	"request"		= moduleSettings.bindSession ? request : {},
	    	"server"		= moduleSettings.bindSession ? server : {},
	    	"httpData"		= moduleSettings.bindHTTPRequestData? getHTTPRequestData() : {},
	    };

	    // Incorporate context
	    structAppend( argMap, context, true );

	    // Componse path
	    var thisPath 	= "#variables.appPath#views/#arguments.template#.twig";
	    // Create pebble template
		var oTemplate 	= engine.getTemplate( thisPath );
		// bind it
		oTemplate.evaluate( oWriter, argMap );

		// render it out
		return oWriter.toString();
	}
	
}