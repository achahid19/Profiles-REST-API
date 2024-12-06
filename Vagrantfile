# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Specify the box. For M1/M2 Mac, use an ARM64-compatible box.
  config.vm.box = "bento/ubuntu-20.04" # Updated to a more recent version.
  config.vm.box_version = ">= 202105.25.0" # Update the version based on available ones.
  
  # Specify the VMware provider explicitly.
  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "2048" # Set memory to 2 GB
    v.vmx["numvcpus"] = "2"   # Allocate 2 CPUs
  end

  # Forward port 8000 from guest to host.
  config.vm.network "forwarded_port", guest: 8000, host: 4242

  # Provisioning: Configure the VM after it's launched.
  config.vm.provision "shell", inline: <<-SHELL
    # Disable auto updates for apt
    sudo systemctl disable apt-daily.service
    sudo systemctl disable apt-daily.timer

    # Update and install dependencies
    sudo apt-get update
    sudo apt-get install -y python3-venv zip

    # Add a Python alias in the .bash_aliases file
    if ! grep -q PYTHON_ALIAS_ADDED /home/vagrant/.bash_aliases; then
      echo "# PYTHON_ALIAS_ADDED" >> /home/vagrant/.bash_aliases
      echo "alias python='python3'" >> /home/vagrant/.bash_aliases
    fi
  SHELL
end
