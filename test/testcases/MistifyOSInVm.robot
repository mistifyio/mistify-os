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
    Should Contain  ${_o}  Set hostname to <Mistify-OS>
    Should Contain  ${_o}  Reached target Multi-User System
    ssh.Set Client Configuration  timeout=15s

Login to VM
    [Documentation]	Login as root to the default console.

    ssh.Write  ${MISTIFY_USERNAME}
    ssh.Read Until  Password:
    ssh.Write  ${MISTIFY_PASSWORD}
    ssh.Read Until  ${MISTIFY_PROMPT}

Get IP Address
    [Documentation]	Retrieve the IP address from the running instance and
    ...			save it for later to login using ssh.

    ssh.Write  ifconfig \| grep 10\\.0\\. \| tr -s \' \' \| cut -d \' \' -f 3
    ${_o}=  ssh.Read Until  ${MISTIFY_PROMPT}
    ${_l}=	Get Lines Containing String  ${_o}  10.0
    Log To Console  \nVM IP address is: ${_l}

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
