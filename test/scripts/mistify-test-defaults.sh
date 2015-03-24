#+
# Defaults for testing Mistify-OS.
#-

testmistifystatedir=${statedir}/testmistify

function get_default() {
    # Parameters:
    #   1: option name
    #   2: default value
    if [ -e $testmistifystatedir/$1 ]; then
      r=`cat $testmistifystatedir/$1`
    else
      r=$2
    fi
    verbose The default for $1 is $2
    echo $r
}

function set_default() {
    # Parameters:
    #   1: option name
    #   2: value
    echo "$2">$testmistifystatedir/$1
    verbose The default $1 has been set to $2
}

# Network configuration

tapdefault=$(get_default tap tap0)
bridgedefault=$(get_default bridge mosbr0)
bridgeipdefault=$(get_default bridgeip 10.0.2.2)
maskbitsdefault=$(get_default maskbits 24)

# Build information.
if [ -e "$statedir/variantbuilddir" ]; then
    builddirdefault=$(get_default builddir `cat $statedir/variantbuilddir`)
else
    builddirdefault=$(get_default builddir '$PWD')
fi

# Test images
kerneldefault=$(get_default kernel $builddirdefault/images/bzImage.buildroot)
initrddefault=$(get_default initrd $builddirdefault/images/initrd.buildroot)

