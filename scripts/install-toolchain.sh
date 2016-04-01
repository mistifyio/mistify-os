#+
# Handle the external toolchain options for the buildmistify script including
# building and installing the external toolchain. This version uses
# uses crosstools-NG and builds the toolchain uses sources fetched from the
# crosstools-NG git repository.
#
# This script is intended to be sourced by the buildmistify script.
#-

#+
# These variables are passed to the make file.
#-
toolchain_name_prefix=crosstool-ng
toolchain_base_name=$toolchain_name_prefix-$toolchainprefix-$toolchainversion-$variant
toolchain_tar_file=$toolchain_base_name.tgz
toolchainartifact_url=$tcartifacturi/$toolchain_tar_file
toolchain_variation_dir=$toolchaindir/build-$toolchain_base_name
toolchain_install_dir=$toolchaindir/$toolchain_base_name
toolchainreset=$toolchainreset

#+
# Internal variables.
#-
toolchain_make=Makefile-toolchain
toolchain_built=$toolchain_install_dir/bin/$toolchainprefix-gcc

# This is called by the buildmistify script and is passed to the buildroot
# build.
toolchain-dir () {
    echo $toolchain_install_dir
}

download-toolchain-artifact () {
    if [ ! -f $downloaddir/$toolchain_tar_file ]; then
        mkdir -p $downloaddir

        message "Downloading toolchain artifact from $toolchainartifact_url"
        wget -nc $toolchainartifact_url -O $downloaddir/$toolchain_tar_file

        if [ $? -gt 1 ]; then
            die "Toolchain artifact download failed."
        fi
    else
        message "Using existing tar file $downloaddir/$toolchain_tar_file."
    fi
}

extract-toolchain-artifact() {
    #+
    # NOTE: The user might be attempting to repair an install so always start
    # with a new directory.
    #-
    rm -rf $toolchain_install_dir
    message "Extracting toolchain artifact $downloaddir/$toolchain_tar_file"
    cd $toolchaindir
    tar -C $toolchaindir -xf $downloaddir/$toolchain_tar_file
    if [ $? -gt 0 ]; then
        die "Toolchain artifact extraction failed."
    fi
    if [ ! -d $toolchain_install_dir ]; then
        die "Toolchain tar file not formatted correctly."
    fi
}

install-toolchain-from-artifact(){
    download-toolchain-artifact
    extract-toolchain-artifact
    return 0
}

run-make()
{
    verbose "Running colorized make."
    verbose "Make args: $@"
    /usr/bin/make "$@" 2>&1 | \
        sed -E \
            -e "s/$toolchain_make/ $(echo -e "\\033[1;34m"$toolchain_make"\\033[0m"/g)" \
            -e "s/error:/ $(echo -e "\\033[31m" ERROR "\\033[0m"/g)" \
            -e "s/warning:/ $(echo -e "\\033[0;33m" WARNING "\\033[0m"/g)"
    return ${PIPESTATUS[0]}
}

run-toolchain-make () {
    # Parameters:
    # 1  A makefile target. Typically toolchain-menuconfig to configure the
    #    the toolchain.
    makevars="\
        tcuri=$tcuri \
        toolchaindir=$toolchaindir \
        toolchainprefix=$toolchainprefix \
        toolchaininstallprefix=$toolchaininstallprefix \
        toolchainversion=$toolchainversion \
        variant=$variant \
        tcartifacturi=$tcartifacturi \
        tcconfig=$tcconfig \
        downloaddir=$downloaddir \
        toolchain_name_prefix=$toolchain_name_prefix \
        toolchain_base_name=$toolchain_base_name \
        toolchain_tar_file=$toolchain_tar_file \
        toolchainartifact_url=$toolchainartifact_url \
        toolchain_variation_dir=$toolchain_variation_dir \
        toolchain_install_dir=$toolchain_install_dir \
        artifact_dir=$artifact_dir \
        verbose=$verbose"
    verbose "Toolchain make variables: $makevars"

    if [ -n "$dryrun" ]; then
        message "Just a test run of the toolchain makefile."
        dryrunarg=-n
    fi
    run-make $makevars \
      -f $projectdir/scripts/$toolchain_make \
      -C $toolchaindir \
      $dryrunarg $1

    if [ $? -gt 0 ]; then
        die "The toolchain build failed."
    fi
    return 0
}

install-toolchain-script () {
    tcc=$toolchain_variation_dir/.config

    if [ -n "$toolchainreset" ]; then
        warning Removing existing toolchain build artifacts and rebuilding.
        run-toolchain-make distclean
    fi

    if [[ "$target" == "toolchain-menuconfig" ]]; then
        cd $toolchain_variation_dir && ./ct-ng menuconfig
        if [[ ! -f $tcconfig || $tcc -nt $tcconfig ]]; then
            ls -l $tcc $tcconfig
            cp $tcc $tcconfig
            if [ $? -gt 0 ]; then
                die "Failed to save $tcconfig"
            else
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
                run-toolchain-make distclean
                run-toolchain-make
            fi
        else
            error "The toolchain config file doesn't exist."
            die "Run ./buildmistify toolchain-menuconfig."
        fi
    fi

    #+
    # Don't build the toolchain if it has already been built.
    #-
    if [ -f $toolchain_built ]; then
        message "Using toolchain installed at: $toolchain_install_dir"
        return 0
    fi
    #+
    # Download, build and install the toolchain.
    #-
    message "Toolchain not built."
    message "Installing toolchain to: $toolchain_install_dir"
    #+
    # Building the toolchain requires a full build.
    #_
    warning A full build is required!
    forcebuild=y

    if [ -f $downloaddir/$toolchain_tar_file ]; then
        message "Installing prebuilt toolchain."
        install-toolchain-from-artifact
    else
        run-toolchain-make
    fi
    return 0
}

install-toolchain () {
    message "The toolchain variation directory is: $toolchain_variation_dir"
    message "The toolchain build tool repository is: $tcuri"
    message "The toolchain version is: $toolchainversion"
    message "The toolchain config file is: $tcconfig"

    mkdir -p $toolchaindir

    if [ -n "$useartifacts" ]; then
        download-toolchain-artifact
    fi
    install-toolchain-script
    return $?
}
