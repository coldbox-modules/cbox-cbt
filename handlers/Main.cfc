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
			getInstance( "User" ).init( "test", "man" ).getMemento(),
			getInstance( "User" ).init( "luis", "majano" ).getMemento(),
			getInstance( "User" ).init( "twig", "man" ).getMemento()
		];

		prc.xehLearnMore       = event.buildLink( "main" );
		prc.xehModuleRendering = event.buildLink( "testing/home" );
		prc.footer             = "Generated on #now()#";

		// Content Variables
		prc.moduleView 		= cbt.renderTemplate( template="home/simple", module="testing" );

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

		return cbt.renderTemplate( "main/simple" );
	}

	/**
	* inheritance
	*/
	function inheritance( event, rc, prc ){
		return cbt.renderTemplate( "main/inheritance" );
	}

	// Run on first init
	any function onAppInit( event, rc, prc ){
	}

}