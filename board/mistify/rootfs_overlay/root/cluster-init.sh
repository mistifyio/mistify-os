#!/usr/bin/env bash

set -e

function msg() {
	logger -st cluster-init-out "$@"
}
function err() {
	logger -st cluster-init-err "$@"
}

exec 1> >(msg)
exec 2> >(err)

function init() {
        ips=('192.168.200.200'
             '192.168.200.201'
             '192.168.200.202'
        )
        quuids=('e30aa502-e48b-2a4e-8116-d4b09c0b89b3'
                '21c1c14f-ca81-2e4f-96cc-0ba6aa404a94'
                '11e48c3f-b13a-5e4a-b20e-b5b3ae6fd060'
        )

        # handle uuid endiannes changes in qemu/smbios/dmidecode, see
        # https://bugzilla.redhat.com/show_bug.cgi?id=1152922
        # and the fix
        # https://lists.gnu.org/archive/html/qemu-devel/2014-10/msg03640.html
        #
        # which also affects the systemd-networkd generated mac for br0
        if [[ $(hostname) != ${quuids[0]} ]]; then
                uuids=('02a50ae3-8be4-4e2a-8116-d4b09c0b89b3'
                       '4fc1c121-81ca-4f2e-96cc-0ba6aa404a94'
                       '3f8ce411-3ab1-4a5e-b20e-b5b3ae6fd060'
                )
                macs=('DE:AD:BE:EF:7F:20'
                      'A6:59:45:B2:57:12'
                      '6A:B1:9E:0F:F0:56'
                )
        else
                echo "SMBIOS version is older than v2.6"
                uuids=(${quuids[*]})
                macs=('DE:AD:BE:EF:7F:20'
                      'FA:86:83:AA:58:6B'
                      'C6:85:44:7D:FA:88'
                )
        fi
}
init

function do_until() {
	local t=$1
	local cmd=$2
	shift 2
	local i=0
	until $cmd "$@"; do
		sleep $t
		msg "$((++i * $t))s elapsed"
	done
}

ip=${ips[0]}
nm=24
gw=192.168.200.1

echo "$LINENO: stopping nconfigd to avoid races"
systemctl stop nconfigd
echo "$LINENO: done"

echo "$LINENO: setting up etcd keys"
etcdctl set /lochness/hypervisors/${uuids[0]}/config/dhcpd true
etcdctl set /lochness/hypervisors/${uuids[0]}/config/dns true
etcdctl set /lochness/hypervisors/${uuids[0]}/config/cbootstrapd true
etcdctl set /lochness/hypervisors/${uuids[0]}/config/etcd true
etcdctl set /lochness/hypervisors/${uuids[0]}/config/tftpd true

etcdctl set /lochness/hypervisors/${uuids[1]}/config/dns true
etcdctl set /lochness/hypervisors/${uuids[1]}/config/etcd true
etcdctl set /lochness/hypervisors/${uuids[2]}/config/dns true
etcdctl set /lochness/hypervisors/${uuids[2]}/config/etcd true
echo "$LINENO: done"

