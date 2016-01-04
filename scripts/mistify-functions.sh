#+
# Some standard functions for Mistify-OS scripts.
#-
projectdir=$PWD    # Save this directory for later.
# Where to maintain buildmistify settings.
statedir=$builddir/.buildmistify

# Which branch this script is running with.
mistifybranch=`git symbolic-ref -q --short HEAD`
# Jenkins detaches for branches so need to use a commit ID instead.
if [ -z "$mistifybranch" ]; then
    mistifybranch=`git rev-parse HEAD`
fi

function get_build_default() {
    # Parameters:
    #   1: option name
    #   2: default value
    if [ -e $statedir/$1 ]; then
        r=`cat $statedir/$1`
    else
        verbose Setting ${e[0]} to default: ${e[1]}
        r=$2
    fi
    verbose The variable $1 equals $2
    echo $r
}

function set_build_default() {
    # Parameters:
    #   1: option name
    #   2: value
    if [ ! -d $statedir ]; then
        verbose Creating the state directory: $statedir
        mkdir -p $statedir
    fi
    echo "$2">$statedir/$1
    verbose The default $1 has been set to $2
}

function reset_build_default() {
    # Parameters:
    #   1: option name
    if [ -e $statedir/$1 ]; then
        rm $statedir/$1
        verbose Option $1 default has been reset.
    else
        verbose Option $1 default has not been set.
    fi
}

function init_build_variable() {
    # Parameters:
    #	1: variable name and default value pair delimited by the delimeter (2)
    #   2: an optional delimeter character (defaults to '=')
    if [ -z "$2" ]; then
        d='='
    else
        d=$2
    fi
    e=(`echo "$1" | tr "$d" " "`)
    verbose ""
    verbose State variable default: "${e[0]} = ${e[1]}"
    eval val=\$${e[0]}
    if [ -z "$val" ]; then
        eval ${e[0]}=$(get_build_default ${e[0]} ${e[1]})
    else
        if [ "$val" = "default" ]; then
            verbose Setting ${e[0]} to default: ${e[1]}
            eval ${e[0]}=${e[1]}
        else
            eval ${e[0]}=$val
        fi
    fi
    eval val=\$${e[0]}
    verbose "State variable: ${e[0]} = $val"
    verbose Saving current settings.
    set_build_default ${e[0]} $val
}

function clear_build_variable() {
    # Parameters:
    #	1: variable name and default value pair delimited by the delimeter (2)
    #   2: an optional delimeter character (defaults to '=')
    if [ -z "$2" ]; then
        d='='
    else
        d=$2
    fi
    e=(`echo "$1" | tr "$d" " "`)
    verbose ""
    verbose Clearing state variable: ${e[0]}
    reset_build_default ${e[0]}
}


green='\e[0;32m'
yellow='\e[0;33m'
red='\e[0;31m'
blue='\e[0;34m'
lightblue='\e[1;34m'
white='\e[1;37m'
nc='\e[0m'
id=$(basename $0)

message () {
    echo -e "$green$id$nc: $*"
}

tip () {
    echo -e "$green$id$nc: $white$*$nc"
}

warning () {
    echo -e "$green$id$yellow WARNING$nc: $*"
}

error () {
    echo >&2 -e "$green$id$red ERROR$nc: $*"
}

verbose () {
    if [[ "$verbose" == "y" ]]; then
        echo >&2 -e "$lightblue$id$nc: $*"
    fi
}

function die() {
    error "$@"
    exit 1
}

function run() {
    verbose "Running: '$@'"
    "$@"; code=$?; [ $code -ne 0 ] && die "Command [$*] failed with status code $code";
    return $code
}

function run_ignore {
    verbose "Running: '$@'"
    "$@"; code=$?; [ $code -ne 0 ] && verbose "Command [$*] returned status code $code";
    return $code
}

function confirm () {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

is_mounted () {
    mount | grep $1
    return $?
}
