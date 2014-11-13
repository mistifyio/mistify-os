#+
# Some standard functions for Mistify-OS scripts.
#-

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
    # TODO: Add a test for a verbose flag.
    echo >&2 -e "$lightblue$id$nc: $*"
}

function die() {
    error "$@"
    exit 1
}

function run() {
    # : This message can be removed or used with a verbose flag.
    verbose "Running: '$@'"
    "$@"; code=$?; [ $code -ne 0 ] && die "Command [$*] failed with error code $code"; 
}

is_mounted () {
    mount | grep $1
    return $?
}

projectdir=$PWD	# Save this directory for later.
# Where to maintain buildmistify settings.
statedir=$projectdir/.buildmistify

