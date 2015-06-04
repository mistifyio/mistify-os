#+
# Handle the external toolchain options for the buildmistify script including
# building and installing the external toolchain. This version uses
# uses crosstools-NG and builds the toolchain uses sources fetched from the
# crosstools-NG git repository.
#
# This script is intended to be sourced by the buildmistify script.
#-
config-toolchain () {
    cd $1
    run ./bootstrap
    run ./configure --enable-local --prefix=$1
    run make
}

build-toolchain () {
    #+
    # Now configure and build the toolchain.
    #-
    if [ ! -f $toolchainconfigured ]; then
	message "Configuring the toolchain build."
	config-toolchain $toolchaindir
	touch $toolchainconfigured
    fi
    cp $tcconfig $tcc
    message "Config file $tcconfig copied to $tcc"
    mkdir -p $TC_LOCAL_TARBALLS_DIR
    cd $toolchaindir
    time $ctng build 2>&1 | tee $logdir/tc-`date +%y%m%d%H%M%S`.log
    tail build.log | grep "Build completed"

    if [ $? -gt 0 ]; then
	die "The toolchain build failed."
    fi
}

install-toolchain () {
    if [ -n "$toolchainreset" ]; then
	for d in tcconfig tcuri toolchaindir toolchainprefix toolchainversion
	do
	    verbose Resetting default: $d
	    reset_build_default $d
	done
    fi
    tcconfigdefault=$(get_build_default tcconfig $PWD/configs/mistify-tc.config)
    tcuridefault=$(get_build_default tcuri git@github.com:crosstool-ng/crosstool-ng.git)
    toolchaindirdefault=$(get_build_default toolchaindir $PWD/toolchain)
    toolchainprefixdefault=$(get_build_default toolchainprefix x86_64-unknown-linux-gnu)
    #+
    # TODO: toolchaintversion needs to be updated at release time to use the tag corresponding
    # to the release.
    #-
    toolchainversiondefault=$(get_build_default toolchainversion crosstool-ng-1.21.0)

    #+
    # Determine the location of the toolchain directory.
    #-
    if [ -z "$toolchaindir" ]; then
	toolchaindir=$toolchaindirdefault
    fi
    message "Using toolchain located at: $toolchaindir"
    #+
    # Determine the toolchain variation to use.
    #-
    if [ -z "$toolchainprefix" ]; then
	toolchainprefix=$toolchainprefixdefault
    fi
    message "Using toolchain variation: $toolchainprefix"
    #+
    # Determine the uri to use to fetch the toolchain source.
    #-
    if [ -z "$tcuri" ]; then
	tcuri=$tcuridefault
    fi
    message "The toolchain build tool repository is: $tcuri"

    if [ -z "$toolchainversion" ]; then
	toolchainversion=$toolchainversiondefault
    fi
    message "The toolchain version is: $toolchainversion"

    if [ ! -f $toolchaindir/README ]; then
	message 'Cloning toolchain build tool from the toolchain repository.'
	git clone $tcuri $toolchaindir
	#+
	# TODO: It is possible that the previous clone failed. Might want to use
	# git again to update just in case.
	#-
	if [ $? -gt 0 ]; then
	    die "Cloning the toolchain encountered an error."
	fi
    fi
    cd $toolchaindir

    verbose toolchainversion is: $toolchainversion
    message "Fetching toolchain update from remote repository."
    git fetch

    run git checkout $toolchainversion
    if [ $? -ne 0 ]; then
	die "Attempted to checkout the toolchain build tool using an invalid ID: $toolchainversion"
    fi
    #+
    # If on a branch then pull the latest changes.
    #-
    run_ignore git symbolic-ref --short HEAD
    if [ $? -eq 0 ]; then
	message Updating from branch: $toolchainversion
	run git pull
    else
	message Toolchain version $toolchainversion is not a branch. Not updating.
    fi
    #+
    # Setup the correct toolchain config file.
    #-
    if [ -z "$tcconfig" ]; then
	if [ -f $statedir/tcconfig ]; then
	    tcconfig=`cat $statedir/tcconfig`
	else
	    tcconfig=$tcconfigdefault
	fi
    fi
    message "The toolchain config file is: $tcconfig"
    echo $tcconfig >$statedir/tcconfig

    #+
    # These variables are used within the crosstool-ng config file which helps
    # avoid having to modify the config when changing toolchain branches or
    # tags.
    #-
    export TC_ARCH_SUFFIX=-$toolchainversion
    export TC_PREFIX=$toolchainprefix
    export TC_PREFIX_DIR=$toolchaindir/variations/$toolchainversion
    export TC_LOCAL_TARBALLS_DIR=$downloaddir
    toolchainkernelheaders=`grep CT_KERNEL_VERSION $tcconfig | cut -d \" -f 2`
    message "TC_ARCH_SUFFIX: $TC_ARCH_SUFFIX"
    message "TC_PREFIX_DIR: $TC_PREFIX_DIR"
    message "TC_LOCAL_TARBALLS_DIR: $TC_LOCAL_TARBALLS_DIR"
    message "Toolchain kernel headers version is: $toolchainkernelheaders"

    ctng="./ct-ng"
    tcc=$toolchaindir/.config

    toolchainconfigured=$TC_PREFIX_DIR/../.$toolchainversion-configured
    toolchainbuilt=$TC_PREFIX_DIR/../.$toolchainversion-built

    if [[ "$target" == "toolchain-menuconfig" ]]; then
	cd $toolchaindir
	if [ ! -f $ctng ]; then
	    config-toolchain $toolchaindir
	fi
	$ctng menuconfig
	if [[ ! -f $tcconfig || $tcc -nt $tcconfig ]]; then
	    ls -l $tcc $tcconfig
	    cp $tcc $tcconfig
	    if [ $? -gt 0 ]; then
		die "Failed to save $tcconfig"
	    else
		rm $toolchainbuilt
		message "Toolchain config file has been saved to: $tcconfig"
		message "Run ./buildmistify to rebuild the toolchain."
	    fi
	fi
	exit 0
    fi
    if [ -f $tcc ]; then
	if [ -f $tcconfig ]; then
	    diff $tcconfig $tcc >/dev/null
	    if [ $? -gt 0 ]; then
		warning "The toolchain configuration has changed -- rebuilding the toolchain."
		rm -f $toolchainbuilt
	    fi
	    echo $tcconfig >$statedir/tcconfig
	    if [ ! -f $toolchainbuilt ]; then
	        build-toolchain
		touch $toolchainbuilt
		return 1
	    fi
	else
	    error "The toolchain config file doesn't exist."
	    message "Run ./buildmistify toolchain-menuconfig."
	    exit 1
	fi
    fi
    #+
    # Don't build the toolchain if it has already been built.
    #-
    if [ -f $toolchainbuilt ]; then
	    message "Using toolchain installed at: $TC_PREFIX_DIR"
	    return 0
    fi
    #+
    # Download, build and install the toolchain.
    #-
    message "Toolchain not built."
    message "Installing toolchain to: $TC_PREFIX_DIR"

    if [ -n "$dryrun" ]; then
	message "Just a test run -- not building the toolchain."
	verbose "$ctng build"
    else
	build-toolchain
	touch $toolchainbuilt
	verbose Saving toolchain build settings.
	set_build_default tcconfig $tcconfig
	set_build_default tcuri $tcuri
	set_build_default toolchaindir $toolchaindir
	set_build_default toolchainprefix $toolchainprefix
	set_build_default toolchainversion $toolchainversion
    fi
    return 0
}
