component accessors="true"{

	property name="firstName";
	property name="lastName";

	function init( firstName="", lastName="" ){
		variables.firstName = arguments.firstName;
		variables.lastName = arguments.lastName;
		
		return this;
	}

}