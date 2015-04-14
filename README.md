Buildroot based Mistify-OS
==========================

[Buildroot](http://buildroot.uclibc.org/), another popular and feature rich tool for building embedded Linux systems, is used to build the kernel and root file system of the Mistify-OS project. The *buildmistify* script encapsulates much of the process of building a kernel and initrd which can be installed on the boot server and booted on the target using the PXE protocol.

To build the OS, simply run the *buildmistify* script with no parameters. The script begins by downloading the Buildroot build environment and finishes with completed images. When complete the *buildmistify* script displays the location of the images. The images can then be uploaded to the boot server for testing.

btw: The resulting images have been proven and are currently running on a Dell R620.

## Latest developments

### External toolchain

The system build now uses an external toolchain built from source using [crosstool-NG](http://crosstool-ng.org). This serves two purposes. One, the time to rebuild Mistify-OS is reduced once the external toolchain has been built and two, the toolchain can be better optimized for Mistify-OS.

### systemd

Mistify-OS has been updated to use [systemd](http://en.wikipedia.org/wiki/Systemd).

### GO

[GO](https://golang.org) projects can now be built using *buildmistify*. The compiler is built from source to allow for situations where the host architecture is different from the target architecture.

### mistify-agent

The [mistify-agent](https://github.com/mistifyio/mistify-agent) is now built under Buildroot and runs on the test box.

### Virtualization

QEMU/KVM and libvirt are now available.

## Release notes

Release notes for the various releases can be found on the [project wiki](https://github.com/mistifyio/mistify-os/wiki). 

### Verification testing
A test suite for verifying Mistify-OS based upon [Robot Framework](http://robotframework.org/) is now available. This is extremely basic at the moment but will improve over time. The associated scripts are contained in the *test* directory. Use the script *testmistify* to execute test suites.

### Sample Sub-Agent
A sample sub-agent written in GO is provided which can serve as a starting point for your sub-agent development. This sub-agent is contained in the *subagents* directory. Building the sub-agent is supported using the *buildgopackage* script and an example test script for testing the sub-agent in a KVM based virtual machine is provided in *test/testcases/MistifyOSInVm.robot*. The test suite referencing this test script is *test/testsuites/vmtests*.

More information about developing Mistify-OS subagents can be found in the [mistify-agent examples](https://github.com/mistifyio/mistify-agent/tree/master/examples/simple-subagent) repository.

## ToDo

### Multi-platform
At this time only the Dell R620 has been used as a target platform. The build needs to be verified to work for a range of platforms. NOTE: At this time only **x86_64** based architectures are supported.

### Proper user configuration
At the moment the Buildroot built bootable image only supports the *root* user. A non-superuser account is needed and the *root* console login disabled for security reasons. The user needs to have sudo capability so that *root* tasks can be performed when necessary.

## The buildmistify script approach

One of the primary reasons for using the *buildmistify* script is that it serves to maintain isolation of the Mistify-OS specific components from the main Buildroot tree. This is important for two reasons. One, it places all of the Mistify-OS related files in a single tree and two, it simplifies development because of not having to navigate the Buildroot tree in order to find Mistify-OS related files.

The *buildmistify* script also simplifies maintenance of configuration files for Buildroot, the Linux kernel and for Busybox. It's strongly recommended that *buildmistify* be used when changing configurations. The reason for this is the script handles some corner cases which can lead to a loss of synchronization between your project and what Buildroot is actually using. This is particularly true when doing fresh, ground up, builds. To support this the *buildmistify* script traps the configuration targets *menuconfig*, *linux-menuconfig* and, *busybox-menuconfig*. **WARNING**: Do not manually edit the config files or some strange and unexpected results could occur. Always use *buildmistify* when reconfiguring your project for your target hardware.

The *buildmistify* script uses Buildroot features to maintain the Mistify-OS sources and builds outside the Buildroot tree. This simplifies updates of Buildroot when necessary. Read the [Building out-of-tree](http://buildroot.uclibc.org/downloads/manual/manual.html#_building_out_of_tree) and [Keeping customizations outside of Buildroot](http://buildroot.uclibc.org/downloads/manual/manual.html#outside-br-custom) sections of the Buildroot manual for more information.

## Building Mistify-OS

Read this [wiki page](https://github.com/mistifyio/mistify-os/wiki/Building-from-Source) for instructions for getting started building Mistify-OS from source.

### Container Based Builds

A special test suite named *buildtests* is provided to support building Mistify-OS inside an [lxc](https://linuxcontainers.org/) container. Another testsuite named *containertests* can help creating and properly provisioning an *lxc* based container for building Mistify-OS. Currently, this supports only 64 bit containers running an Ubuntu 14.04 (trusty) distribution.

### Help options

The *buildmistify* script supports two forms of help. Using the *--help* option will display the usage for *buildmistify*. On the other hand, *help* is treated as a target and passed to Buildroot which will then display its help information. 

All other scripts support the *--help* option and provide a fairly comprehensive description of how to use the scripts and what the various options are.

### The *jenkins* Script

If you plan to use Jenkins for CI you might find the *jenkins* script useful. It's designed to trigger a build on a [Jenkins](https://jenkins-ci.org/) server for the current repository branch. Of course it requires a corresponding configuration of a *Jenkins* job to accept the parameters passed by the *jenkins* script. You can use the *--dryrun* option to see what the commnand to the *Jenkins* server will be and use that to configure the options for the job on the *Jenkins* server.

## Booting your test box

### An example:

This example assumes two boxes. One box serves as the boot server configured to support DHCP and the PXE boot protocol. The other box serves as the target. Change the IP addresses to match your network environment.

The boot server at IP:10.8.30.15 serves the boot files to the target machine. The boot process itself uses *ipxe*. The *ipxe* configuration resides on the server in the directory **/var/www/html**.

Currently the *ipxe* configuration supports booting an Ubuntu based system to some boxes and a Buildroot based build to a single test box. The DHCP server is also configured to set this test box IP to 10.8.30.13.

The Ethernet port on the test box uses two MAC addresses. The first is used by *ipxe* to which the DHCP assigns the IP address 10.8.30.202. The second MAC address is used by the Linux environment. This second MAC address is the MAC address to which the DHCP server assigns the IP address 10.8.30.13.

The *netboot.ipxe* config file tests for the boot IP address of 10.8.30.202 and when true branches to a Buildroot specific section which specifies the files *initrd.buildroot" and *bzImage.buildroot". The *ipxe.exe* now running on the target box (specified in the *dhcpd* config file) reads this config and then downloads the appropriate images from the server. After the download completes the RAM disk is initialized and control is passed to the downloaded kernel. It's all Linux from that point on.

Once Linux has been booted it should be possible to *ssh* to the box using the IP 10.30.8.13. For now only the "root" user is supported. For development purposes the root password is **LetMeIn2**. (e.g. `ssh root@10.8.30.13`)

