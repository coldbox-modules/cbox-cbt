/**
* My Event Handler Hint
*/
component{

	property name="cbt" inject="engine@cbt";

	// Index
	any function index( event,rc, prc ){
		
		rc[ "websiteTitle" ] 	= "ColdBox Templating Language";
		rc[ "content" ] 		= "<h1>I am running on CBT baby! and totally XSS escaped</h1>";
		rc[ "complex" ] 		= {
			"hero" 	= "I am the hero unit",
			"body"	= "Welcome to the world of templating languages"
		};

		prc[ "users" ] = [
			getInstance( "User" ).init( "test", "man" ),
			getInstance( "User" ).init( "luis", "majano" ),
			getInstance( "User" ).init( "twig", "man" )
		];

		prc.xehLearnMore = event.buildLink( "main" );
		prc.footer = "Generated on #now()#";

		return cbt.render( "main/simple" );
	}

	/**
	* inheritance
	*/
	function inheritance( event, rc, prc ){
		return cbt.render( "main/inheritance" );
	}

	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}