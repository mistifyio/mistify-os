#!/bin/bash

URL=""

read -r cmdline < /proc/cmdline
for param in $cmdline ; do
	case $param in
	    mistify.config-url=*)
		    URL=${param#mistify.config-url=}
		    ;;
	esac
done

if [ -z "$URL" ]; then
    exit 0
fi

curl --fail -L -s -O /etc/mistify.env "$URL"

exit $?
