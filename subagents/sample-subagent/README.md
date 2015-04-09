This is a test service/sub-Agent that simply returns the guest from the request in the response and uses "fake" metrics.

We use this for stubbing out functionality.

See `agent.json` for a config for the Agent that uses this sub-agent for all actions.

Example [runit](http://smarden.org/runit/) scripts:

Service run script
```
#!/bin/sh
# place in /etc/services/test-rpc-service/run
exec 2>&1
ulimit -n 8192
# this sub-agent does not require any special permissions
exec chpst -u nobody /usr/local/bin/test-rpc-service -p 9999
```

Log run script
```
#!/bin/sh
# place in /etc/services/test-rpc-service/log/run
exec 2>&1
mkdir -p /var/log/test-rpc-service
exec svlogd /var/log/test-rpc-service
```
