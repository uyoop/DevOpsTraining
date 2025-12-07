
Vagrant.configure("2") do |config|
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.ssh.insert_key = false # to use the global unsecure key instead of one insecure key per VM
    config.vm.provider :virtualbox do |v|
      v.memory = 512
      v.cpus = 1
    end

    config.vm.define :VMserveur do |VMserveur|
      # Vagrant va récupérer une machine de base ubuntu 24.04 depuis cette plateforme https://app.vagrantup.com/boxes/search
      VMserveur.vm.box = "bento/ubuntu-24.04"
      VMserveur.vm.hostname = "VMserveur"
      VMserveur.vm.network :private_network, ip: "192.168.56.111"
    end

    config.vm.define :VMdatabase do |VMdatabase|
      # Vagrant va récupérer une machine de base ubuntu 24.04 depuis cette plateforme https://app.vagrantup.com/boxes/search
      VMdatabase.vm.box = "bento/ubuntu-24.04"
      VMdatabase.vm.hostname = "VMdatabase"
      VMdatabase.vm.network :private_network, ip: "192.168.56.112"
    end
  end