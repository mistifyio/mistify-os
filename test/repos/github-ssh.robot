*** Settings ***
Documentation	A user for github which can be used to
...		clone a project.
...
...	WARNING: At the moment this approach exposes the user credentials
...	which is inherently dangerous.

*** Variables ***
${GIT_URL}		git@github.com:mistifyio/mistify-os.git

