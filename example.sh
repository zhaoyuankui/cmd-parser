#!/bin/bash

source ./cmd_paraser.sh;

# The api input of cmd_paraser.sh
commands=(list set);
sub_commands=(add del);
debug_switch=on;
# If set, and if the command is not given, it will be the default command
default_command=list;
# If set, it will be used for logging
#logger=;

parse_command "${@}"

################ Results ################
# echo "command: $cmd";

# echo "sub-command: $sub_cmd";

#declare flags_str=;
#for k in ${!flags[@]}; do
#    declare v="${flags[$k]}";
#    flags_str="$flags_str, '$k' -> '$v'";
#done
#flags_str="${flags_str#, }";
#echo "flags: { $flags_str }";

#param_str=;
#for param in "${parameters[@]}"; do
#    param_str="$param_str '$param'";
#done
#param_str="${param_str# }"
#$logger "parameters: [ $param_str ]";
