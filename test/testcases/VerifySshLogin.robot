*** Settings ***
Documentation	This test suite verifies ssh login into a Mistify-OS host.
...
...	This simply logs in and execute some commands to verify the
...	SUT is actually running Mistify-OS.

Resource	test/resources/mistify.robot
Resource	test/resources/ssh.robot

Suite Setup	Setup Testsuite
Suite Teardown	Teardown Testsuite

*** Test Cases ***
Verify Is Mistify-OS
    [Documentation]	Verify that the Mistify-OS is running.
    ...
    ...		Examine the output from different commands to verify
    ...		the Mistify-OS is running on the platform.

    ${o}=	ssh.Execute Command	uname -a
    Should Contain	${o}  Mistify-OS

*** Keywords ***
Setup Testsuite
    Login To SUT  ${TESTBED_IP}  ${USERNAME}  ${PASSWORD}

Teardown Testsuite
    Comment	Teardown happens automatically when the test suite ends.
