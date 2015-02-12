*** Settings ***
Documentation	Common definitions and keywords for tesing Mistify-OS.
...
...	This contains variables and keywords common to all Mistify-OS
...	builds. It also brings in the test bed specific information so
...	that test suites need not repeat those lines.

Resource	${TESTBED}

*** Variables ***
${USERNAME}	root
${PASSWORD}	LetMeIn2

