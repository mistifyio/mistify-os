#+
# Some functions for managing configuration variants.
#-
variantsconfigdir=$projectdir/variants

function variant_file () {
  #+
  # Parameters:
  # 1 = original file
  # 2 = variant name
  # 3 = return variable
  #-
  vf=$variantsconfigdir/$2-$(basename $1).patch
  verbose "Variant file is: $vf"
  eval "$3=$vf"
}

create_variant () {
  #+
  # Parameters:
  # 1 = original file
  # 2 = variant name
  #-
  vf=''
  if [ $# -gt 1 ]; then
    variant_file $1 $2 vf
    if [ ! -e $vf ]; then
	touch $vf
    fi
  fi
}

use_variant () {
    #+
    # Parameters:
    # 1 = file to patch.
    # 2 = output file.
    # 3 = variant name (empty indicates using base file)
    #-
    verbose "use_variant: file=$1, output=$2, variant=$3"
    vf=''
    if [ ! -z "$3" ]; then
      variant_file $1 $3 vf
    fi
    if [ "$vf" ] && [ -f $vf ]; then
	verbose "Patching $1 using variant $3 to produce $2"
	run patch -i $vf -o $2 $1
	verbose "Patch exit status is: $?"
    else
	if [ -z "$3" ]; then
	    verbose "Using base config file: $1"
	else
	    verbose "Patch file doesn't exist. Copying $1 to $2"
	fi
	run cp $1 $2
	return 0
    fi
}

update_variant () {
    #+
    # Parameters:
    # 1 = new version of file
    # 2 = original file
    # 3 = variation name (empty indicates using base file)
    #-
    verbose "update_variant: new file=$1, original=$2, variant=$3"
    if [ ! -z "$3" ]; then
	vf=''
	variant_file $2 $3 vf
	mkdir -p $variantsconfigdir
	if [ ! -e $vf ]; then
	    verbose "Using original $2 and new $1 to create patch file $vf"
	    warning "Variant $3 doesn't exist."
	    confirm "Would you like to create the variant?"
	    if [ $? -gt 0 ]; then
		exit 1
	    else
		message "Creating variant $3 for $2".
	    fi
	fi
	run_ignore diff -u $2 $1 > $vf
	verbose "Diff exit status is: $?"
	if [ $? -gt 1 ]; then
	    error "An error occured when creating the patch $vf"
	    return 1
	fi
	return 0
    else
	if [ -z "$3" ]; then
	    verbose "Updating base configuration file $2"
	else
	    verbose "Variant not needed. Copying $1 to $2."
	fi
	run cp $1 $2
	return 0
    fi
}