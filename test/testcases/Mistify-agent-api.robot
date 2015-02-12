*** Settings ***
Documentation	This test runs the test-api.sh script and verifies some of its output.

Resource	test/resources/mistify.robot
Library		OperatingSystem

*** Variables ***

*** Test Cases ***
Verify Test Script Exists
    [Documentation]	This verifies the test script exists.
    ${_o}=	Run 	ls test
    Should Contain	${_o}	test-api.sh

Check Mistify Agent Api Running
    [Documentation]	This runs the test-api.sh script and checks some of its output.

    [Tags]    DEBUG
    ${o}=	Run
    ...	test/test-api.sh ${TESTBED_IP}
    Set Suite Variable	${o}
    Should Contain	${o}
    ...	Host: ${TESTBED_IP}

Verify Connected To Host
    [Documentation]	Verifies the test script connected to the host.

    [Tags]    DEBUG
    Should Contain	${o}
    ...	Connected to ${TESTBED_IP}

Verify Is Json Output
    [Documentation]	Verify that the return data is formatted as json.

    [Tags]    DEBUG
    Should Contain	${o}
    ...	Content-Type: application/json

Verify First Content Length
    [Documentation]	Verifies the content length is 33 bytes.

    [Tags]    DEBUG
    Should Contain	${o}
    ...	Content-Length: 33

Verify Upload Length
    [Documentation]	Verifies the upload length is correct.

    [Tags]    DEBUG
    Should Contain	${o}
    ...	upload completely sent off: 33 out of 33 bytes

Verify Next Length
    [Documentation]	Verifies the next content length.

    [Tags]    DEBUG
    Should Contain	${o}
    ...	Content-Length: 30

Verify Hello World
    [Documentation]	Verifies the Hello World message.

    [Tags]    DEBUG
    Should Contain	${o}
    ...	"hello": "world",

Verify Closing Connection
    [Documentation]	Verifies the connection is closing.

    [Tags]    DEBUG
    Should Contain	${o}
    ...	Closing connection 0

No Failures
    [Documentation]	Verify no 404s were returned.

    [Tags]    DEBUG
    Should Not Contain	${o}
    ...	404 Not Found

*** Keywords ***
