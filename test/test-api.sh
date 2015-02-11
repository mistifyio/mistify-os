#!/usr/bin/env bash
set -e
set -o pipefail
set -x

HOST=${1:-127.0.0.1}

http (){
	METHOD=$1
	URL=$2
	shift 2
	curl --fail -sv -X $METHOD -H 'Content-Type: application/json' http://$HOST:8080/$URL "$@" | jq .
}

http PATCH metadata --data-binary '{"foo": "bar", "hello": "world" }'

http PATCH metadata --data-binary '{"foo": null}'

STATUS=$(http GET images | jq -r 'map(select(.id == "linux-test"))[0].status')
if [ $STATUS == "null" ]; then
    http POST images --data-binary '{"source": "http://www.akins.org/mistify/linux-test.gz" }'
fi

until [ $STATUS = "complete" ]; do
    sleep 5
    STATUS=$(http GET images | jq -r 'map(select(.id == "linux-test"))[0].status')
done

ID=$(http POST guests --data-binary \
    '{"metadata": { "foo": "bar"}, "memory": 256, "cpu": 2, \
    "nics": [ { "model": "virtio", "address": "10.10.10.10", \
    "netmask": "255.255.255.0", "gateway": "10.10.10.1", \
    "network": "virbr0"} ], \
    "disks": [ {"image": "linux-test"}, {"size": 512} ] }' | jq -r .id)

STATE=create
until [ $STATE = "running" ]; do
    sleep 1
    STATE=$(http GET guests/$ID | jq -r .state)
done

sleep 10

http GET guests

sleep 10

for m in cpu disk nic; do
    http GET guests/$ID/metrics/$m
done

for ID in $(http GET guests | jq -r .[].id); do
	http GET guests/$ID
	http DELETE guests/$ID
done
