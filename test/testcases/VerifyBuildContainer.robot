*** Settings ***
Documentation	This verifies an LXC based container can be created and is
...		functional.
...
...	This creates a test container, verifies it will run and then
...	destroys it. This is only to verify containers will work and
...	can be removed.

Resource	test/resources/mistify.robot
Resource	test/resources/lxc.robot

*** Variables ***
${container}=	throwaway

*** Test Cases ***
Verify LXC is installed
    Test LXC Is Installed

Verify Container Creation
    ${_rc}=	Create Unprivileged Container
    ...	${container}	${DISTRO_NAME}
    ...	${DISTRO_VERSION_NAME}	${DISTRO_ARCH}
    Should Be Equal As Integers	${_rc}	0

Verify Container Exists
    ${_o}=	Container List
    Should Contain	${_o}
    ...	${container}

Verify Container Starts
    ${_rc}=	Start Container	${container}
    Should Be Equal As Integers	${_rc}	0

Verify Container Is Running
    ${_rc}=	Is Container Running	${container}
    Should Be Equal As Integers	${_rc}	1

Verify Container IP Address
    ${_o}=	Container IP Address	${container}
    Log To Console	\nContainer IP address: ${_o}
    Should Contain X Times	${_o}	\.	3

Verify Container Stops
    ${_rc}=	Stop Container	${container}

Verify Container Stopped
    ${_rc}=	Is Container Running	${container}
    Should Be Equal As Integers	${_rc}	0

Verify Destroy Container
    ${_rc}=	Destroy Container	${container}
    Should Be Equal As Integers	${_rc}	0
