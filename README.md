Buildroot based Mistify-OS
==========================

[Buildroot](http://buildroot.uclibc.org/), another popular and feature rich tool for building embedded Linux systems, is used to build the kernel and root file system of the Mistify-OS project. The *buildmistify* script encapsulates much of the process of building a kernel and initrd which can be installed on the boot server and booted on the target using the PXE protocol.

To build the OS, simply run the *buildmistify* script with no parameters. The script begins by downloading the Buildroot build environment and finishes with completed images. When complete the *buildmistify* script displays the location of the images. The images can then be uploaded to the boot server for testing.

btw: The resulting images have been proven and are currently running on a Dell R620.

## Latest developments

### GO

[GO](https://golang.org) projects can now be built using *buildmistify*.

### mistify-agent

The [mistify-agent](https://github.com/mistifyio/mistify-agent) is now built under Buildroot and runs on the test box.

### Virtualization

QEMU and libvirt are now available.

## Known problems

### The Ethernet interface has to be started twice

The Ethernet interface eno3 requires some settle time before attempting a DHCP request. This is currently being dealt with using pre-up steps in the */etc/network/interfaces* file. A sleep of 4 seconds following bringing the interface up.

## ToDo

### Kernel configuration
Kernel configuration needs to be tuned for what Mistify-OS will actually need.

### Verification testing
A test suite for verifying Mistify-OS is needed.

### Multi-platform
At this time only the Dell R620 has been used as a target platform. The build needs to be verified to work for a range of platforms. NOTE: At this time only **x86_64** based architectures will be supported.

### Build tools and kernel CPU optimizations
When best performance is a requirement it's sometimes necessary to tune the kernel and compiler to take advantage of specific CPU features. This needs to be studied in the Mistify-OS context to determine what --if anything-- needs to be done.

### Proper user configuration
At the moment the Buildroot built bootable image only supports the *root* user. A non-superuser account is needed and the *root* console login disabled for security reasons. The user needs to have sudo capability so that *root* tasks can be performed when necessary.

## The buildmistify script approach

One of the primary reasons for using the *buildmistify* script is that it serves to maintain isolation of the Mistify-OS specific components from the main Buildroot tree. This is important for two reasons. One, it places all of the Mistify-OS related files in a single tree and two, it simplifies development because of not having to navigate the Buildroot tree in order to find Mistify-OS related files.

The *buildmistify* script also simplifies maintenance of configuration files for Buildroot, the Linux kernel and for Busybox. It's strongly recommended that *buildmistify* be used when changing configurations. The reason for this is the script handles some corner cases which can lead to a loss of synchronization between your project and what Buildroot is actually using. This is particularly true when doing fresh, ground up, builds. To support this the *buildmistify* script traps the configuration targets *menuconfig*, *linux-menuconfig* and, *busybox-menuconfig*. WARNING: Do not manually edit the config files or some strange and unexpected results could occur. Always use *buildmistify* when reconfiguring your project for your target hardware.

The *buildmistify* script uses Buildroot features to maintain the Mistify-OS sources and builds outside the Buildroot tree. This simplifies updates of Buildroot when necessary. Read the [Building out-of-tree](http://buildroot.uclibc.org/downloads/manual/manual.html#_building_out_of_tree) and [Keeping customizations outside of Buildroot](http://buildroot.uclibc.org/downloads/manual/manual.html#outside-br-custom) sections of the Buildroot manual for more information.

### Help options

The *buildmistify* script supports two forms of help. Using the *--help* option will display the usage for *buildmistify*. On the other hand, *help* is treated as a target and passed to Buildroot which will then display its help information. 

### QEMU/KVM target build option

Use of a virtual machine greatly accelerates some development tasks. Targets already exist for this but not in a direct Mistify-OS context. The Buildroot build process doesn't support building for multiple "machines" in one pass. Instead, the config file needs to be changed to switch to a different target. The *buildmistify* script can help simplify this task. NOTE: Not yet implemented.

## Booting your test box -- OmniTI internal

### An example:

The boot server at IP:10.8.30.15 serves the boot files to the target machine. The boot process itself uses *ipxe*. The *ipxe* configuration resides on the server in the directory **/var/www/html**.

Currently the *ipxe* configuration supports booting an Ubuntu based system to some boxes and a Buildroot based build to a single test box. The DHCP server is also configured to set this test box IP to 10.8.30.13.

The Ethernet port on the test box uses two MAC addresses. The first is used by *ipxe* to which the DHCP assigns the IP address 10.8.30.202. The second MAC address is used by the Linux environment. This second MAC address is the MAC address to which the DHCP server assigns the IP address 10.8.30.13.

The *netboot.ipxe* config file tests for the boot IP address of 10.8.30.202 and when true branches to a Buildroot specific section which specifies the files *initrd.buildroot" and *bzImage.buildroot". The *ipxe.exe* now running on the target box (specified in the *dhcpd* config file) reads this config and then downloads the appropriate images from the server. After the download completes the RAM disk is initialized and control is passed to the downloaded kernel. It's all Linux from that point on.

Once Linux has been booted it should be possible to *ssh* to the box using the IP 10.30.8.13. For now only the "root" user is supported. For development purposes the root password is **LetMeIn2**. (e.g. `ssh root@10.8.30.13`)

