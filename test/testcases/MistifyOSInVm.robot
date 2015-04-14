*** Settings ***
Documentation   This series of tests verifies the Mistify-OS will boot in a
...		KVM based virtual machine.
...
...	NOTE: This relies upon the VM network setup script and the script to
...	start the virtual machine.
...	The approach is to configure the network for connecting to the VM and
...	then starting the VM. The boot messages are monitored for progress.

Library		String
Resource	test/resources/mistify.robot
Resource	test/resources/ssh.robot

Suite Setup	Login To Localhost

*** Test Cases ***
Configure Network
    [Documentation]	This runs the vm-network script to setup the for
    ...			this test.
    ...
    ...		NOTE: The default options are used.
    ...		WARNING: The script vm-network requires root access using sudo.
    ...		Currently this script doesn't respond to a prompt for a password. To
    ...		To avoid problems a simple "sudo ls" before running this test
    ...		should be sufficient for most sudo configurations where a
    ...		sudo timeout of 15 minutes is the norm.

    [Tags]    DEBUG
    Login To Localhost
    Log To Console  Configuring the network.
    ssh.Set Client Configuration  timeout=15s
    ssh.Write  cd ${PWD}
    ssh.Write  test/scripts/vm-network --verbose
    ${_o}=  ssh.Read Until
    ...  Network is now configured for running a VM

Start The VM
    [Documentation]	This runs Mistify-OS in a VM using prebuilt images.
    ...
    ...		NOTE: The default options are used.

    ssh.Write  test/scripts/start-vm
    ssh.Set Client Configuration  timeout=3m
    ${_o}=  ssh.Read Until  ${MISTIFY_LOGIN_PROMPT}
    Should Contain  ${_o}  Set hostname to <
    Should Contain  ${_o}  Reached target Multi-User System
    ssh.Set Client Configuration  timeout=15s

Login to VM
    [Documentation]	Login as root to the default console.

    ssh.Write  ${MISTIFY_USERNAME}
    ssh.Read Until  Password:
    ssh.Write  ${MISTIFY_PASSWORD}
    ssh.Read Until  ${MISTIFY_VM_PROMPT}

Get IP Address
    [Documentation]	Retrieve the IP address from the running instance and
    ...			save it for later to login using ssh.

    ssh.Write  ifconfig \| grep 10\\.0\\. \| tr -s \' \' \| cut -d \' \' -f 3
    ${_o}=  ssh.Read Until  ${MISTIFY_VM_PROMPT}
    ${_l}=	Get Lines Containing String  ${_o}  10.0
    Log To Console  \nVM IP address is: ${_l}

Show Running Agent Processes
    [Documentation]	Log the processes which have "agent" as part of their
    ...			name.
    ssh.Write  ps aux \| grep agent
    ${_o}=  ssh.Read Until  ${MISTIFY_VM_PROMPT}
    Log To Console  \nAgent related processes are:
    ${_l}=  String.Get Lines Containing String  ${_o}  agent
    Log To Console  ${_l}

Start The Subagent
    [Documentation]	Start the subagent from the command line.
    ...	NOTE: In normal situations the subagent would be started automatically
    ...	during boot. This however can simplify development iterations.
    ssh.Write  /opt/mistify/sbin/sample-subagent &
    ${_o}=  ssh.Read Until  ${MISTIFY_VM_PROMPT}
    ssh.Write  ps aux \| grep sample-subagent
    ${_o}=  ssh.Read Until  ${MISTIFY_VM_PROMPT}
    Should Contain  ${_o}  /opt/mistify/sbin/sample-subagent

Verify Subagent Is Listening
    [Documentation]	Send a message to the subagent to verify it is running
    ...			and listening.
    ${_c}=	catenate  SEPARATOR=${SPACE}
    ...	curl -s -H "Content-Type: application/json"
    ...	http://localhost:9999/_mistify_RPC_
    ...	--data-binary '{ "method": "Test.Restart",
    ...	"params": [ { "guest": { "id": "123456789" } } ], "id": 0 }'
    ssh.Write  ${_c}
    ${_o}=  ssh.Read Until  ${MISTIFY_VM_PROMPT}
    Should Contain  ${_o}  {"result":{"guest":{"id":"123456789"}},"error":null,"id":0}
    Log To Console  \nSubagent responded with:
    Log To Console  ${_o}

#+
# Add additional tests here.
#-

Logout from VM
    [Documentation]	Logout from the VM.

    ssh.Write  exit
    ${_o}=  ssh.Read Until  ${MISTIFY_LOGIN_PROMPT}

Shutdown the VM
    [Documentation]	Uses the ^A-X sequence to shutdown the VM instance.

    ${_c_a}=	 Evaluate  chr(int(1))
    ssh.Write Bare  ${_c_a}x
    ${_o}=  ssh.Read Until  QEMU: Terminated

Shutdown Network
    [Documentation]	This shuts down the interfaces which were created for
    ...			this test using the vm-network script.
    ...
    ...		NOTE: Again this requires use of sudo. If the above tests take
    ...		a long time then the sudo permissions may have timed out.
    ...		This problem will be dealt with at some point. Until then
    ...		it may be necessary to do some hack to keep the permissions
    ...		long enough for this test.

    Log To Console	\n
    Log To Console	++++++++++++++++++++++++++++++++
    Log To Console	NOTE: The network interfaces which were created for this test have NOT
    Log To Console	been disabled. If you want to shutdown those interfaces it is necessary
    Log To Console	to run vm-network from the command line.
    Log To Console	e.g. test/scripts/vm-network --shutdown
    Log To Console	This necessary because of having to use sudo and not wanting to
    Log To Console	prompt for a password.
    Log To Console	--------------------------------
    # ssh.Set Client Configuration  timeout=15s
    # ssh.Write  test/scripts/vm-network --verbose --shutdown
    # ${_o}=  ssh.Read Until  VM related interfaces have been removed.

*** Keywords ***
