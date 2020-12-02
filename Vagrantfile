Vagrant.configure("2") do |config|

  config.vm.box = "centos-7.8.2003"
  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 2048
  end
      
  config.vm.synced_folder '.', '/vagrant', disabled: true
  masterIP="192.168.101.10"
  podCidr="172.16.0.0/16"
    
  config.vm.define "master" do |master|
    master.vm.network "private_network", ip: "#{masterIP}"
    
    master.vm.synced_folder '.', '/vagrant', type: "smb", mount_options:["nobrl"], create: true
    master.vm.provision "shell", inline:"export IP=#{masterIP}; export MASTER_IP=#{masterIP}; export POD_CIDR=#{podCidr}; cd /vagrant/resources/shell; bash master.sh", binary:true
  end

  nodeSize=2
  (1..nodeSize).each do |n|
    config.vm.define "node-#{n}" do |node|
      node.vm.provider "virtualbox" do |v|
        v.memory = 4096
      end
      
      nodeIP="192.168.101.#{10+n}"
      node.vm.network "private_network", ip: "#{nodeIP}"
       
      node.vm.synced_folder 'resources', '/vagrant/resources', type: "rsync"
      node.vm.provision "shell", inline:"export IP=#{nodeIP}; export MASTER_IP=#{masterIP}; cd /vagrant/resources/shell; bash node.sh", binary:true
    end
  end 
end
