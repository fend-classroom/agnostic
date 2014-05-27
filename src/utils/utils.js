/*
   This file is part of UNIX Guide for the Perplexed project.
   Copyright (C) 2014 by Assaf Gordon <assafgordon@gmail.com>
   Released under GPLv3 or later, with the following addition:

     As additional permission under GNU GPL version 3 section 7, you
     may distribute non-source (e.g., minimized or compacted) forms of
     that code without the copy of the GNU GPL normally required by
     section 4, provided you include this license notice and a URL
     through which recipients can access the Corresponding Source.

   See: https://www.gnu.org/philosophy/javascript-trap.html
*/

/*
 Generate Helper Functions
 */

/* TODO: IsObject and IsArray are limited (perhaps even incorrect),
   according to http://tobyho.com/2011/01/28/checking-types-in-javascript/ */

/* A Helper function, returns true of the given parameter is an object */
IsObject = function(obj) {
	var s = Object.prototype.toString.call(obj);
	return (  s === "[object Object]");
}
VerifyObject = function (obj) {
	if (!IsObject(obj))
		throw new ShellExecutorException("'obj' is not a valid object", obj);
}


/* A Helper function, returns true of the given parameter is an array */
IsArray = function (obj) {
	var s = Object.prototype.toString.call(obj);
	return (  s === "[object Array]");
}
VerifyArray = function (obj) {
	if (!IsArray(obj))
		throw new ShellExecutorException("'obj' is not a valid array", obj);
}

/* A Helper function to verify that a given object has only the allowed keys.
   The function throws 'ShellExecutorException' if it finds a disallowed key.

   Example:
	a = { "foo" : "bar", "baz" : [1,2,3,4,5] };
	VerifyAllowedKeys(a, ["foo","baz"]); //Will succeed
	VerifyAllowedKeys(a, ["foo"]); //Will throw exception: "baz" is not an allowed key
*/
VerifyAllowedKeys = function(obj, allowed_keys_array) {
	VerifyObject(obj);

	/* Create a hash of allowed keys */
	var allowed_keys = {};
	for (var i in allowed_keys_array) {
		allowed_keys[allowed_keys_array[i]] = 1 ;
	}

	/* Iterate over keys in obj */
	for (var key in obj) {
		var ok = (key in allowed_keys);
		if (! (key in allowed_keys) )
			throw new ShellExecutorException(
				":'obj' contains disallowed key '" + key + "'" +
				" allowed-keys = '" + allowed_keys_array.toString() + "'" ,obj);
	}
}

/* A Helper function to verify a hash contains just one key.
   The function throws if there are ZERO keys, or two-or-more keys.

   Example:
	VerifyOneKey( { "foo": [1,2,3,4] } ); // OK
	VerifyOneKey( { } ) ; // throws
	VerifyOneKey( { "foo" : 4, "bar": 43 } ) ; //throws
*/
VerifyOneKey = function(obj) {
	VerifyObject(obj);

	if (Object.keys(obj).length==0)
		throw new ShellExecutorException("'obj' is empty", obj);
	if (Object.keys(obj).length>1)
		throw new ShellExecutorException("'obj' contains more than one key", obj);
}

/* A Helper function to return the name of the one key in an object.
   The function will throw if the objecct doesn't have keys, or have more
   than more key.

   Example:
	GetOneKey( { "foo" : [1,2,3,4] } ); //returns "foo"
	GetOneKey( { } ); //throws
	GetOneKey( { "foo": 3, "bar": [1,2,3,4] } ); //throws.
*/
GetOneKey = function(obj) {
	VerifyOneKey(obj);
	for (var key in obj) {
		return key;
	}
}
