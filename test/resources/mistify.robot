*** Settings ***
Documentation	Common definitions and keywords for tesing Mistify-OS.
...
...	This contains variables and keywords common to all Mistify-OS
...	builds. It also brings in the test bed specific information so
...	that test suites need not repeat those lines.

#+
# NOTE: The variable TESTBED is passed from the command line by the testmistify
# script. There is no default value for this variable.
#-
Resource	${TESTBED}

#+
# NOTE: The variable DISTRO is passed from the command line by the testmistify
# script. There is no default value for this variable.
#-
Resource	${TESTDISTRO}

*** Variables ***
${USERNAME}	root
${PASSWORD}	LetMeIn2

