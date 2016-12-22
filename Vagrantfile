#    Copyright [2016] [Ismael Rodriguez Espigares and Alejandro Varela Rial]
#    Derived work from Protwis project Development environment (https://github.com/protwis/protwis_vagrant) by Vignir Isberg.
# 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

Vagrant.configure("2") do |config|

    # Vagrant box to build off of.
    config.vm.box = "ubuntu/trusty64"

    # Forward ports
    config.vm.network :forwarded_port, guest: 22, host: 2226, id: "ssh"
    config.vm.network :forwarded_port, guest: 5432, host: 5432, id: "postgresql"
    config.vm.network :forwarded_port, guest: 8000, host: 8000
    config.vm.network :forwarded_port, guest: 80, host: 8001
    config.vm.network :forwarded_port, guest: 8081, host: 8081

    # Allocate resources
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--memory", "2560"]
        vb.customize ["modifyvm", :id, "--cpus", "2"]
    end

    # Set up a shared directory
    config.vm.synced_folder "shared", "/protwis/", :owner => "vagrant"

    # copy puppet scripts to VM
    config.vm.provision "file", source: "gpcrmd_puppet_modules", destination: "/protwis/conf/protwis_puppet_modules"

    # Enable the Puppet provisioner
    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file = "default.pp"
        puppet.module_path = "gpcrmd_puppet_modules"
    end
    
    # Start jetty
    config.vm.provision "shell", run: "always" do |s|
        s.inline = "/etc/init.d/jetty start"
        s.privileged   = true
    end

end