echo "$LINENO: setting up network"
rm -f /etc/systemd/network/*
cat > /etc/systemd/network/br0.netdev <<EOF
[NetDev]
Name=br0
Kind=bridge
EOF

cat > /etc/systemd/network/br0.network <<EOF
[Match]
Name=br0

[Network]
DNS=127.0.0.1
Address=$ip/$nm
Gateway=$gw
EOF

cat > /etc/systemd/network/ethernet.network <<EOF
[Match]
Name=en*

[Network]
Bridge=br0
EOF

cat > /etc/resolv.conf <<EOF
nameserver 127.0.0.1
EOF

systemctl restart systemd-networkd && ip addr del $ip/$nm dev ens3 || :
echo "$LINENO: done"

echo "$LINENO: ensuring nconfigd has started and getting its pid"
systemctl start nconfigd
sleep 2
nconfigdpid=$(pidof nconfigd)
echo "$LINENO: nconfigd has a pid of:$nconfigdpid"
echo "$LINENO: done"

echo "$LINENO: waiting for nconfigd/ansible"
do_until 1 test -d /proc/$nconfigdpid
dig +short dns.services.lochness.local @127.0.0.1 -p 15353 || echo "$LINENO: ok well that failed, but lets continue anyway"
echo "$LINENO: done"

echo "$LINENO: setting up etcd to listen on external interfaces"
cat > /etc/sysconfig/etcd <<EOF
ETCD_LISTEN_CLIENT_URLS=http://$ip:2379,http://$ip:4001,http://localhost:2379,http://localhost:4001
EOF
systemctl restart etcd
sleep .100
echo "$LINENO: done"

echo "$LINENO: waiting for etcd to come back fully"
do_until 1 etcdctl cluster-health
echo "$LINENO: done"

echo "$LINENO: setting up other nodes in etcd"
stop=$((${#uuids[*]} - 1))
for i in $(seq 0 $stop); do
	echo "${uuids[$i]}"
	etcdctl set /lochness/hypervisors/${uuids[$i]}/config/etcd true
	cat <<-EOF | tr -d '\n' | etcdctl set /lochness/hypervisors/${uuids[$i]}/metadata
	{"id":"${uuids[$i]}","ip":"${ips[$i]}","netmask":"255.255.255.0","gateway":"$gw","mac":"${macs[$i]}"}
	EOF
	cat <<-EOF | tr -d '\n' | etcdctl set /queensland/nodes/${uuids[$i]}
	{"ip":"${ips[$i]}"}
	EOF
	cat <<-EOF | tr -d '\n' | etcdctl set /queensland/services/etcd-server/${uuids[$i]}
	{"priority":0,"weight":0,"port":2380,"target":"${uuids[$i]}"}
	EOF
done
echo "$LINENO: done"

echo "$LINENO: waiting for nconfigd to process new nodes, then stopping nconfigd"
journalctl -fu nconfigd.service | grep --line-buffered 'PLAY RECAP' | while read line; do
	break
done
systemctl stop nconfigd
echo "$LINENO: done"

echo "$LINENO: waiting for etcd to come back fully"
do_until 1 etcdctl cluster-health
echo "$LINENO: done"

echo "$LINENO: setting up etcd cluster"
etcdctl set /lochness/config/ETCD_DISCOVERY_SRV 'services.lochness.local'
etcdctl set /lochness/config/ETCD_INITIAL_CLUSTER_STATE 'new'
etcdctl set /lochness/config/ETCD_INITIAL_CLUSTER_TOKEN 'etcd-cluster-1'
for i in $(seq 0 $stop)
do
	path="/lochness/hypervisors/${uuids[$i]}/config"
	echo "$path"
	etcdctl set $path/NCONFIGD_ETCD_ADDRESS http://$ip:4001
	etcdctl set $path/ETCD_ADVERTISE_CLIENT_URLS "http://${uuids[$i]}.nodes.lochness.local:2379,http://${uuids[$i]}.nodes.lochness.local:4001"
	etcdctl set $path/ETCD_INITIAL_ADVERTISE_PEER_URLS "http://${uuids[$i]}.nodes.lochness.local:2380"
	etcdctl set $path/ETCD_LISTEN_CLIENT_URLS "http://${uuids[$i]}.nodes.lochness.local:2379,http://${uuids[$i]}.nodes.lochness.local:4001,http://localhost:2379,http://localhost:4001"
	etcdctl set $path/ETCD_LISTEN_PEER_URLS "http://${uuids[$i]}.nodes.lochness.local:2380"
	etcdctl set $path/ETCD_NAME "${uuids[$i]}"
done
echo "$LINENO: done"

echo "$LINENO: checking for kernel/initrd existence"
do_until 5 ls -l /var/lib/images/0.1.0/{vmlinuz,initrd}
echo "$LINENO: done"

echo "$LINENO: ok you can now boot node1 and node2"
do_until 5 curl --silent http://${ips[1]}:4001/v2/keys
echo "$LINENO: ok new etcd cluster seems to be up"

echo "$LINENO: sleeping 10s to let new nodes settle"
sleep 10
echo "$LINENO: done"

echo "$LINENO: syncing queensland data from old cluster to new"
etcdctl ls --recursive --sort -p /queensland | sed '/\/$/ d' | while read key; do
	etcdctl get $key | sed 's|^|value=|' | curl -s -XPUT http://${ips[1]}:4001/v2/keys$key -d@-
done
echo "$LINENO: done"

echo "$LINENO: setting hv1 to be dns server (temporarily)"
curl -s -XPUT http://${ips[1]}:4001/v2/keys/lochness/hypervisors/${uuids[1]}/config/dns -dvalue=true
echo "$LINENO: done"

echo "$LINENO: backing up etcd data"
etcdctl ls --sort --recursive -p | sed '/\/$/ d' | while read key; do
	printf "%s %s\n" "$(printf $key | base64 -w0)" "$(base64 -w0 <(etcdctl get $key))"
done > /tmp/etcd.dump
echo "$LINENO: done"

echo "$LINENO: waiting for other dns server to come up"
do_until 5 dig +short dns.services.lochness.local @${ips[1]}
echo "done"

echo "$LINENO: restarting etcd so it can join the cluster"
cat /dev/null > /etc/default/etcd
curl -s http://localhost:8888/config/$ip > /tmp/mistify-config
cat > /etc/resolv.conf <<EOF
nameserver ${ips[1]}
nameserver ${ips[2]}
nameserver ${ips[0]}
EOF
systemctl stop etcd confd named dhcpd cbootstrapd tftpd
rm -rf /mistify/data/etcd/*
systemctl start etcd
echo "$LINENO: done"

echo "$LINENO: waiting for etcd cluster to be healthy"
do_until 5 etcdctl cluster-health
echo "$LINENO: done"

echo "$LINENO: restoring etcd data"
while read key value; do
	echo $value | base64 -d | sed 's|^|value=|' | \
		curl -s -XPUT "http://localhost:4001/v2/keys$(echo $key | base64 -d)" -d@-
done < /tmp/etcd.dump
echo "$LINENO: done"

echo "$LINENO: restarting nconfigd so it can do its thing"
systemctl restart nconfigd
echo "$LINENO: done"
