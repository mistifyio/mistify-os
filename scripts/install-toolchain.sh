#+
# Handle the external toolchain options for the buildmistify script including
# building and installing the external toolchain. This version uses
# uses crosstools-NG and builds the toolchain uses sources fetched from the
# crosstools-NG git repository.
#
# This script is intended to be sourced by the buildmistify script.
#-
#+
# TODO: toolchaintag needs to be updated at release time to use the tag corresponding
# to the release.
#-
tcconfigdefault=$PWD/configs/mistify-tc.config
tcuridefault=git@github.com:crosstool-ng/crosstool-ng.git
toolchaindirdefault=$PWD/toolchain
toolchainprefixdefault=x86_64-unknown-linux-gnu
toolchainbranchdefault="master"
toolchaintagdefault=

config-toolchain () {
    cd $1
    run ./bootstrap
    run ./configure --enable-local --prefix=$1
    run make
}

install-toolchain () {
    #+
    # Determine the location of the toolchain directory.
    #-
    if [ -z "$toolchaindir" ]; then
	if [ -f $statedir/toolchaindir ]; then
	    toolchaindir=`cat $statedir/toolchaindir`
	else
	    toolchaindir=$toolchaindirdefault
	fi
	message "Using toolchain located at: $toolchaindir"
    fi
    echo $toolchaindir >$statedir/toolchaindir
    #+
    # Determine the toolchain variation to use.
    #-
    if [ -z "$toolchainprefix" ]; then
	if [ -f $statedir/toolchainprefix ]; then
	    toolchainprefix=`cat $statedir/toolchainprefix`
	else
	    toolchainprefix=$toolchainprefixdefault
	fi
	message "Using toolchain variation: $toolchainprefix"
    fi
    echo $toolchainprefix >$statedir/toolchainprefix
    #+
    # Determine the uri to use to fetch the toolchain source.
    #-
    if [ -z "$tcuri" ]; then
	if [ -f $statedir/tcuri ]; then
	    tcuri=`cat $statedir/tcuri`
	else
	    tcuri=$tcuridefault
	fi
    fi
    message "The toolchain build tool repository is: $tcuri"
    echo $tcuri >$statedir/tcuri

    #+
    # If the toolchainbranch option is used then ignore the toolchaintag option.
    # NOTE: Specifying a branch overrides using a tag.
    #-
    if [ ! -z "$toolchainbranch" ]; then
	message "Switching to toolchain build tool branch: $toolchainbranch"
	if [ ! -z "$toolchaintag" ]; then
	    warning "Ignoring --toolchaintag"
	    toolchaintag=
	fi
	rm -f $statedir/toolchaintag
    else
	if [ -f $statedir/toolchainbranch ]; then
	    toolchainbranch=`cat $statedir/toolchainbranch`
	else
	    toolchainbranch=$toolchainbranchdefault
	fi
    fi
    echo $toolchainbranch >$statedir/toolchainbranch

    if [ ! -f $toolchaindir/README ]; then
	message 'Fetching toolchain build tool branch "master" from the toolchain repository.'
	git clone $tcuri $toolchaindir
	#+
	# TODO: It is possible that the previous clone failed. Might want to use
	# git again to update just in case.
	#-
	if [ $? -gt 0 ]; then
	    error "Fetching the toolchain encountered an error."
	    exit 1
	fi
    fi
    cd $toolchaindir

    #+
    # Determine the tag to use to sync toolchain to.
    # NOTE: Having branch and tag separate helps avoid an ambiguity which could
    # result in accidentally creating a branch when a tag was intended.
    # NOTE: If toolchaintag is set at this point then it wasn't overridden by  
    # specifying a branch.
    #-
    if [ ! -z "$toolchaintag" ]; then
	toolchainbranch=
	message "Switching to toolchain build tool tag: $toolchaintag"
	echo $toolchaintag >$statedir/toolchaintag
    else
	if [ -f $statedir/toolchaintag ]; then
	    toolchainbranch=
	    toolchaintag=`cat $statedir/toolchaintag`
	fi
    fi

    #+
    # Verify using the desired toolchain version. If the branch or tag doesn't exist
    # locally then fetch an update from the repo.
    #-
    if [ ! -z "$toolchaintag" ]; then
	message "Using toolchain tag: $toolchaintag"
	git tag | grep $toolchaintag
	if [ $? -ne 0 ]; then
	    message "Local toolchain build tool tag $toolchaintag doesn't exist."
	    message "Fetching toolchain update from remote repository."
	    git fetch
	fi
	toolchainlabel="tags/$toolchaintag"
    else
	message "Using toolchain build tool branch: $toolchainbranch"
	git branch | grep $toolchainbranch
	if [ $? -ne 0 ]; then
	    message "Local toolchain branch $toolchainbranch doesn't exist."
	    message "Fetching update from remote toolchain repository."
	    git fetch
	fi
	toolchainlabel=$toolchainbranch
    fi

    git checkout $toolchainlabel
    if [ $? -ne 0 ]; then
	error "Attempted to checkout the toolchain build tool using an invalid tag or branch: $toolchainlabel"
	exit 1
    fi
    message "The toolchain build tool synced to: $toolchainlabel"

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
    export TC_ARCH_SUFFIX=-$toolchainlabel
    export TC_PREFIX_DIR=$toolchaindir/variations/$toolchainlabel
    export TC_LOCAL_TARBALLS_DIR=$downloaddir
    toolchainkernelheaders=`grep CT_KERNEL_VERSION $tcconfig | cut -d \" -f 2`
    message "TC_ARCH_SUFFIX: $TC_ARCH_SUFFIX"
    message "TC_PREFIX_DIR: $TC_PREFIX_DIR"
    message "TC_LOCAL_TARBALLS_DIR: $TC_LOCAL_TARBALLS_DIR"
    message "Toolchain kernel headers version is: $toolchainkernelheaders"

    ctng="./ct-ng"
    tcc=$toolchaindir/.config

    if [ -f $tcc ]; then
	if [ -f $tcconfig ]; then
	    if [[ $tcconfig -nt $tcc ]]; then
		if [ $? -gt 0 ]; then
		    warning "The toolchain hasn't been built yet."
		fi
		message "Config file $tcconfig copied to $tcc"
		echo $tcconfig >$statedir/tcconfig
	    fi
	else
	    if [[ "$target" != "toolchain-menuconfig" ]]; then
		error "The toolchain config file doesn't exist."
		message "Run ./buildmistify toolchain-menuconfig."
		exit 1
	    fi
	fi
    fi
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
		error "Failed to save $tcconfig"
		exit 1
	    else
		#rm $TC_PREFIX_DIR/../.$toolchainlabel-built
		message "Toolchain config file has been saved to: $tcconfig"
		message "Run ./buildmistify to rebuild the toolchain."
	    fi
	fi
	exit 0
    fi
    #+
    # Don't build the toolchain if it has already been built. If
    if [ -f $TC_PREFIX_DIR/../.$toolchainlabel-built ]; then
	    message "Using toolchain installed at: $TC_PREFIX_DIR"
	    return
    fi
    #+
    # Download, build and install the toolchain.
    #-
    message "Toolchain not detected."
    message "Installing toolchain to: $TC_PREFIX_DIR"

    #+
    # Now configure and build the toolchain.
    #-
    config-toolchain $toolchaindir
    cp $tcconfig $tcc
    mkdir -p $TC_LOCAL_TARBALLS_DIR
    cd $toolchaindir
    $ctng build
    if [ $? -gt 0 ]; then
	error "The toolchain build failed."
	exit 1
    fi
    touch $TC_PREFIX_DIR/../.$toolchainlabel-built
}
