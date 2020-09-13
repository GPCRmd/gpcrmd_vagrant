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

    config.vagrant.plugins = ["vagrant-vbguest"]
    # Vagrant box to build off of.
    # config.vm.box = "ubuntu/trusty64"
    config.vm.box = "centos/7"

    #config.vm.box_version = "20160201.0.2"  # ubuntu known version to work
    


    # Forward ports
    config.vm.network :forwarded_port, guest: 22, host: 2226, id: "ssh", host_ip: "127.0.0.1"
    config.vm.network :forwarded_port, guest: 5432, host: 5432, id: "postgresql", host_ip: "127.0.0.1"
    config.vm.network :forwarded_port, guest: 8000, host: 8000, id: "django_webserver", host_ip: "127.0.0.1"
    config.vm.network :forwarded_port, guest: 80, host: 8001, id: "apache", host_ip: "127.0.0.1"
    config.vm.network :forwarded_port, guest: 8081, host: 8081, id: "apache_mdsrv", host_ip: "127.0.0.1"
    config.vm.network :forwarded_port, guest: 8082, host: 8082, id: "apache_no_virtualhost",host_ip: "127.0.0.1"

    # Allocate resources
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--memory", "2560"]
        vb.customize ["modifyvm", :id, "--cpus", "2"]
    end

    if config.vm.box == "ubuntu/trusty64"
        $apache_group = "www-data"
        $jetty_solr = true
    elsif config.vm.box == "centos/7"
        $apache_group = "apache"
        $jetty_solr = false
        $script = <<-SCRIPT
        yum list installed puppetlabs-release || rpm -ivh https://yum.puppetlabs.com/el/7/products/x86_64/puppetlabs-release-7-12.noarch.rpm;
        yum list installed puppet-server || yum install -y puppet-server
        SCRIPT

        $script2 = <<-SCRIPT
        GROUP=#{$apache_group}; getent group $GROUP || groupadd $GROUP;
        GROUP_ID=$(getent group $GROUP | cut -d: -f3);
        umount /protwis;
        mount -t vboxsf --options rw,nodev,relatime,iocharset=utf8,uid=1000,gid=${GROUP_ID},dmode=0775,fmode=0664 protwis_ /protwis;
        SCRIPT

        config.vm.provision "prepare-box", type: "shell", privileged: true, before: :all,
            inline: $script
        config.vm.provision "mount-protwis", type: "shell", privileged: true, before: :all,
        run: "always", inline: $script2

    end



    # Set up a shared directory
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.synced_folder "shared", "/protwis/", owner: "vagrant",
    mount_options: ["dmode=775,fmode=664"], automount: true
    # copy puppet scripts to VM
    config.vm.provision "file", type:"file", source: "gpcrmd_puppet_modules",
        destination: "/protwis/conf/protwis_puppet_modules"

    # Enable the Puppet provisioner
    config.vm.provision "puppet", type:"puppet", after: "file" do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file = "default.pp"
        puppet.module_path = "gpcrmd_puppet_modules"
    end



    if $jetty_solr
        # Start jetty
        config.vm.provision "jetty", type: "shell", after: :all, run: "always" do |s|
            s.inline = "/etc/init.d/jetty start"
            s.privileged   = true
        end
    end

end
