#!/bin/bash


#pushd ../
#./buildmistify --builddir /home/vagrant/build --buildroot /home/vagrant/buildroot
#popd

truncate -s 8G /home/vagrant/root.img

BRIDGE=mistify

brctl show | grep ^$BRIDGE
if [ $? -ne 0 ]; then
     brctl addbr $BRIDGE
fi

brctl addbr $BRIDGE
ifconfig $BRIDGE 192.168.255.1 netmask 255.255.255.0

sysctl -w net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o $BRIDGE -j MASQUERADE
iptables -A FORWARD -o $BRIDGE -m state --state RELATED,ESTABLISHED -j ACCEPT

qemu-system-x86_64 \
    -kernel /home/vagrant/build/images/bzImage.buildroot  \
    -initrd /home/vagrant/build/images/initrd.buildroot \
    -drive if=virtio,file=/home/vagrant/root.img  \
    -machine accel=kvm -cpu host -smp 2 \
    -append "noapic acpi=off ramdisk_size=200000 rw console=ttyS0 zfs=auto network=test" \
    -nographic -m 2048 \
    -netdev type=tap,script=$PWD/qemu-ifup,id=net0 -device virtio-net-pci,netdev=net0 &

QPID=$!


sleep 10

until curl -so /dev/null -fail http://192.168.255.100:8080/guests; do
    sleep 5
done

sleep 10

bash agent-test 192.168.255.100

kill $QPID
