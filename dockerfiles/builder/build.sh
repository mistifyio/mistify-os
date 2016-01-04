#!/usr/bin/env bash

if [[ $0 != /build.sh ]]; then
	cmd="$1"
	shift
	exec "$1" "$@"
fi

set -x
cd /mistify-os
./buildmistify \
	--downloaddir /downloads/ \
	--tcuri https://github.com/mistifyio/crosstool-ng --toolchaindir /toolchains/toolchain \
	--gouri https://github.com/golang/go --godir /toolchains/go \
	--buildrooturi https://github.com/mistifyio/buildroot --buildrootdir /build/buildroot \
	--builddir /build/build \
	"$@" \
	;
