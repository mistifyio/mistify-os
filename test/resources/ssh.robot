*** Settings ***
Documentation	Common variables and keywords for SSH connections to
...		the system under test.
...
...	These variables and keywords are common to SSH connections.

Library		SSHLibrary  with name  ssh

*** Keywords ***
Login To SUT
    [Documentation]	Creates an SSH connection to the SUT (System Under Test)
    ...
    ...		The SUT can be an actual running platform or a QEMU/KVM
    ...		virtual machine.
    [Arguments]	${_ip}  ${_user}  ${_password}
    ssh.Open Connection	${_ip}
    ssh.Login	${_user}  ${_password}

Disconnect From SUT
    [Documentation]	Close all open SSH connections.
    ...
    ...		It is possible a test will open multiple SSH connections
    ...		to the SUT.
    ssh.Close All Connections

Login To Localhost
    [Documentation]	Logs into the local host using a public key.
    ...
    ...		The public key must already exist in the path ~/.ssh.
    ...		The public key must be in the ~/.ssh/authorized_keys file.
    ssh.Open Connection  localhost
    Log To Console  \nUser is: %{USER} Home is: %{HOME}
    ssh.Login With Public Key  %{USER}  %{HOME}/.ssh/id_rsa

Disconnect From Localhost
    [Documentation]	Disconnect the ssh session with localhost.
    ...
    ...		WARNING: Currently this disconnects all ssh connections.
    ...		The SUT and Localhost connection IDs need to be saved
    ...		and a session switch added.
    ssh.Close All Connections
