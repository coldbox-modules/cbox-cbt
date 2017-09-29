/**
* A normal ColdBox Event Handler
*/
component{

	property name="cbt" inject="engine@cbt";

	function index( event, rc, prc ){
		return cbt.render( "home/index" );
	}

}
