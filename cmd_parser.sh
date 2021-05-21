#!/bin/bash
# Requirements:
#     Minimum Bash version 4 for associative array.
# API:
## logger - the logger to log message
## default_command - the default command if no command assigned
## commands - the commands array, used for distincting from ordinary parameters, e.g.:
###  declare -a commands=(node ban);
## sub_commands - the sub-commands array, used for distincting from ordinary parameters, e.g.:
###  declare -a sub_commands=(add del);
## debug_switch=on|off - the debug switch, if switch on, it will print logs to logger,
##                       or the default std_logger, if switched off, it will be silent.

# API output
declare cmd=;
declare sub_cmd=;
declare -A flags=();
declare -a parameters=();

function parse_command() {
    init;

    $logger "commond line: $0 ""${@}";
    if [ "$1" ] && [[ ${commands[@]/$1/} != ${commands[@]} ]]; then
        cmd="$1";
        shift;
        if [ "$1" ] && [[ ${sub_commands[@]/$1/} != ${sub_commands[@]} ]]; then
            sub_cmd="$1";
            shift;
        fi
    fi
    if [ ! "$cmd" ]; then
        cmd="$default_command";
    fi
    $logger "command: $cmd, sub command: $sub_cmd";

    while [ $# -gt 0 ]; do
        if [ "$1" == '--' ]; then
            shift;
            parameters=("${@}");
            break;
        elif [[ "$1" != '-'* ]]; then
            parameters=("${@}");
            break;
        fi
        declare -i idx=0;
        if [[ "$1" == '--'* ]]; then
            idx=2;
        elif [[ "$1" == '-'* ]]; then
            idx=1;
        fi
        if [ $idx -gt 0 ]; then
            if [ "$2" ] && [[ "$2" != '-'* ]]; then
                flags[${1:$idx}]="$2";
                shift 2;
            else
                flags[${1:$idx}]='';
                shift;
            fi
        fi
    done
    log_flags;
    log_parameters;
}

function init() {
    cmd=;
    sub_cmd=;
    flags=();
    parameters=();
    if [ ! "$logger" ]; then
        if [ "$debug_switch" == "on" ]; then
            logger=std_logger;
        else
            logger=mute_logger;
        fi
    fi
}

function log_flags() {
    if [ "$logger" == 'mute_logger' ]; then
        return;
    fi
    declare flags_str=;
    for k in ${!flags[@]}; do
        declare v="${flags[$k]}";
        flags_str="$flags_str, '$k' -> '$v'";
    done
    flags_str="${flags_str#, }";
    $logger "flags: { $flags_str }";
}

function log_parameters() {
    if [ "$logger" == 'mute_logger' ]; then
        return;
    fi
    param_str=;
    for param in "${parameters[@]}"; do
        param_str="$param_str '$param'";
    done
    param_str="${param_str# }"
    $logger "parameters: [ $param_str ]";
}

function mute_logger() {
    return;
}

function std_logger() {
    echo "${@}";
}

function expect_eq() {
    test "$1" == "$2" || $logger "[ERROR] expect '$1' equals '$2'";
}

function test_parse_command() {
    debug_switch=on;
    commands=(list ban);
    sub_commands=(add del purge);

    parse_command;
    expect_eq '' "$cmd";
    expect_eq '' "$sub_cmd";
    expect_eq 0 ${#flags[@]};
    expect_eq 0 ${#parameters[@]};

    parse_command list;
    expect_eq 'list' "$cmd";
    expect_eq '' "$sub_cmd";
    expect_eq 0 ${#flags[@]};
    expect_eq 0 ${#parameters[@]};

    parse_command list purge;
    expect_eq 'list' "$cmd";
    expect_eq 'purge' "$sub_cmd";
    expect_eq 0 ${#flags[@]};
    expect_eq 0 ${#parameters[@]};

    parse_command list aaa bbb ccc;
    expect_eq 'list' "$cmd";
    expect_eq '' "$sub_cmd";
    expect_eq 0 ${#flags[@]};
    expect_eq 3 ${#parameters[@]};
    expect_eq aaa ${parameters[0]};
    expect_eq bbb ${parameters[1]};
    expect_eq ccc ${parameters[2]};

    parse_command list add aaa bbb ccc;
    expect_eq 'list' "$cmd";
    expect_eq 'add' "$sub_cmd";
    expect_eq 0 ${#flags[@]};
    expect_eq 3 ${#parameters[@]};
    expect_eq aaa ${parameters[0]};
    expect_eq bbb ${parameters[1]};
    expect_eq ccc ${parameters[2]};

    parse_command ban add -t host 192.168.1.1;
    expect_eq ban "$cmd";
    expect_eq add "$sub_cmd";
    expect_eq host ${flags[t]};
    expect_eq 192.168.1.1 ${parameters[0]};

    parse_command ban add -t srv -z hk 192.168.1.1:9900 192.168.1.2:9900;
    expect_eq ban "$cmd";
    expect_eq add "$sub_cmd";
    expect_eq srv ${flags[t]};
    expect_eq hk ${flags[z]};
    expect_eq 192.168.1.1:9900 ${parameters[0]};
    expect_eq 192.168.1.2:9900 ${parameters[1]};

    # with flags terminator
    parse_command ban add -t srv -z hk -s -- 192.168.1.1:9900 192.168.1.2:9900;
    expect_eq ban "$cmd";
    expect_eq add "$sub_cmd";
    expect_eq 3 ${#flags[@]};
    expect_eq srv ${flags[t]};
    expect_eq hk ${flags[z]};
    expect_eq '' ${flags[s]};
    expect_eq 192.168.1.1:9900 ${parameters[0]};
    expect_eq 192.168.1.2:9900 ${parameters[1]};

    # with long flags
    parse_command ban add -t srv --zone hk --silent -- 192.168.1.1:9900 192.168.1.2:9900;
    expect_eq ban "$cmd";
    expect_eq add "$sub_cmd";
    expect_eq 3 ${#flags[@]};
    expect_eq srv ${flags[t]};
    expect_eq hk ${flags[zone]};
    expect_eq '' ${flags[silent]};
    expect_eq 192.168.1.1:9900 ${parameters[0]};
    expect_eq 192.168.1.2:9900 ${parameters[1]};

    # with quoted flags and parameters
    parse_command list add -t srv --zone hk --name 'HongKong services' --silent -- 192.168.1.1:9900 192.168.1.2:9900 'user service';
    expect_eq list "$cmd";
    expect_eq add "$sub_cmd";
    expect_eq 4 ${#flags[@]};
    expect_eq srv ${flags[t]};
    expect_eq hk ${flags[zone]};
    expect_eq 'HongKong services' "${flags[name]}";
    expect_eq '' ${flags[silent]};
    expect_eq 3 ${#parameters[@]};
    expect_eq 192.168.1.1:9900 ${parameters[0]};
    expect_eq 192.168.1.2:9900 ${parameters[1]};
    expect_eq 'user service' "${parameters[2]}";

}

if [ "`caller | awk '{print $1}'`" == '0' ]; then
    test_parse_command;
fi
