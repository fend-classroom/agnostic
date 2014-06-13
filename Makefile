NODEBIN ?= nodejs

CMDDEMO1="sort -k1n,1 -u input.txt"
CMDDEMO2="grep -i FOO <input.txt >output.txt"
CMDDEMO3="LC_ALL=C sort -k5nr,5 input.txt >output.txt"
CMDDEMO4='cut -f1-5 -d"|" foo.txt | grep -v ^bar | wc -l'
CMDDEMO5='grep -q FOO bar.txt && echo found || echo not-found'

# This file will be generated by PEG
SHELL_PARSER=./src/node_modules/shell/posix_shell_parser.js

# These files will be generated by Browserify
AGNOSTIC_BUNDLE=./src/node_modules/agnostic_web_bundle.js
AGNOSTIC_BUNDLE_MINIFIED=./src/node_modules/agnostic_web_bundle.min.js

SHELL_PARSE_TOOL=./src/tools/shell_parse.js
SHELL_EXECUTOR_LOG=./src/tools/shell_executor_log.js

all: info

.PHONY: info
info:
	@echo "The following targets are available:"
	@echo ""
	@echo "  make check    -     Run tests"
	@echo "  make web      -     Create required Javascript for website"
	@echo ""
	@echo "Shell Syntax Parsing Examples:"
	@echo "  make ex1p -     a simple command"
	@echo "  make ex2p -     a command with redirection"
	@echo "  make ex3p -     a command variable assignment and redirection"
	@echo "  make ex4p -     commands with pipes"
	@echo "  make ex5p -     commands with &&, ||"
	@echo ""
	@echo "Shell Executor Examples:"
	@echo "  make ex1e -     a simple command"
	@echo "  make ex2e -     a command with redirection"
	@echo "  make ex3e -     a command variable assignment and redirection"
	@echo "  make ex4e -     commands with pipes"
	@echo "  make ex5e -     commands with &&, ||"


.PHONY: clean
clean:
	rm -f $(SHELL_PARSER) $(SHELL_PARSER).tmp
	rm -f $(AGNOSTIC_BUNDLE) $(AGNOSTIC_BUNDLE).tmp $(AGNOSTIC_BUNDLE).deps
	rm -f $(AGNOSTIC_BUNDLE_MINIFIED) $(AGNOSTIC_BUNDLE_MINIFIED).tmp


## This rule compiles the Shell POSIX Parser
## (written in PegJS syntax) into a javascript source file,
## with the exported variable 'posix_shell_parser'
##
## NOTE: PegJS generates an empty file, even if compilation failed.
##       The empty file will be newer than the source '.pegjs' file,
##       which messes-up Make's timestamp detection.
##       Using a 'tmp' file prevents this from being an issue.
$(SHELL_PARSER): ./src/shell_parser/posix_shell.pegjs
	@rm -f $(SHELL_PARSER) $(SHELL_PARSER).tmp
	@pegjs "$<" "$@.tmp"
	@mv "$@.tmp" "$@"



##
## These rules generate the Agnostic "Browserified" bundle,
## using "Browserify" starting from './src/node_modules/agnostic.js'.
## See below the rules 'test_agnostic_bundle_browserified' and
## 'test_agnostic_bundle_minified' which test these generated files.
##

## This rule generate a dependency list, so that later
##  'make' invocation can detect when the bundle needs to be rebuilt.
-include $(AGNOSTIC_BUNDLE).deps
$(AGNOSTIC_BUNDLE).deps: $(SHELL_PARSER)
	@(browserify -s agnostic --list ./src/node_modules/agnostic.js | \
	    tr '\n' ' ' | \
	    sed 's;^;$(AGNOSTIC_BUNDLE): ;' > "$@")

## This rule uses 'browserify' to list all the source files that will be
## bundled with 'Agnostic' - and verify no external (e.g. NodeJS's) files are used.
.PHONY: agnostic_bundle_verify_no_external_sources
agnostic_bundle_verify_no_external_sources:
	@( \
	FILES=$$(browserify -s agnostic --list ./src/node_modules/agnostic.js) ; \
	if echo "$$FILES" | grep -qv "^$$PWD" ; then \
		echo "Error: Agnostic bundle (./src/node_modules/aggnostic.js) uses external files" >&2 ; \
		echo "$$FILES" | grep -v "^$$PWD" ; \
		exit 1; \
	fi ; \
	)

