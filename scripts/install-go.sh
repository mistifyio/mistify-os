#+
# Compile go from source and install it into the previously built toolchain.
# NOTE: The go repo is mirrored on github. The install instructions point to
# the googlesource repo so that URL is the default for this script. Of course
# it can be overridden using the --gouri command line option.
# NOTE: This relies upon the toolchainversion variable from the install-toolchain
# script. This is because the path to the toolchain is embedded and different
# versions of the toolchain can be selected.
#-
build-c-go () {
    #+
    # Parameters:
    # 1 = The label to associate with the build.
    # 2 = The tag to checkout from the repo.
    #-
    if [ -f $godir/.$1-built ]; then
        message "build-c-go: Using go version $1."
    return
    fi
    verbose "build-c-go: Building go version $1."
    if [ -n "$dryrun" ]; then
        message "build-c-go: Just a test run -- not building go."
        return
    fi
    run mkdir -p $godir/$1
    cd $godir/$1
    verbose "Working directory is: $PWD"
    if [ ! -d go ]; then
        run git clone $gouri
    fi
    cd go
    run git fetch $gouri
    run git checkout $2
    cd src
    export GOOS=linux
    export GOARCH=amd64
    if [ -n "$TC_PREFIX_DIR" ]; then
        export CC_FOR_TARGET="$TC_PREFIX_DIR/bin/${TC_PREFIX}-cc"
        export CXX_FOR_TARGET="$TC_PREFIX_DIR/bin/${TC_PREFIX}-c++"
    fi
    export CGO_ENABLED=1

    run ./make.bash

    # Clean up
    unset CC_FOR_TARGET
    unset CXX_FOR_TARGET
    unset CGO_ENABLED

    touch $godir/.$1-built
}

build-go-go () {
    #+
    # Parameters:
    # 1 = The label to associate with the build.
    # 2 = The tag to checkout from the repo.
    #-
    if [ -f $godir/.$1-built ]; then
        message "build-go-go: Using go version $1."
        return
    fi
    bootstraplabel=$gobootstraptag-$toolchainversion
    build-c-go $bootstraplabel $gobootstraptag

    verbose "build-go-go: Building go version $1."
    if [ -n "$dryrun" ]; then
        message "build-go-go: Just a test run -- not building go."
        return
    fi
    run mkdir -p $godir/$1
    cd $godir/$1
    verbose "Working directory is: $PWD"
    if [ ! -d go ]; then
        run git clone $gouri
    fi
    cd go
    run git fetch $gouri
    run git checkout $2
    cd src
    export GOROOT_BOOTSTRAP=$godir/$bootstraplabel/go
    export GOOS=linux
    export GOARCH=amd64

    run ./make.bash

    # Clean up
    unset GOROOT_BOOTSTRAP

    touch $godir/.$1-built
}

install-go () {
    message "Building go in: $godir"

    message "The go source repository is: $gouri"

    message "The go branch or tag is: $gotag"

    golabel=$gotag-$toolchainversion
    verbose The Go label is: $golabel

    GOROOT=$godir/$golabel/go
    verbose "The go binaries are located at: $GOROOT"

    #+
    # With go version 1.5 and later all C source has been removed from
    # the go sources. This means go is needed to build go and makes this
    # a two stage build.
    # NOTE: This logic precludes the use of a hash.
    #-
    major=`echo $gotag | cut -d . -f 1`
    if [ ! "$major" == "go1" ]; then
        die Only go1.x.x supported at this time.
    fi
    minor=`echo $gotag | cut -d . -f 2`
    if [ "$minor" -lt "5" ]; then
        build-c-go $golabel $gotag
    else
        build-go-go $golabel $gotag
    fi
}
