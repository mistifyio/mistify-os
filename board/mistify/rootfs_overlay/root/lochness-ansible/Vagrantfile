# -*- mode: ruby -*-
# vi: set ft=ruby :

# hacks to make CentOS look like our build of Mistify-OS
$script = <<SCRIPT
set -e

if [ ! -x /usr/bin/etcd ] ; then
    cd /tmp/
    curl -L https://github.com/coreos/etcd/releases/download/v2.0.0-rc.1/etcd-v2.0.0-rc.1-linux-amd64.tar.gz -o etcd-v2.0.0-rc.1-linux-amd64.tar.gz
    tar xzvf etcd-v2.0.0-rc.1-linux-amd64.tar.gz
    cd etcd-v2.0.0-rc.1-linux-amd64
    mv etcd /usr/bin/etcd
    mv etcdctl /usr/bin/etcdctl
fi

if [ ! -x /usr/bin/confd ] ; then
    cd /tmp/
    curl -L -O https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64
    mv confd-0.7.1-linux-amd64 /usr/bin/confd
    chmod +x /usr/bin/confd
fi

if [ ! -x /usr/bin/ansible ]; then
    rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
    yum install -y ansible
fi

if [ ! -x /usr/local/go/bin/go ]; then
     yum install -y git-core mercurial
     cd /tmp
     curl -s -L -O https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz
     tar -C /usr/local -zxf go1.4.linux-amd64.tar.gz
fi

cat <<EOS > /etc/profile.d/go.sh
GOPATH=\\$HOME/go
export GOPATH
PATH=\\$GOPATH/bin:\\$PATH:/usr/local/go/bin
export PATH
EOS


SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/centos-7.0"
  config.ssh.forward_agent = true
  config.vm.provision "shell", inline: $script
end
