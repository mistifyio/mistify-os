#+
# Compile go from source and install it into the previously built toolchain.
#-
gouridefault=https://code.google.com/p/go
godirdefault=$PWD/go
gotagdefault=release

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
	run hg clone -u $gotag $gouri
	cd go/src
	export GOOS=linux
	export GOARCH=amd64
	run ./all.bash
	touch $godir/.$gotag-built
    fi
}
