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
# For login to a running instance of Mistify-OS
${MISTIFY_USERNAME}	root
${MISTIFY_PASSWORD}	LetMeIn2
# Mistify-OS when running on hardware uses a UUID as part of the prompt.
${MISTIFY_PROMPT}	root@
# When running in a development machine in a VM the prompt is localhost.
${MISTIFY_VM_PROMPT}	root@localhost

${MISTIFY_LOGIN_PROMPT}	login:

# To clone the Mistify-OS repo for building.
${MISTIFY_OS_REPO}	mistify-os
${MISTIFY_GIT_URL}	git@github.com:mistifyio/${MISTIFY_OS_REPO}.git
${MISTIFY_CLONE_DIR}	${MISTIFY_OS_REPO}
