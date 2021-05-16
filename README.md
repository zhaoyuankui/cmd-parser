# cmd-parser
A light-weight Bash shell library for command line parsing.

## Requirements
Bash 4+ for associative array used for flags.

## Features
1. Support command and sub-command, at most two levels.
2. Support flags, short and long format.
3. Support flag terminator '--'.
4. Support any parameters at the tail.

## Example
example.sh
```bash
#!/bin/bash

source ./cmd_paraser.sh;

# The api of cmd_paraser.sh
commands=(list set);
sub_commands=(add del);
debug_switch=on;
# If set, and if the command is not given, it will be the default command
default_command=list;
# If set, it will be used for logging
#logger=;
parse_command "${@}"
```
### Case1
Run
`$ bash example.sh list add --silent -type fruit apple banana orange 'water melon'`,
the default std_logger output would be:
>commond line: example.sh list add --silent -type fruit apple banana orange water melon<br/>
command: list, sub command: add<br/>
flags: { 'silent' -> '', 'type' -> 'fruit' }<br/>
parameters: [ 'apple' 'banana' 'orange' 'water melon' ]

### Case2
For testing the flag terminator, run
`bash example.sh list add -type fruit --slient -- apple banana orange 'water melon'`,
the output would be the same as case1.
### Case3
For short format flags, run
`bash example.sh list add -t fruit -s -- apple banana orange 'water melon'`,
and gets output:
>commond line: example.sh list add -t fruit -s -- apple banana orange water melon<br/>
command: list, sub command: add<br/>
flags: { 't' -> 'fruit', 's' -> '' }<br/>
parameters: [ 'apple' 'banana' 'orange' 'water melon' ]
### Case4
For testing default command, run
`bash example.sh  --silent -type fruit apple banana orange 'water melon'`,
and the output is:
>commond line: example.sh --silent -type fruit apple banana orange water melon<br/>
command: list, sub command:<br/>
flags: { 'silent' -> '', 'type' -> 'fruit' }<br/>
parameters: [ 'apple' 'banana' 'orange' 'water melon' ]

## API
As you can see in the examples, the input of parse_command should be:
1. commands - the commands array, used for distincting from ordinary parameters, e.g.:
  declare -a commands=(node ban);
2. sub_commands - the sub-commands array, used for distincting from ordinary parameters, e.g.:
  declare -a sub_commands=(add del);
3. logger - the logger to log message
4. default_command - the default command if no command assigned
5. debug_switch=on|off - the debug switch, if switch on, it will print logs to logger, or the default std_logger, if switched off, it will be silent.

In which the commands and sub_commands should always be initialized, and others are optional.

The output of parse_command would be:
1. declare cmd=;
2. declare sub_cmd=;
3. declare -A flags=();
4. declare -a parameters=();

It's very simple to know what are they mean from literal, only to notice the **flags** is an associative array.

## Notice
1. If the last flag has no value later on(i.e. a boolean flag), the flag terminator should be given.
2. Make sure to initialize the commands and sub_commands array, or else it won't work as expect.
