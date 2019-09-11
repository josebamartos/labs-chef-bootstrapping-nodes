# Install required Vagrant plugins
missing_plugins_installed = false
required_plugins = %w(vagrant-cachier vagrant-hostsupdater)

required_plugins.each do |plugin|
  if !Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    missing_plugins_installed = true
  end
end

# If any plugins were missing and have been installed, re-run vagrant
if missing_plugins_installed
  exec "vagrant #{ARGV.join(" ")}"
end

Vagrant.configure(2) do |config|
  
  # Chef Infra Server
  config.vm.define :chef_server do |chef_server_config|
    chef_server_config.vm.box = "centos/7"
    chef_server_config.vm.hostname = "chef-server"
    chef_server_config.vm.network :private_network, ip: "10.10.10.10"
    chef_server_config.vm.network "forwarded_port", guest: 80, host: 8080
    chef_server_config.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end
    chef_server_config.vm.provision :shell, path: "provision/chef_server.sh"
  end

  # Chef Node with no Chef Infra Client installed
  (1..2).each do |i|
    config.vm.define "chef_node_0#{i}" do |chef_node|
      chef_node.vm.box = "centos/7"
      chef_node.vm.hostname = "chef-node-0#{i}"
      chef_node.vm.network :private_network, ip: "10.10.10.1#{i}"
      chef_node.vm.network "forwarded_port", guest: 80, host: "808#{i}"
      chef_node.vm.provider "virtualbox" do |vb|
        vb.memory = "256"
      end
      chef_node.vm.provision :shell, path: "provision/chef_node.sh"
    end
  end
end
