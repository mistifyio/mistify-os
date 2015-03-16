*** Settings ***
Documentation	This creates a user having the same credentials as the
...		user running this testsuite.
...
...	A problem with using unprivileged containers is the user and
...	group IDs are remapped for security reasons. This enables root
...	access inside the container without worry of corrupting the host
...	environment. The problem is that the host side user can't easily
...	install keys for use with other hosts (e.g. github) and results
...	in having to enter a password over and over again which is
...	unacceptable for unattended builds.
...
...	This script deals with that problem by creating a user of the
...	same name in the container using a known password and then
...	uses that password to install keys in the user's home directory
...	within the container.

Library		String

Resource	test/resources/mistify.robot
Resource	test/resources/ssh.robot
Resource	test/resources/lxc.robot

Suite Setup             Setup Testsuite
Suite Teardown          Teardown Testsuite

*** Variables ***
${prompt}=	root@${DISTRO_LONG_NAME}
${userprompt}=	${USER}@${DISTRO_LONG_NAME}

*** Test Cases ***
Connect To Container
    Login To Localhost
    ssh.Write  lxc-attach -n ${DISTRO_LONG_NAME}
    ${_o}=  ssh.Read Until  ${prompt}
    Log To Console  \nAttached to: ${_o}
    Should Contain  ${_o}  ${prompt}

Create User In Container
    [Documentation]	Create the user account if it doesn't exist.
    ...
    ...		NOTE: It is possible this test is being run following
    ...		a previous run where the user account was created.
    ssh.Write  getent passwd ${USER} \| cut -d : -f 1
    ${_o}=	ssh.Read Until  ${prompt}
    ${_u}=	Get Line  ${_o}  0
    Run Keyword If  '${_u}' != '${USER}'
    ...  Create User  ${USER}

Verify User Entry In Passwd
    ssh.Write  grep ${USER} ${/}etc${/}passwd
    ${_o}=  ssh.Read Until  ${prompt}
    Log To Console  \nGrep returned: ${_o}
    Should Contain  ${_o}  ${USER}

Verify User Entry In Group
    ssh.Write  grep ${USER} ${/}etc${/}group
    ${_o}=  ssh.Read Until  ${prompt}
    Log To Console  \nGrep returned: ${_o}
    Should Contain  ${_o}  ${USER}

Verify User Home Directory
    ssh.Write  ls ${/}home \| grep ${USER}
    ${_o}=  ssh.Read Until  ${prompt}
    Log To Console  \nGrep returned: ${_o}
    Should Contain  ${_o}  ${USER}

Set User Password
    Log To Console  \nSetting user ${USER} password to ${USER}
    ssh.Write  passwd ${USER}
    ssh.Read Until  password:
    ssh.Write  ${USER}
    ssh.Read Until  password:
    ssh.Write  ${USER}
    ${_O}=  ssh.Read Until  ${prompt}
    Should Contain  ${_o}  password updated successfully
    ssh.Write  exit
    # NOTE: Switching SSH connections is not yet supported.
    Disconnect From Localhost

Verify User Can SSH
    ${ip}=	Container IP Address  ${DISTRO_LONG_NAME}
    Set Suite Variable  ${ip}
    Log To Console  \nLogging in as ${USER} to container at IP: ${ip}
    Login to SUT  ${ip}  ${USER}  ${USER}
    ssh.Write  pwd
    ${homedir}=  ssh.Read Until  ${userprompt}
    Should Contain  ${homedir}  ${USER}
    Set Suite Variable  ${homedir}
    Disconnect From SUT

Transfer User Keys
    [Documentation]	The user keys are needed mostly for the build
    ...			process.
    ...
    ...		The build accesses a number of git repositories. Having
    ...		the keys means not having to enter the password. In order
    ...		for this to work the public keys need to be installed on
    ...		the different servers.
    Log To Console	\nCopying local keys from ${HOME} to\n
    ...  		the container at ${homedir}.
    Login to SUT  ${ip}  ${USER}  ${USER}
    ssh.Put Directory  ${HOME}/.ssh  /home/${USER}  mode=600
    Log To Console  Copied keys.
    Disconnect From SUT

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
    ssh.Close All Connections
    Stop Container	${DISTRO_LONG_NAME}

Create User
    [Arguments]  ${_user}
    Log To Console  \nCreating user: ${_user}
    ssh.Write  useradd -m -s ${/}bin${/}bash -U ${_user}
    ssh.Read Until  ${prompt}

