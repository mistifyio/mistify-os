#!/bin/bash

MISTIFY_IFSTATE=/tmp/.ifstate
MISTIFY_CONFIG=/tmp/mistify-config
PROC_CMDLINE=/proc/cmdline
ETHER_DEVS=(`ls /sys/class/net | egrep -v '^lo$'`)

MISTIFY_KOPT_IP=""
MISTIFY_KOPT_GW=""
MISTIFY_KOPT_IFACE=""

# Parse the kernel boot arguments and look for any mistify.* arguments and
# pick out their values.
function parse_boot_args() {
    local cmdline=$(cat $PROC_CMDLINE)
    grep -q 'mistify.debug/test/not-for-prod' <<<$cmdline || return

    for kopt in $cmdline; do
        k=`echo $kopt | awk -F= '{print $1}'`
        v=`echo $kopt | awk -F= '{print $2}'`
        case $k in
            'mistify.debug/test/not-for-prod.ip')
                MISTIFY_KOPT_IP="$v"
                ;;
            'mistify.debug/test/not-for-prod.gw')
                MISTIFY_KOPT_GW="$v"
                ;;
            'mistify.debug/test/not-for-prod.iface')
                MISTIFY_KOPT_IFACE="$v"
                ;;
        esac
    done
}

# Act on any IP address being passed to us via kernel boot arguments.
# By default, configure the first enummerated interface on the system with it.
function configure_net_manual() {
    if [ -n "$MISTIFY_KOPT_IFACE" ]; then
        local iface="$MISTIFY_KOPT_IFACE"
    else
        local iface="${ETHER_DEVS[0]}"
    fi

    echo "Manually configuring $iface with $MISTIFY_KOPT_IP..."
    /sbin/ip link set $iface up
    /sbin/ip addr add $MISTIFY_KOPT_IP dev $iface
    echo "IFTYPE=MANUAL" >> $MISTIFY_IFSTATE
    echo "IFACE=$iface" >> $MISTIFY_IFSTATE
    echo "IP=$MISTIFY_KOPT_IP" >> $MISTIFY_IFSTATE

    if [ -n "$MISTIFY_KOPT_GW" ]; then
        echo "Manually adding $MISTIFY_KOPT_GW as default route"
        /sbin/ip route add default via $MISTIFY_KOPT_GW
        echo "GW=$MISTIFY_KOPT_GW" >> $MISTIFY_IFSTATE
    fi

    save_mac_for_bridge
}

# Cycle through all known ethernet interfaces until we find one which
# responds to DHCP requests.
function configure_net_dhcp() {
    set -x
    echo "Probing for DHCP"
    /sbin/dhclient -v -e MISTIFY_IFSTATE=$MISTIFY_IFSTATE -1 ${ETHER_DEVS[*]} &&
        echo "IFTYPE=DHCP" >> $MISTIFY_IFSTATE
}

# Unconfigure and otherwise clean up any interfaces we may have configured
function unconfigure_net_iface() {
    if [ -f $MISTIFY_IFSTATE ]; then
        . $MISTIFY_IFSTATE
    else
        return 1
    fi

    if [ "$IFTYPE" != "DHCP" ]; then
        return
    fi

    echo "Releasing DHCP lease on $IFACE..."
    /sbin/dhclient -v -e MISTIFY_IFSTATE=$MISTIFY_IFSTATE -r ${ETHER_DEVS[*]}
    /sbin/ip addr del $IP dev $IFACE
    /sbin/ip link set $IFACE up

    save_mac_for_bridge
}

function save_mac_for_bridge() {
    if [ -f $MISTIFY_IFSTATE ]; then
        . $MISTIFY_IFSTATE
    else
        return 1
    fi

    local mac=$(cat /sys/class/net/$IFACE/address)
    echo "MACAddress=$mac" >> $MISTIFY_IFSTATE &&
        echo "Saving MAC address for bridge $mac"
}

function get_mistify_config() {
    if [ -f $MISTIFY_IFSTATE ]; then
        . $MISTIFY_IFSTATE
    else
        return 1
    fi

    if [[ -z $DNS ]]; then
        # not configured via dhcp
        return 1
    fi

    local resp=''
    for dns in ${DNS[*]}; do
        srv=$(dig +noall +answer +additional SRV ipxe.services.lochness.local @$dns) || continue
        resp="$srv"
        break
    done

    if [[ -z $resp ]]; then
        echo "could not resolv ipxe service"
        return 1
    fi

    local addr=$(echo $resp | awk '/\sA\s/ {print $NF}')
    local port=$(echo $resp | awk '/\sSRV\s/ {print $7}')
    local ip=${IP%%/*}
    curl http://$addr:$port/config/$ip > $MISTIFY_CONFIG

    if [ $? -ne 0 ]; then
        echo "FATAL: Could not get Mistify configuration for $ip!"
        return 1
    fi
}

## Network initialization main. Under 'start' we either manually configure a IP address
## on the first interface if we are given one in the kernel boot arguments.
## Otherwise we probe each interface for a DHCP response until we fine one that does.
case "$1" in
    'start')
        # Initialize our own interface state file
        cp /dev/null $MISTIFY_IFSTATE

        parse_boot_args

        if [ -n "$MISTIFY_KOPT_IP" ]; then
            configure_net_manual
        else
            configure_net_dhcp
            get_mistify_config
        fi
        ;;
    'stop')
        unconfigure_net_iface
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        ;;
esac

# vim:set ts=4 sw=4 et:
