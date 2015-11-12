#+
# Some functions for managing configuration variants.
#-
variantsconfigdir=$projectdir/variants

function config_contains () {
  #+
  # Parameters:
  # 1 = option to find
  # x = list of options to search
  # Returns:
  # Status: 0 = OK, 1=not found
  #-
  opt=$1
  shift

  for o in $*; do
    if [ "$1" == "$o" ]; then
      return 0
    fi
  done
  return 1
}

function find_prefix () {
  echo `grep -m1 "^[A-Z|0-9]*_" $1 | cut -f1 -d '_'`
}

function merge_variant () {
  #+
  # Parameters:
  # 1 = base file
  # 2 = variant file
  # 3 = output file
  #-
  verbose "base=$1, variant=$2, output=$3"
  prefix=`find_prefix $1`
  verbose "Configuration option prefix is: $prefix"
  message "Merging files $1 and $2 into $3"
  message "Base file is: $1"
  sed_expression="s/^\(# \)\{0,1\}\(${prefix}_[a-zA-Z0-9_]*\)[= ].*/\2/p"

  baselist=$(sed -n "$sed_expression" $1)
  variantlist=$(sed -n "$sed_expression" $2)
  run cp $1 $3
  for var in $variantlist; do
    verbose "Checking variant option: $var"
    config_contains $var $baselist
    if [ $? -eq 0 ]; then
      warning "Config option $var is redefined in $2"
      verbose "Removing option $var from $3"
      # This removes either the assignment or the "is not set" for the option.
      sed -i "/$var[ =]/d" $3
    fi
    # The redefinitions have been removed from the base config so can
    # simply concatenate the variant file.
    verbose "Appending the variant configuration."
    cat $2 >> $3
  done
}

function variant_file () {
  #+
  # Parameters:
  # 1 = original file
  # 2 = variant name
  # 3 = return variable
  #-
  vf=$variantsconfigdir/$2-$(basename $1)
  verbose "Variant file is: $vf"
  eval "$3=$vf"
}

function copy_if_different () {
    #+
    # Parameters:
    # 1 = source file
    # 2 = destination file
    #-
    diff $1 $2 &> /dev/null
    if [ $? -gt 0 ]; then
        verbose Files $1 and $2 are different -- copying.
        run cp $1 $2
    else
        verbose Files $1 and $2 are the same -- not copying.
    fi
}

function use_variant () {
    #+
    # Parameters:
    # 1 = base file
    # 2 = output file.
    # 3 = variant name (empty indicates using base file)
    #-
    verbose "use_variant: file=$1, output=$2, variant=$3"
    vf=''
    if [ ! -z "$3" ]; then
      variant_file $1 $3 vf
    fi
    if [ "$vf" ] && [ -f $vf ]; then
	merge_variant $1 $vf $2
    else
	if [ -z "$3" ]; then
	    verbose "Using base config file: $1"
	else
	    verbose "Variant file doesn't exist. Copying $1 to $2"
	fi
	copy_if_different $1 $2
	return 0
    fi
}

function update_variant () {
    #+
    # Parameters:
    # 1 = new version of file
    # 2 = base file
    # 3 = variation name (empty indicates using base file)
    #-
    verbose "update_variant: new file=$1, original=$2, variant=$3"
    if [ -n "$3" ] && [ "$3" != "base" ]; then
	vf=''
	variant_file $2 $3 vf
	mkdir -p $variantsconfigdir
	if [ ! -e $vf ]; then
	    verbose "Using original $2 and new $1 to create variant file $vf"
	    warning "Variant $3 doesn't exist."
	    confirm "Would you like to create the variant?"
	    if [ $? -gt 0 ]; then
		exit 1
	    else
		message "Creating variant $3 for $2".
	    fi
	fi
	prefix=`find_prefix $2`
	verbose "Using config option prefix: $prefix"
	diff -e $2 $1 | grep $prefix >$vf
	if [ $? -gt 1 ]; then
	    error "An error occured when updating the variant: $vf"
	    return 1
	fi
	return 0
    else
	message "Updating base configuration file $2"
	verbose "Variant not needed. Copying $1 to $2."
	run cp $1 $2
	return 0
    fi
}