
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "chef/ubuntu-14.04"
	config.ssh.forward_agent = true

	config.vm.provider "vmware_fusion" do |v|
		v.vmx["memsize"] = "2048"
		v.vmx["numvcpus"] = "2"
	end


    config.vm.provision "shell", privileged: true, inline: <<EOS
apt-get update
apt-get install -y build-essential git mercurial unzip bc libncurses5-dev

mkdir -p /home/vagrant/.ssh
cat << END  > /home/vagrant/.ssh/config
Host github.com
    StrictHostKeyChecking no
END

chown -R vagrant /home/vagrant/.ssh

EOS
end
