*** Settings ***
Documentation	This verifies the Mistify-OS build process using a Linux
...		container.
...
...	This test suite creates an LXC container and then runs buildmistify
...	within the container.
...
...	NOTE: At the moment the build is run as root. Later an actual user
...	will be created.

Resource	test/resources/mistify.robot
Resource	test/resources/ssh.robot
Resource	test/resources/lxc.robot

Suite Setup             Setup Testsuite
Suite Teardown          Teardown Testsuite

*** Variables ***

*** Test Cases ***
Verify Container Is Running
    ${_rc}=	Is Container Running	${DISTRO_LONG_NAME}
    Should Be Equal As Integers	${_rc}	1

Get Container IP Address
    Log To Console	\n
    ${_o}=	Container IP Address	${DISTRO_LONG_NAME}
    Log To Console	\nContainer IP address: ${_o}
    Should Contain X Times	${_o}  \.  3
    Set Suite Variable	${ip}  ${_o}
    Log To Console	\nContainer IP address is: ${ip}

Connect To Container
    Login To Localhost
    ssh.Write  lxc-attach -n ${DISTRO_LONG_NAME}
    ${_o}=  ssh.Read Until  root@
    Should Contain  ${_o}  root@

Install Key Tools
    ${_components}=  catenate  SEPARATOR=
    ...  ${SPACE} openssh-server man
    ...  ${SPACE} build-essential git mercurial unzip bc libncurses5-dev
    ...  ${SPACE} syslinux genisoimage libdevmapper-dev libnl-dev
    ...  ${SPACE} autoconf automake libtool gettext autopoint
    ...  ${SPACE} pkg-config flex gperf bison texinfo gawk subversion
    Log To Console  \nInstalling: ${_components}
    ssh.Set Client Configuration  timeout=20m
    ssh.Write  apt-get install -y ${_components}
    ${_o}=  ssh.Read Until  root@${DISTRO_LONG_NAME}
    ssh.Set Client Configuration  timeout=3m

Disconnnet From Container
    ssh.Write  exit
    ${_o}=  ssh.Read Until  exit
    Should Contain  ${_o}  exit

*** Keywords ***
Setup Testsuite
    ${_rc}=	Does Container Exist  ${DISTRO_LONG_NAME}
    ${_rc}=	Run Keyword If  ${_rc} == 0  # 0 indicates no
    ...	Create Build Container
    Run Keyword Unless	${_rc} == None # None indicates using existing container.
    ...	Should Be Equal As Integers	${_rc}	0
    ${_rc}=	Start Container	${DISTRO_LONG_NAME}
    Should Be Equal As Integers	${_rc}	0
    ${_ip}=	Container IP Address	${DISTRO_LONG_NAME}
    Set Suite Variable	${_ip}
    Log To Console	\nUsing container ${DISTRO_LONG_NAME} at IP address: ${_ip}

Teardown Testsuite
    Stop Container	${DISTRO_LONG_NAME}

Create Build Container
    ${_rc}=	Create Unprivileged Container
    ...	${DISTRO_LONG_NAME}	${DISTRO_NAME}
    ...	${DISTRO_VERSION_NAME}	${DISTRO_ARCH}
    [Return]	${_rc}
