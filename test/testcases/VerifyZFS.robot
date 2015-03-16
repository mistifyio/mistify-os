*** Settings ***
Documentation	Verify ZSF is running and the zfs directories have been
...		mounted.

Resource	test/resources/mistify.robot
Resource	test/resources/ssh.robot

Suite Setup	Login To SUT  ${TESTBED_IP}  ${USERNAME}  ${PASSWORD}

*** Test Cases ***
Check For SPL
    [Documentation]	ZFS requires the SPL kernel module.
    ...
    ...			Verify the spl kernel module is loaded and has
    ...			properly associated with the zfs modules.
    ${o}=
    ...	ssh.Execute Command	lsmod \| grep spl
    # It may be this can be expressed as a list of patterns but
    # it's not obvious how to do that at the moment so brute force.
    Should Contain
    ...	${o}	spl
    Should Contain
    ...	${o}	zfs
    Should Contain
    ...	${o}	zavl
    Should Contain
    ...	${o}	zunicode
    Should Contain
    ...	${o}	zcommon
    Should Contain
    ...	${o}	znvpair

Check For ZFS
    [Documentation]	Verify ZFS kernel modules are loaded on the SUT.
    ...
    ...		ZFS includes a number of kernel modules which must be loaded
    ...		before any zfs devices can be mounted.
    ${o}=
    ...	ssh.Execute Command	lsmod \| grep '^z' \| cut -f 1 -d ' '
    Should Contain
    ...	${o}	zfs
    Should Contain
    ...	${o}	zavl
    Should Contain
    ...	${o}	zunicode
    Should Contain
    ...	${o}	zcommon
    Should Contain
    ...	${o}	znvpair

Check ZFS Mounts
    [Documentation]	Verify the ZFS file systems have been mounted.
    ...
    ...		For Mistify-OS a number of zfs mounts must exist in
    ...		known locations or other components may fail.
    ${o}=
    ...	ssh.Execute Command	mount \| grep 'mistify'
    Should Contain
    ...	${o}	mistify on /mistify type zfs
    Should Contain
    ...	${o}	mistify/guests on /mistify/guests type zfs
    Should Contain
    ...	${o}	mistify/images on /mistify/images type zfs
    Should Contain
    ...	${o}	mistify/private on /mistify/private type zfs
    Should Contain
    ...	${o}	mistify/data on /mistify/data type zfs

*** Keywords ***
