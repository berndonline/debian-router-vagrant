# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |domain|
    domain.management_network_address = "10.255.1.0/24"
    domain.management_network_name = "wbr1"
    domain.nic_adapter_count = 130
  end
  #Generating Ansible Host File at following location:
  #    ./.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "./helper_scripts/playbook.yml"
  end

  ##### DEFINE VM for rtr-1 #####

  config.vm.define "debian-router" do |device|
    device.vm.box = "debian/stretch64"

    device.vm.provider :libvirt do |v|
      v.memory = 2048
    end

    device.vm.guest = :debian

  config.vm.synced_folder '.', '/vagrant', disabled: true

    # NETWORK INTERFACES
      # link for Gig01 --> rtr-1:Gig1
      device.vm.network "private_network",
            :mac => "a0:00:00:00:00:01",
            :libvirt__tunnel_type => 'udp',
            :libvirt__tunnel_local_ip => '127.0.0.1',
            :libvirt__tunnel_local_port => '8001',
            :libvirt__tunnel_ip => '127.0.0.1',
            :libvirt__tunnel_port => '9001',
            :libvirt__iface_name => 'ens6',
            auto_config: false

  config.vm.boot_timeout = 400

  config.ssh.forward_agent = true
  config.ssh.guest_port = 22
  config.ssh.insert_key = false

end

  ##### DEFINE VM for rtr-2 #####
  
  config.vm.define "cisco-iosxe" do |device|
    device.vm.box = "iosxe"

    device.vm.provider :libvirt do |v|
      v.memory = 2048
    end

    device.vm.guest = :freebsd

  config.vm.synced_folder '.', '/vagrant', disabled: true

    # NETWORK INTERFACES
      # link for Gig3 --> rtr-1:Gig01
      device.vm.network "private_network",
            :mac => "a0:00:00:00:00:04",
            :libvirt__tunnel_type => 'udp',
            :libvirt__tunnel_local_ip => '127.0.0.1',
            :libvirt__tunnel_local_port => '9001',
            :libvirt__tunnel_ip => '127.0.0.1',
            :libvirt__tunnel_port => '8001',
            :libvirt__iface_name => 'Gig2',
            auto_config: false

  config.vm.boot_timeout = 400

  config.ssh.forward_agent = true
  config.ssh.guest_port = 22
  config.ssh.insert_key = false
end

end

