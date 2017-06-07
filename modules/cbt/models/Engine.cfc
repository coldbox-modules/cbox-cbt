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
	    var flash 		= requestService.getFlashScope();

	    // Build out arg map for rendering
	    var argMap = {
	    	"rc" 			= event.getCollection(),
	    	"prc" 			= event.getPrivateCollection(),
	    	"event"			= event,
	    	"controller" 	= controller,
	    	"flash"			= moduleSettings.bindFlash ? flash.getScope() : {},
	    	"cgi"			= moduleSettings.bindCGI ? cgi : {},
	    	"session"		= moduleSettings.bindSession ? session : {},
	    	"request"		= moduleSettings.bindRequest ? request : {},
	    	"server"		= moduleSettings.bindServer ? server : {},
	    	"httpData"		= moduleSettings.bindHTTPRequestData? getHTTPRequestData() : {}
	    };

	    argMap = this.toJava( argMap );

	    // writeDump(var=argMap);
	    // abort;

	    // Incorporate incoming context
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

	private any function toJava( required any obj ){

		//Convert components to a map representation of their properties
		if( isValid( "component", arguments.obj ) ){
			
			var md = getMetadata( arguments.obj );
			var props = md.properties;

			// Return null if we have no ability to access the properties
			if( !arrayLen( props ) || !structKeyExists( md, "accessors" ) || md[ "accessors" ] == "false" ){
				return javacast( "null", 0 );
			}

			var map = createObject( "java", "java.util.HashMap" ).init();

			for( var prop in props ){

				var accessor = arguments.obj[ "get" & prop.name ];

				map[ prop.name ] = toJava( accessor() );

			}

			return map;

		//convert structs to java.util.HashMap
		} else if( isStruct( arguments.obj ) ){
			
			var map = createObject( "java", "java.util.HashMap" ).init();
			
			map.putAll( arguments.obj );
			
			for( var key in map ){
				if( !isSimpleValue( map[ key ] ) ){
					map[ key ] = toJava( map[ key ] );
				}
			}

			return map

		//convert structs to java.util.ArrayList
		} else if(isArray(arguments.obj)){
			
			var list = createObject( "java", "java.util.ArrayList" ).init();

			for(var member in arguments.obj){
				list.add( toJava( member ) );
			}

			return list;
		
		//Otherwise return the object
		} else {
			return arguments.obj;
		}
	} 
	
}