## This rule builds the bundled javascript file
$(AGNOSTIC_BUNDLE): agnostic_bundle_verify_no_external_sources $(SHELL_PARSER)
	browserify -s agnostic -o "$@.tmp" ./src/node_modules/agnostic.js
	mv "$@.tmp" "$@"

## This script minifies the bundled javascript
$(AGNOSTIC_BUNDLE_MINIFIED): $(AGNOSTIC_BUNDLE)
	uglifyjs -o "$@.tmp" "$<"
	mv "$@.tmp" "$@"

# An easy-to-type shortcut target
.PHONY: agnostic_bundle
agnostic_bundle: $(AGNOSTIC_BUNDLE_MINIFIED)






.PHONY: web
web: $(SHELL_PARSER) $(AGNOSTIC_BUNDLE_MINIFIED)
	cp $(AGNOSTIC_BUNDLE_MINIFIED) ./website/

.PHONY: check
check: test_object_utils \
       test_string_utils \
       test_path_utils \
       test_shellquote_utils \
       test_getopt \
       test_os_state \
       test_streams \
       test_storage_object \
       test_filesystem \
       test_process_state \
       test_program_base \
       test_program_date \
       test_program_seq \
       test_program_head \
       test_program_tail \
       test_program_cat \
       test_program_cut \
       test_program_echo \
       test_program_true \
       test_program_false \
       test_program_printf \
       test_program_wc \
       test_program_basename \
       test_program_dirname \
       test_pipe \
       test_parse_syntax \
       test_shell_parsers_comparison \
       test_shell_descriptor \
       test_shell_HTML_descriptor \
       test_shell_state \
       test_shell_executor_special_builtin \
       test_shell_executor_variables \
       test_shell_executor_expand_variables \
       test_shell_executor_arithmetics \
       test_shell_interactive \
       test_agnostic_bundle_source \
       test_agnostic_bundle_browserified \
       test_agnostic_bundle_minified

.PHONY: test_parse_syntax
test_parse_syntax:
	$(NODEBIN) ./src/tests/shell_parser_tester.js

.PHONY: test_os_state
test_os_state:
	$(NODEBIN) ./src/tests/os_state_tester.js

.PHONY: test_process_state
test_process_state:
	$(NODEBIN) ./src/tests/process_state_tester.js

.PHONY: test_streams
test_streams:
	$(NODEBIN) ./src/tests/stream_tester.js

.PHONY: test_storage_object
test_storage_object:
	$(NODEBIN) ./src/tests/storage_object_tester.js

.PHONY: test_filesystem
test_filesystem:
	$(NODEBIN) ./src/tests/filesystem_tester.js

.PHONY: test_program_base
test_program_base:
	$(NODEBIN) ./src/tests/program_base_tester.js

.PHONY: test_program_date
test_program_date:
	$(NODEBIN) ./src/tests/program_date_tester.js

.PHONY: test_program_seq
test_program_seq:
	$(NODEBIN) ./src/tests/program_seq_tester.js

.PHONY: test_program_head
test_program_head:
	$(NODEBIN) ./src/tests/program_head_tester.js

.PHONY: test_program_tail
test_program_tail:
	$(NODEBIN) ./src/tests/program_tail_tester.js

.PHONY: test_program_cat
test_program_cat:
	$(NODEBIN) ./src/tests/program_cat_tester.js

.PHONY: test_program_cut
test_program_cut:
	$(NODEBIN) ./src/tests/program_cut_tester.js

.PHONY: test_program_echo
test_program_echo:
	$(NODEBIN) ./src/tests/program_echo_tester.js

.PHONY: test_program_true
test_program_true:
	$(NODEBIN) ./src/tests/program_true_tester.js

.PHONY: test_program_false
test_program_false:
	$(NODEBIN) ./src/tests/program_false_tester.js

.PHONY: test_program_printf
test_program_printf:
	$(NODEBIN) ./src/tests/program_printf_tester.js

.PHONY: test_program_wc
test_program_wc:
	$(NODEBIN) ./src/tests/program_wc_tester.js

.PHONY: test_program_basename
test_program_basename:
	$(NODEBIN) ./src/tests/program_basename_tester.js

.PHONY: test_program_dirname
test_program_dirname:
	$(NODEBIN) ./src/tests/program_dirname_tester.js

