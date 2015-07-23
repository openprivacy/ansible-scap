# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant configuration for testing of system hardening.
# "dashboard" haa OpenSCAP, SCAP content (the SSG) and GovReady installed.
# "server" has only OpenSCAP installed; this is the server to be hardened.
Vagrant.configure(2) do |config|

  # Configure CentOS 7 for Testing "dashboard"
  config.vm.define "dashboard" do |dashboard|
    dashboard.vm.box = "geerlingguy/centos7"
    
    # network config
    dashboard.vm.network :private_network, ip: "192.168.56.101" # , auto_config: false
    dashboard.vm.network :forwarded_port, guest: 80, host: 8081
    # the following line doesn't "stick" - vagrant sets the port by default to 2222
    # dashboard.vm.network :forwarded_port, guest: 22, host: 2201, auto_correct: false

    # Sync overall cloudstart directory on host machine with "/vagrant" directory on guest machine
    dashboard.vm.synced_folder ".", "/vagrant", group: "vagrant", owner: "vagrant", create: true

    # Launch virtualbox GUI window and increase memory
    dashboard.vm.provider "virtualbox" do |d|
      # d.gui = true
      d.memory = "1024"
    end
    
    # Provision this machine as the dashboard control center running scans
    dashboard.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision.yml"
    end
  end

  # Configure CentOS 7 "server" (to be hardened)
  config.vm.define "server" do |server|
    server.vm.box = "geerlingguy/centos7"
    
    # network config # 2200
    server.vm.network :private_network, ip: "192.168.56.102" # , auto_config: false
    server.vm.network :forwarded_port, guest: 80, host: 8082
    # the following line doesn't "stick" - vagrant sets the port by default to 2200
    server.vm.network :forwarded_port, guest: 22, host: 2202, auto_correct: false

    # Sync overall cloudstart directory on host machine with "/vagrant" directory on guest machine
    server.vm.synced_folder ".", "/vagrant", group: "vagrant", owner: "vagrant", create: true

    # Launch virtualbox GUI window and increase memory
    server.vm.provider "virtualbox" do |c|
      # c.gui = true
      c.memory = "768"
    end

    # Provision this machine as a standard hardened server
    server.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision.yml"
    end
  end
end
