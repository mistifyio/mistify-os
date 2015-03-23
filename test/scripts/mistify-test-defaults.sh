#+
# Defaults for testing Mistify-OS.
#-

# Network configuration
tapdefault=tap0
bridgedefault=mosbr0
ipdefault=10.0.2.2
maskbitsdefault=24
macdefault=DE:AD:BE:EF:`printf "%02X:%02X" $(( (RANDOM % 256) )) $(( (RANDOM % 256) ))`

# Disk images
diskimagesizedefault=1G

# Build information.
if [ -e "$statedir/variantbuilddir" ]; then
  builddirdefault=`cat $statedir/variantbuilddir`
fi

testmistifystatedir=${statedir}/testmistify

