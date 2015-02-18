*** Settings ***
Documentation	This defines the attributes for an OS-Distribution.
...
...	These are the common attributes to describe the Ubuntu Trusty (14.04)
...	distro for 64 bit architectues.

*** Variables ***
# NOTE: These names are consistent with using lxc containers.
${DISTRO_NAME}		ubuntu
${DISTRO_VERSION}	14.04
${DISTRO_VERSION_NAME}	trusty
${DISTRO_ARCH}		amd64
${DISTRO_LONG_NAME}	${DISTRO_NAME}-${DISTRO_VERSION_NAME}-${DISTRO_ARCH}
