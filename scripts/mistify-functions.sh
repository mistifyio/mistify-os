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
    echo -e "$green$id$red ERROR$nc: $*"
}

projectdir=$PWD	# Save this directory for later.
# Where to maintain buildmistify settings.
statedir=$projectdir/.buildmistify

