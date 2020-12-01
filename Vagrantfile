Vagrant.configure("2") do |config|

  config.vm.box = "centos-7.8.2003"
  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 2048
  end
	  
  config.vm.synced_folder '.', '/vagrant', disabled: true
    
  config.vm.define "master" do |master|
    master.vm.network "private_network", ip: "192.168.101.10"
    
    master.vm.synced_folder '.', '/vagrant', type: "smb", mount_options:["nobrl"], create: true
    master.vm.provision "shell", inline:"echo 11111", binary:true
  end

  nodeSize=2
  (1..nodeSize).each do |n|
    config.vm.define "node-#{n}" do |node|
      node.vm.provider "virtualbox" do |v|
        v.memory = 4096
      end    
      node.vm.network "private_network", ip: "192.168.101.#{10+n}"
       
      node.vm.synced_folder 'resources', '/vagrant/resources', type: "rsync"
      node.vm.provision "shell", inline:"echo 111111-#{101+n}", binary:true
    end
  end 

end
