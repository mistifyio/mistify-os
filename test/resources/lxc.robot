*** Settings ***
Documentation	This test creates a Linux Container (lxc) in which to
...		run test builds and more.
...
...	Part of testing Mistify-OS is verfiying it will build under
...	different configurations. It has been shown that buildroot
...	is not a perfect solution for build isolation. For example
...	there have been instances where a distro's installed
...	libraries or header files have been used when they shouldn't
...	have. This has created situations where a build works fine
...	on one distro but fails on another. This component is intended
...	to create a container based upon a specific distro to verify
...	a Mistify-OS build.
...
...	NOTE: This creates an unprivileged container.

Library		OperatingSystem

*** Keywords ***
Test LXC Is Installed
    ${_o}=	Run	lxc-create --help
    Should Contain	${_o}	lxc-create creates a container

Create Unprivileged Container
    [Arguments]	${_container_name}	${_distro_name}
    ...	${_distro_version_name}	${_distro_arch}
    Log To Console	\n
    ${_c}=	catenate	SEPARATOR=
    ...  lxc-create -t download
    ...  ${SPACE} -n ${_container_name}
    ...  ${SPACE} -- -d ${_distro_name} -r ${_distro_version_name}
    ...  ${SPACE} -a ${_distro_arch}
    ${_rc}	Run And Return Rc	${_c}
    [Return]	${_rc}

Container List
    ${_o}=	Run	lxc-ls
    [Return]	${_o}

Start Container
    [Arguments]	${_container_name}
    ${_rc}=	Run And Return Rc	lxc-start -d -n ${_container_name}
    # Some time is needed for the container to obtain an IP address.
    ${_o}=	Run	sleep 5
    [Return]	${_rc}

Does Container Exist
    [Documentation]	Tests to see if the container exists and is either
    ...			running or stopped.
    ...
    ...		Returns 1 if the container exists and 0 if it doesn't.
    [Arguments]	${_container_name}
    ${_rc}=	Run And Return Rc
	...	lxc-ls -f --running --stopped \| grep \'${_container_name}\\s\'
    Return From Keyword If	${_rc} == ${0}	${1}
    [Return]	${0}

Is Container Running
    [Arguments]	${_container_name}
    ${_rc}=	Run And Return Rc
	...	lxc-ls -f --running \| grep \'${_container_name}\\s\'
    Return From Keyword If	${_rc} == ${0}	${1}
    [Return]	${0}

Container IP Address
    [Arguments]	${_container_name}
    ${_o}=	Run	lxc-ls -f --running
    Log To Console	\nRunning containers:\n${_o}
    ${_c}=	catenate	SEPARATOR=
	...	lxc-ls -f --running \|${SPACE}
	...	grep \'${_container_name}\\s\' \|${SPACE}
	...	tr -s \' \' \|${SPACE}
	...	cut -d \' \' -f 3
    ${_o}=	Run	${_c}
    Log To Console	\nCommand: ${_c} returned: ${_o}
    [Return]	${_o}

Stop Container
    [Arguments]	${_container_name}
    ${_rc}	Run And Return Rc	lxc-stop -n ${_container_name}
    [Return]	${_rc}

Destroy Container
    [Arguments]	${_container_name}
    ${_rc}=	Run And Return Rc	lxc-destroy -n ${_container_name}
    [Return]	${_rc}
