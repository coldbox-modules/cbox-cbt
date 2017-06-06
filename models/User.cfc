component accessors="true"{

	property name="firstName";
	property name="lastName";

	function getFirstName(){
		return variables.firstName;
	}

	function init( firstName="", lastName="" ){
		variables.firstName = arguments.firstName;
		variables.lastName = arguments.lastName;
		
		return this;
	}

}