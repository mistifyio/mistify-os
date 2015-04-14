# ABOUT #
This is a sample sub-agent based upon the [example test-rpc-service](https://github.com/mistifyio/mistify-agent/tree/master/examples/test-rpc-service) sub-agent in the mistify-agent repository.

More information regarding developing sub-agents is available in the [example simple-subagent](https://github.com/mistifyio/mistify-agent/tree/master/examples/simple-subagent).

**NOTE**: If you want to use this sub-agent as a starting point for developing a new sub-agent it is recommended this be copied to your development directory.

See `agent.json` for a config for the Agent that uses this sub-agent for all actions.

## Testing Inside a VM

The *testmistify* script can be used to run your sub-agent inside a KVM based virtual machine. In particular the [vmtests](https://github.com/mistifyio/mistify-os/tree/master/test/testsuites/vmtests) testsuite and the [MistifyOSInVm.robot](https://github.com/mistifyio/mistify-os/blob/master/test/testcases/MistifyOSInVm.robot) script be used as a starting point for your tests.

The script *testmistify* is designed to start and execute these tests using Robot Framework.


