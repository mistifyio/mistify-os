*** Settings ***
Documentation	Common variables and keywords for SSH connections to
...		the system under test.
...
...	These variables and keywords are common to SSH connections.

Library		SSHLibrary	with name	ssh

*** Keywords ***
Login To SUT
    [Documentation]	Creates an SSH connection to the SUT (System Under Test)
    ...
    ...		The SUT can be an actual running platform or a QEMU/KVM
    ...		virtual machine.
    ssh.Open Connection	${TESTBED_IP}
    ssh.Login		${USERNAME}	${PASSWORD}

Disconnect From SUT
    [Documentation]	Close all open SSH connections.
    ...
    ...		It is possible a test will open multiple SSH connections
    ...		to the SUT.
    ssh.Close All Connections
