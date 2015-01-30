#+
# Some standard functions for Mistify-OS scripts.
#-
projectdir=$PWD	# Save this directory for later.
# Where to maintain buildmistify settings.
statedir=$projectdir/.buildmistify

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

