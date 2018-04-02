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

	/**
	* Constructor
	*/
	Engine function init(){
		variables.appPath           	= "";
		variables.viewsConvention   	= "";
		variables.layoutsConvention 	= "";
		variables.engineConfiguration	= "";
		variables.modulesConfig 		= {};

		return this;
	}

	/**
	 * Load up Configurations
	 */
	function onDIComplete(){
		// Setup Pathing + Module Settings
		variables.appPath 			= controller.getSetting( "ApplicationPath" );
		variables.viewsConvention 	= controller.getSetting( "viewsConvention", true );
		variables.layoutsConvention = controller.getSetting( "layoutsConvention", true );
		variables.modulesConfig		= controller.getSetting( "modules" );

		// Get default configuration for builder
		//variables.engineConfiguration = javaLoader.create( "org.jtwig.environment.DefaultEnvironmentConfiguration" ).init();

		var configBuilder = javaLoader.create( "org.jtwig.environment.EnvironmentConfigurationBuilder" )
			.configuration()
				.render()
					.withStrictMode( javaCast( "boolean", moduleSettings.strictVariables ) )
				.and();

		// Caching
		if( !moduleSettings.cacheActive ){
			configBuilder
				.parser()
					.withoutTemplateCache()
				.and();
		}
		
		variables.engineConfiguration = configBuilder.build();
	}

	/**
	 * Render out from a-la-carte content instead of from files.  Internally, we will use the RAM file resource
	 * to stream the intermediate content
	 * 
	 * @content The templating content to convert
	 * @context A structure of data to bind the rendering with, so you can access it within the `{{ }}` or `{{{ }}}` notations.
	 */
	string function renderContent( required string content, struct context={} ){
		// Trim content
		arguments.content = trim( arguments.content );

		// Generate template from incoming string
		var oTemplate = javaLoader.create( "org.jtwig.JtwigTemplate" )
			.inlineTemplate( arguments.content, variables.engineConfiguration );
		
		// Generate Context + Model
		var argMap = generateBindingContext( event=requestService.getContext() );
		// Incorporate incoming context
		argMap.append( context, true );
		var oModel = javaLoader.create( "org.jtwig.JtwigModel" ).newModel( argMap );

		// Render it out.
		return oTemplate.render( oModel );
	}
	

	/**
	* Render out a template using the templating language
	* 
	* @template The template to render. By convention we will look in the views convention of the current application or running module. This can also be an absolute path.
	* @context A structure of data to bind the rendering with, so you can access it within the `{{ }}` or `{{{ }}}` notations.
	* @module If passed, then we will bypass lookup for templates and go to the specified module to render the template from.
	*/
	string function renderTemplate( 
		string template='', 
		struct context={},
		string module=''
	){
	    var event 		= requestService.getContext();
		var argMap 		= generateBindingContext( event=event, module=arguments.module );

	    // Incorporate incoming context
	    structAppend( argMap, context, true );

	    // Discover view or check if absolute already?
		if( fileExists( arguments.template ) ){
			var thisPath = arguments.template;
		} else {
			var thisPath = discoverTemplate( 
				template = arguments.template, 
				event    = event, 
				module   = arguments.module 
			);
		}

		// Generate template from incoming string
		var oTemplate = javaLoader.create( "org.jtwig.JtwigTemplate" )
			.fileTemplate( thisPath, variables.engineConfiguration );
		// Generate Model from context
		var oModel = javaLoader.create( "org.jtwig.JtwigModel" ).newModel( argMap )

	    // Render it out
	    return oTemplate.render( oModel );
	}

	/**
	 * Discover a template from the ColdBox Eco-System
	 * 
	 * @template The template convention to lookup
	 * @event The request context
	 * @module If passed, look for the view in this module.
	 */
	function discoverTemplate( required template, required event, string module="" ){
		// Direct or indirect module execution
		var currentModule 	= ( len( arguments.module ) ? arguments.module : event.getCurrentModule() );
		// Default template extensions
		var extension 		= variables.moduleSettings.templateExtension;

		// Append our .cbt extension if needed
		if( !findNoCase( extension, arguments.template ) ){
			arguments.template &= extension;
		}

		// Module Mode?
		if( len( currentModule )  ){
			return "#variables.modulesConfig[ currentModule ].path#/#variables.modulesConfig[ currentModule ].conventions.viewsLocation#/#arguments.template#";
		} 
		// View Mode
		else {
			return "#variables.appPath##variables.viewsConvention#/#arguments.template#";
		}
	}

	/**
	 * Generate binding context
	 * 
	 * @event The ColdBox Request context to bind with
	 * @module Are we in direct module template mode?
	 */
	private struct function generateBindingContext( required event, string module="" ){
		var flash = requestService.getFlashScope();

	    // Build out arg map for rendering
	    var argMap = {
	    	// ColdBox Scopes
	    	"rc" 						= event.getCollection(),
	    	"prc" 						= event.getPrivateCollection(),
	    	"flash"						= moduleSettings.bindFlash ? flash.getScope() : {},
	    	
	    	// ColdBox Context
	    	"now"					 	= now(),
	    	"baseURL" 				 	= event.getSESBaseURL(),
	    	"currentAction" 		 	= event.getCurrentAction(),
	    	"currentEvent" 			 	= event.getCurrentEvent(),
	    	"currentHandler" 		 	= event.getcurrentHandler(),
	    	"currentLayout" 		 	= event.getCurrentLayout(),
	    	"currentModule" 		 	= event.getCurrentModule(),
	    	"currentRoute" 			 	= event.getCurrentRoute(),
	    	"currentRoutedURL"  	 	= event.getCurrentRoutedURL(),
	    	"currentRoutedNamespace" 	= event.getCurrentRoutedNamespace(),
	    	"currentView"		     	= event.getCurrentView(),
	    	"moduleRoot"			 	= event.getModuleRoot(),
	    	
	    	// ColdFusion Scopes
	    	"cgi"						= moduleSettings.bindCGI ? cgi : {},
	    	"session"					= moduleSettings.bindSession ? session : {},
	    	"request"					= moduleSettings.bindRequest ? request : {},
	    	"server"					= moduleSettings.bindServer ? server : {},
	    	"httpData"					= moduleSettings.bindHTTPRequestData? getHTTPRequestData() : {},
	    	
	    	// ColdBox Pathing Prefixes
	    	"appPath"					= variables.appPath,
	    	"layoutsPath"				= variables.appPath & "layouts/",
	    	"viewsPath"					= variables.appPath & "views/",
	    	"modulePath" 				= "",
	    	"modulesLayoutsPath" 		= "",
	    	"modulesViewsPath"			= ""
	    };

	    // Are we in a module, bind the module path
	    if( len( event.getCurrentModule() ) ){
	    	argMap.modulePath 			= variables.modulesConfig[ event.getCurrentModule() ].path;
	    	argMap.modulesLayoutsPath 	= argMap.modulePath & "/" & variables.modulesConfig[ event.getCurrentModule() ].conventions.layoutsLocation;
	    	argMap.modulesViewsPath 	= argMap.modulePath & "/" & variables.modulesConfig[ event.getCurrentModule() ].conventions.viewsLocation;
	    }

		// Are we in direct module execution mode?
		if( len( arguments.module ) ){
			argMap.modulePath 			= variables.modulesConfig[ arguments.module ].path;
	    	argMap.modulesLayoutsPath 	= argMap.modulePath & "/" & variables.modulesConfig[ arguments.module ].conventions.layoutsLocation;
	    	argMap.modulesViewsPath 	= argMap.modulePath & "/" & variables.modulesConfig[ arguments.module ].conventions.viewsLocation;
		}

		// CF To Java Conversions, removed due to performance, user must send data instead of objects
		// Discover further if we can do our own Java parser to detect CFC's and execute them via reflection.
	    //argMap = toJava( argMap );

		return argMap;
	}

	/**
	 * Convert CFML to java types
	 * Experimental, removing for now until further conventions can be done with CFC types.
	 *
	 * @obj Target objects for conversion
	 */
	private any function toJava( any obj ){
		// Convert nulls to proper java nulls
		if( isNull( arguments.obj ) ){
			
			return javacast( "null", 0 );

		// Convert components to a map representation of their properties
		} else if( isValid( "component", arguments.obj ) ){
		
			var md 		= getMetadata( arguments.obj );
			var props 	= md.properties ?: [];

			// weird cf11 metadata bug
			if( isSimpleValue( props ) ){
				props = [ ];
			}

			// Return null if we have no ability to access the properties
			if( !arrayLen( props ) || !structKeyExists( md, "accessors" ) || md[ "accessors" ] == "false" ){
				return javacast( "null", 0 );
			}

			var map = createObject( "java", "java.util.HashMap" ).init();
			for( var prop in props ){
				map[ prop.name ] = toJava( 
					evaluate( "arguments.obj.get#prop.name#()" )
				);
			}

			return map;
		
		//convert structs to java.util.HashMap
		} else if( isStruct( arguments.obj ) ){
			
			var map = createObject( "java", "java.util.HashMap" ).init();
			
			map.putAll( arguments.obj );

			for( var key in map ){
				// Null checks, stupid java
				if( isNull( map[ key ] ) ){
					map[ key ] = "null";
				} else if( !isSimpleValue( map[ key ] ) ){
					map[ key ] = toJava( map[ key ] );
				}
			}

			return map;
		// convert structs to java.util.ArrayList
		} else if( isArray( arguments.obj ) ){

			var list = createObject( "java", "java.util.ArrayList" ).init();

			for( var member in arguments.obj ){
				list.add( toJava( member ?: "" ) );
			}

			return list;
		
		// Otherwise return the object as is
		} else {
			return arguments.obj;
		}
	} 
	
}