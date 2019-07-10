# Defines our Vagrant environment
#
# -*- mode: ruby -*-
# vi: set ft=ruby :
  VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.network "forwarded_port", guest: 25565, host: 25565
    config.vm.define "server" do |host|
        host.vm.synced_folder ".", "/vagrant/devops-coop.minecraft"
        host.vm.hostname = "server"
        host.vm.provider "virtualbox" do |vb|
            # => 2019-06-29
            # => Due to some issues with tasks failing due to low memory options,
            # => We have increased the required memory from 1024 to 2048
            vb.memory = "2048"
            vb.cpus = "1"
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        end
        # => 2019-06-29
        # => Modified the process to perform the installation of Ansible and
        # => ultimately rely on this process to perform the required feature
        # => installation and configuration
        # =>
        # => 2019-07-07
        # => TODO: Remove Ansible version restriction
        # => https://github.com/ansible/molecule/issues/1727
        host.vm.provision "shell", inline: <<-SHELL
            echo ""
            echo "Perform a cache update"
            echo "########################"
            sudo apt-get update
            echo ""
            echo "Install Python and Pip"
            echo "########################"
            sudo apt-get install -y python python-pip
            echo ""
            echo "########################"
            echo "Upgrade Pip to recent and install Ansible"
            sudo pip install --upgrade pip
            sudo pip install "ansible==2.7.12"
            echo ""
            echo "Verify Ansible Versions"
            echo "########################"
            ansible --version
            ansible-playbook --version
            ansible-galaxy --version
            echo ""
            echo "Fix permissions on home directory"
            echo "########################"
            sudo chown -R vagrant /home/vagrant
            sudo chmod -R 0700 /home/vagrant
            echo ""
        SHELL

        # => 2019-06-29
        # => Execute the Vagrant Provisioner for Ansible every time we perform a `vagrant up` and then
        # => apply the default playbook build
        # =>
        # => We are using Ansible to load the requirements which should contain the galaxy docker role
        # => to streamline the installation of docker.
        host.vm.provision "ansible_local", :run => 'always' do |ansible|
            ansible.install = true
            ansible.provisioning_path = "/vagrant/devops-coop.minecraft/"
            ansible.tmp_path = "/tmp/"
            ansible.become = true
            ansible.playbook = "/vagrant/devops-coop.minecraft/tests/vagrant_playbook.yml"
            ansible.galaxy_role_file = "/vagrant/devops-coop.minecraft/tests/requirements.yml"
            ansible.galaxy_roles_path = "/tmp/roles/"
        end
    end
end
