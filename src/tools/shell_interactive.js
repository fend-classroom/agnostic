/****************************************
 * This file is part of UNIX Guide for the Perplexed project.
 * Copyright (C) 2014 by Assaf Gordon <assafgordon@gmail.com>
 * Released under GPLv3 or later.
 ****************************************/

/*
An interactive shell Emulator
*/

"use strict";

var assert = require('assert');
var readline = require('readline');

var load_shell_parser = require('utils/shell_parser_loader');
var shell_parser = load_shell_parser();

var InteractiveShell = require('shell/shell_interactive');

var shell = new InteractiveShell(shell_parser);

//
// Prompt loop starts here
//
var rl = readline.createInterface(process.stdin, process.stdout);
rl.setPrompt('$ ');
rl.prompt();

rl.on('line', function(line) {
	var result = shell.execute(line);
	if ( 'stdout' in result )
		console.log(result.stdout.join("\n"));
	if ( 'stderr' in result )
		console.error(result.stderr.join("\n"));

	rl.prompt();
}).on('close', function() {
  process.exit(0);
});

