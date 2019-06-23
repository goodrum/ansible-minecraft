# Defines our Vagrant environment
#
# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest: 25565, host: 25565
  config.vm.define "server" do |host|
    host.vm.hostname = "server"
    host.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "1"
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    end
    # host.vm.provision :shell, :inline => $setupScript
    host.vm.provision "shell", inline: <<-SHELL
      echo "Perform a cache update"
      sudo apt-get update
      echo "Configure Ansible"
      sudo apt-get install -y software-properties-common
      sudo apt-add-repository ppa:ansible/ansible -y
      sudo apt-get update
      sudo apt-get install ansible -y
      ansible --version
      ansible-playbook --version
      ansible-galaxy --version
      echo "Fix permissions on home directory"
      sudo chown -R vagrant /home/vagrant
      sudo chmod -R 0700 /home/vagrant
    SHELL

    # => Execute the Vagrant Provisioner for Ansible every time we perform a `vagrant up` and then
    # => apply the default playbook build
    # =>
    # => We are using Ansible to load the requirements which should contain the galaxy docker role
    # => to streamline the installation of docker.
    host.vm.provision "ansible_local", :run => 'always' do |ansible|
      ansible.install = true
      ansible.provisioning_path = "/vagrant/"
      ansible.tmp_path = "/vagrant/tmp/"
      ansible.become = true
      ansible.playbook = "/vagrant/tests/vagrant_playbook.yml"
      ansible.galaxy_role_file = "/vagrant/tests/requirements.yml"
      ansible.galaxy_roles_path = "/tmp/roles/"
    end
  end
end
