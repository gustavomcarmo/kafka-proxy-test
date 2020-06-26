# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.2.0"

Vagrant.configure("2") do |config|
  config.vagrant.plugins = "vagrant-hostsupdater"

  config.vm.box = "codeyourinfra/docker"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.hostname = "kafka.example.org"

  config.vm.provider "virtualbox" do |v|
    v.memory = "8192"
    v.linked_clone = true
  end

  config.vm.provision "ansible" do |ansible|
    ansible.inventory_path = "inventory.yml"
    ansible.playbook = "playbook.yml"
    ansible.limit = "all"
  end
end