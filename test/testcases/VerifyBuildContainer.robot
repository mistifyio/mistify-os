*** Settings ***
Documentation	This verifies an LXC based container can be created and is
...		functional.

Resource	test/resources/mistify.robot
Resource	test/resources/lxc.robot

*** Test Cases ***
Verify LXC is installed
    Test LXC Is Installed

Verify Container Creation
    ${_rc}=	Create Unprivileged Container
    ...	${DISTRO_LONG_NAME}	${DISTRO_NAME}
    ...	${DISTRO_VERSION_NAME}	${DISTRO_ARCH}
    Should Be Equal As Integers	${_rc}	0

Verify Container Exists
    ${_o}=	Container List
    Should Contain	${_o}
    ...	${DISTRO_LONG_NAME}

Verify Container Starts
    ${_rc}=	Start Container	${DISTRO_LONG_NAME}
    Should Be Equal As Integers	${_rc}	0

Verify Container Is Running
    ${_rc}=	Is Container Running	${DISTRO_LONG_NAME}
    Should Be Equal As Integers	${_rc}	1

Verify Container IP Address
    ${_o}=	Container IP Address	${DISTRO_LONG_NAME}
    Log	Container IP address: ${_o}
    Should Contain X Times	${_o}	\.	3

Verify Container Stops
    ${_rc}=	Stop Container	${DISTRO_LONG_NAME}

Verify Container Stopped
    ${_rc}=	Is Container Running	${DISTRO_LONG_NAME}
    Should Be Equal As Integers	${_rc}	0

Verify Destroy Container
    ${_rc}=	Destroy Container	${DISTRO_LONG_NAME}
    Should Be Equal As Integers	${_rc}	0
