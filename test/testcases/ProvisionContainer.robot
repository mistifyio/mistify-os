*** Settings ***
Documentation	This verifies the Mistify-OS build process using a Linux
...		container.
...
...	This test suite creates an LXC container and then runs buildmistify
...	within the container.
...
...	NOTE: At the moment the build is run as root. Later an actual user
...	will be created.
...	WARNING: Currently this works only for Debian based distros.

Library		String

Resource	test/resources/mistify.robot
Resource	test/resources/ssh.robot
Resource	test/resources/lxc.robot

Suite Setup             Setup Testsuite
Suite Teardown          Teardown Testsuite

*** Variables ***
${prompt}=	root@${DISTRO_LONG_NAME}

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
    ${_o}=  ssh.Read Until  ${prompt}
    Log To Console  \nAttach:\n${_o}
    Should Contain  ${_o}  ${prompt}

Define Package List
    [Documentation]	Creating this variable here because RF complained
    ...			about using this technique in the variables section
    ...			and using a true list wasn't producing the desired
    ...			results for passing the list to apt-get.
    ${packages}=  catenate  SEPARATOR=${SPACE}
    ...  openssh-server  man
    ...  build-essential  git  mercurial  unzip  bc  libncurses5-dev
    ...  syslinux  genisoimage  libdevmapper-dev  libnl-dev
    ...  autoconf  automake  libtool  gettext  autopoint
    ...  pkg-config  flex  gperf  bison  texinfo  gawk  subversion
    ...  gcc-multilib
    Set Suite Variable  ${packages}

Update APT Database
    [Documentation]	The package database needs to be updated
    ...			before the packages can be installed.
    Log To Console  \nThis works only for debian based distros!!
    Log To Console  \nInstalling: ${packages}
    ssh.Write  ls /
    ${_o}=  ssh.Read Until  ${prompt}  loglevel=INFO
    Log To Console  \nUpdating the package database.
    ssh.Set Client Configuration  timeout=1m
    ssh.Write  apt-get update
    ${_o}=  ssh.Read Until  ${prompt}  loglevel=INFO

Install Key Tools
    ssh.Write  apt-get install -y ${packages}
    ssh.Set Client Configuration  timeout=20m
    ${_o}=  ssh.Read Until  ${prompt}  loglevel=INFO
    Log To Console  \napt-get returned:\n${_o}
    ssh.Set Client Configuration  timeout=3m

Verify Key Tools Installed
    Log To Console  \nThis works only for debian based distros!!
    Log To Console  \nPackage list: ${packages}
    ssh.Write  dpkg -l \| awk '/^[hi]i/{print $2}'
    ${_o}=	ssh.Read Until	${prompt}
    Log To Console  \nInstalled packages:\n${_o}
    @{_packages}=	Split String  ${packages}
    :FOR  ${_p}  IN  @{_packages}
    	\	Should Contain  ${_o}  ${_p}

Disconnect From Container
    ssh.Write  exit
    ${_o}=  ssh.Read Until  exit
    Should Contain  ${_o}  exit
    Disconnect From Localhost

*** Keywords ***
Setup Testsuite
    ${_rc}=	Use Container
    ...	${DISTRO_LONG_NAME}	${DISTRO_NAME}
    ...	${DISTRO_VERSION_NAME}	${DISTRO_ARCH}
    Log To Console	\nUsing container: ${DISTRO_LONG_NAME}
    Run Keyword Unless  ${_rc} == 0
    ...	Log To Console	\nContainer could not be created.
    ...		WARN

Teardown Testsuite
    Stop Container	${DISTRO_LONG_NAME}