.PHONY: test_shell_descriptor
test_shell_descriptor: $(SHELL_PARSER)
	$(NODEBIN) ./src/tests/shell_descriptor_tester.js

.PHONY: test_shell_HTML_descriptor
test_shell_HTML_descriptor: $(SHELL_PARSER)
	$(NODEBIN) ./src/tests/shell_HTML_descriptor_tester.js

.PHONY: test_shell_state
test_shell_state:
	$(NODEBIN) ./src/tests/shell_state_tester.js

.PHONY: test_shell_executor_special_builtin
test_shell_executor_special_builtin:
	$(NODEBIN) ./src/tests/shell_executor_special_buildin_tester.js

.PHONY: test_shell_executor_variables
test_shell_executor_variables:
	$(NODEBIN) ./src/tests/shell_executor_variables.js

.PHONY: test_shell_executor_expand_variables
test_shell_executor_expand_variables:
	$(NODEBIN) ./src/tests/shell_executor_expand_variables.js

.PHONY: test_shell_executor_arithmetics
test_shell_executor_arithmetics:
	$(NODEBIN) ./src/tests/shell_executor_arithmetics.js

.PHONY: test_shell_interactive
test_shell_interactive:
	$(NODEBIN) ./src/tests/shell_interactive.js

.PHONY: test_object_utils
test_object_utils:
	$(NODEBIN) ./src/tests/object_utils_tester.js

.PHONY: test_string_utils
test_string_utils:
	$(NODEBIN) ./src/tests/string_utils_tester.js

.PHONY: test_path_utils
test_path_utils:
	$(NODEBIN) ./src/tests/path_utils_tester.js

.PHONY: test_shellquote_utils
test_shellquote_utils:
	$(NODEBIN) ./src/tests/shellquote_utils_tester.js

.PHONY: test_getopt
test_getopt:
	$(NODEBIN) ./src/tests/getopt_tester.js

.PHONY: test_pipe
test_pipe:
	$(NODEBIN) ./src/tests/pipe_tester.js

.PHONY: test_shell_parsers_comparison
test_shell_parsers_comparison: $(SHELL_PARSER)
	$(NODEBIN) ./src/tests/shell_parsers_comparison_tester.js

.PHONY: test_agnostic_bundle_source
test_agnostic_bundle_source: $(SHELL_PARSER)
	$(NODEBIN) ./src/tests/agnostic_bundle_tester.js agnostic.js

.PHONY: test_agnostic_bundle_browserified
test_agnostic_bundle_browserified: $(AGNOSTIC_BUNDLE) $(SHELL_PARSER)
	$(NODEBIN) ./src/tests/agnostic_bundle_tester.js $(notdir $(AGNOSTIC_BUNDLE))

.PHONY: test_agnostic_bundle_minified
test_agnostic_bundle_minified: $(AGNOSTIC_BUNDLE_MINIFIED) $(SHELL_PARSER)
	$(NODEBIN) ./src/tests/agnostic_bundle_tester.js $(notdir $(AGNOSTIC_BUNDLE_MINIFIED))

.PHONY: ex1p ex2p ex3p ex4p ex5p
ex1p:
	$(NODEBIN) $(SHELL_PARSE_TOOL) $(CMDDEMO1) | jq .

ex2p:
	$(NODEBIN) $(SHELL_PARSE_TOOL) $(CMDDEMO2) | jq .

ex3p:
	$(NODEBIN) $(SHELL_PARSE_TOOL) $(CMDDEMO3) | jq .

ex4p:
	$(NODEBIN) $(SHELL_PARSE_TOOL) $(CMDDEMO4)  | jq .

ex5p:
	$(NODEBIN) $(SHELL_PARSE_TOOL) $(CMDDEMO5) | jq .


.PHONY: ex1e ex2e ex3e ex4e ex5e
ex1e:
	$(NODEBIN) $(SHELL_EXECUTOR_LOG) $(CMDDEMO1)

ex2e:
	$(NODEBIN) $(SHELL_EXECUTOR_LOG) $(CMDDEMO2)

ex3e:
	$(NODEBIN) $(SHELL_EXECUTOR_LOG) $(CMDDEMO3)

ex4e:
	$(NODEBIN) $(SHELL_EXECUTOR_LOG) $(CMDDEMO4)

ex5e:
	$(NODEBIN) $(SHELL_EXECUTOR_LOG) $(CMDDEMO5)
