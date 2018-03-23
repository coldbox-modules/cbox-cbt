/**
* My BDD Test
*/
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

/*********************************** BDD SUITES ***********************************/

	function run(){
		// all your suites go here.
		describe( "CBT Module", function(){

			beforeEach(function( currentSpec ){
				setup();
			});

			it( "should register library", function(){
				var loader = getLoader();
				expect(	loader ).toBeComponent();
			});

			it( "should compile templates by convention", function(){
				var e = execute( event="main.index", renderResults=true );
				expect(	e.getRenderedContent() ).toInclude( "I am running on CBT baby!" );
			});

			it( "should module templates by convention", function(){
				var e = execute( event="testing:home.index", renderResults=true );
				expect(	e.getRenderedContent() ).toInclude( "Welcome to my cool module page" );
			});

			it( "should render on demand templating", function(){
				var loader = getLoader();
				var onDemand = "
					<h2>On-Demand Renderings</h2>
					{{ 'Rendering from OnDemand Baby' | upper }}
					<br>
					{{ max( 20, 100 ) }}
					<br>
					Today is {{ now | date( 'yyyy-MMM-dd HH:mm:ss' ) }}
					<br>
					BaseURL: {{ baseURL }}
				";

				var results = loader.renderContent(
					content = onDemand
				);

				expect( results )
					.toInclude( "100" )
					.toInclude( "root/index.cfm" );
			});

		});
	}

	private function getLoader(){
		return getWireBox().getInstance( "engine@cbt" );
	}

}