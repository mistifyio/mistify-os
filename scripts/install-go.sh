#+
# Compile go from source and install it into the previously built toolchain.
#-
gouridefault=https://code.google.com/p/go
godirdefault=$PWD/go
gotagdefault=go1.4

install-go () {
    #+
    # Determine the location of the go directory.
    #-
    if [ -z "$godir" ]; then
	if [ -f $statedir/godir ]; then
	    godir=`cat $statedir/godir`
	else
	    godir=$godirdefault
	fi
	message "Using go located at: $godir"
    fi
    eval godir=$godir
    verbose "Building go in: $godir"
    echo $godir >$statedir/godir

    if [ -n "$TC_PREFIX_DIR" ]; then
	    verbose "Using toolchain for target in: $TC_PREFIX_DIR"
    fi

    #+
    # Determine the uri to use to fetch the go source.
    #-
    if [ -z "$gouri" ]; then
	if [ -f $statedir/gouri ]; then
	    gouri=`cat $statedir/gouri`
	else
	    gouri=$gouridefault
	fi
    fi
    message "The go source repository is: $gouri"
    echo $gouri >$statedir/gouri

    #+
    # Determine the tag or branch to use to fetch the go source.
    #-
    if [ -z "$gotag" ]; then
	if [ -f $statedir/gotag ]; then
	    gotag=`cat $statedir/gotag`
	else
	    gotag=$gotagdefault
	fi
    fi
    message "The go branch or tag is: $gotag"
    echo $gotag >$statedir/gotag

    GOROOT=$godir/$gotag/go
    verbose "The go binaries are located at: $GOROOT"
    
    if [ -f $godir/.$gotag-built ]; then
	message "Using go version $gotag."
	return
    fi
    #+
    # The go binaries don't exist.
    #-
    if [ -n "$testing" ]; then
	message "Just a test run -- not building the toolchain."
	verbose "./all.bash"
    else
	run mkdir -p $godir/$gotag
	cd $godir/$gotag
	verbose "Working directory is: $PWD"
	if [ -d $godir/$gotag/go ]; then
	    run hg -R go pull -u -r $gotag $gouri
	else
	    run hg clone -u $gotag $gouri
	fi
	cd go/src
	export GOOS=linux
	export GOARCH=amd64
	export CGO_ENABLED=1
	if [ -n "$TC_PREFIX_DIR" ]; then
	    export CC_FOR_TARGET="$TC_PREFIX_DIR/bin/${toolchainprefix}-cc"
	    export CXX_FOR_TARGET="$TC_PREFIX_DIR/bin/${toolchainprefix}-c++"
	fi
	# all.bash runtime tests are not suitable for cross-compile toolchain:
	# https://github.com/golang/go/issues/6172
	run ./make.bash
	touch $godir/.$gotag-built
    fi
}
