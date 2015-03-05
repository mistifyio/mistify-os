*** Settings ***
Documentation	This test suite runs the buildmistify script in a
...		container and checks progress along the way.
...
...	NOTE: This can take an hour or two to complete depending
...	upon network and computer performance. The container must have already
...	been created and provisioned.

Resource	test/resources/mistify.robot
Resource	test/resources/ssh.robot
Resource	test/resources/lxc.robot

Suite Setup             Setup Testsuite
Suite Teardown          Teardown Testsuite

*** Variables ***
${prompt}=	${USER}@${DISTRO_LONG_NAME}

*** Test Cases ***
Get Container IP Address
    ${ip}=	Container IP Address  ${DISTRO_LONG_NAME}
    Set Suite Variable  ${ip}

Connect To The Container
    [Documentation]	Connect to the container.
    ...
    ...		This assumes the container has been created and the
    ...		user created using the calling user's credentials by
    ...		the AddUserToContainer script.
    Log To Console  \nLogging in as ${USER} to container at IP: ${ip}
    Login to SUT  ${ip}  ${USER}  ${USER}

Start The Build
    [Documentation]	Start a Mistify build.
    ...
    ...		This assumes the container has already been created
    ...		and provisioned. However, the clone of the Mistify-OS
    ...		repo has not yet occurred.
    ssh.Write  cd ~
    # There is a the question of re-running this script and having
    # the project already cloned. For now assume this is the first
    # run in the container.
    ssh.Write	git clone ${GIT_URL}
    ${_o}=	ssh.Read Until  ${prompt}
    Should Contain  ${_o}  ... done.

Monitor The Build


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
