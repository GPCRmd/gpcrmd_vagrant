Development environment for [Protwis/GPCRmd](https://github.com/gpcrmd) using Vagrant and Puppet.

### Instructions

This guide describes how to set up a ready-to-go virtual machine with Virtualbox and Vagrant.

Works on Linux, Mac, and Windows.

#### Prerequisites

* [Vagrant][vagrant]
* [Virtualbox][virtualbox]
* [Git][git]
* [GitHub][github] account

[vagrant]: http://www.vagrantup.com
[virtualbox]: https://www.virtualbox.org
[git]: http://git-scm.com
[github]: http://www.bitbucket.org

Install Vagrant, VirtualBox, and Git, and create a GitHub account (if you don't already have one) and ask for writing permissions to administrator (ismaelresp).

Make sure you have the latest version of all three. On Ubuntu (and this may also apply to other Linux distros), the
package manager installs an old version of Vagrant, so you will have to download and install the latest version from
the Vagrant website.

#### Linux and Mac

##### Clone the gpcrmd_vagrant repository from GitHub

Open up a terminal and type

```bash
git clone --recursive git@github.com:GPCRmd/gpcrmd_vagrant.git ~/gpcrmd_vagrant
cd ~/gpcrmd_vagrant
```
or

```bash
git clone --recursive https://github.com/GPCRmd/gpcrmd_vagrant.git ~/gpcrmd_vagrant
cd ~/gpcrmd_vagrant
```
    
##### Fork the gpcrdb repository (only for external collaborators with read-only permissions)

Go to https://github.com/GPCRmd/gpcrdb and click "Fork" in the top right corner

##### Clone the forked or the original repository (writing permission required)

Clone into the "shared" directory (replace your-username with your read-only GitHub username)
    
```bash
cd ~/gpcrmd_vagrant
git clone https://github.com/your-username/gpcrdb.git shared/sites/protwis
```

Or with writting permissions

```bash
cd ~/gpcrmd_vagrant
git clone https://github.com/GPCRmd/gpcrdb.git shared/sites/protwis
```

##### Start the vagrant box

This may take a few minutes

```bash
vagrant up
```
    
##### Download scripts and latest dump

1.  Download from https://github.com/GPCRmd/gpcrmd_data/releases 'prepare.sql' and the last dumpddmmyyyy.backup .
2.  Copy files into next folder: '~/gpcrmd_vagrant/shared/db/'.
3.  In terminal run:

```bash
ln -s [dumpddmmyyyy].backup ~/gpcrmd_vagrant/shared/db/dump.backup
```

##### Download example files

1.  Download from https://github.com/GPCRmd/gpcrmd_data/releases 'files.tar.gz'.
2.  Extract 'files.tar.gz' into '~/gpcrmd_vagrant/shared/sites/'.

```bash
tar -xvzf your/download/folder/files.tar.gz -C ~/gpcrmd_vagrant/shared/sites/
```

    

##### Log into the vagrant VM

```bash
vagrant ssh
```


##### Install RDKit and OpenBabel in the VM
######  1. Increase VM memory temporary:
####### a. Stop vagrant VM:

From a new terminal:

```bash
cd ~/gpcrmd_vagrant
vagrant halt
```

####### b. Edit Vagrantfile:

Open Vagrant file '~/gpcrmd_vagrant/Vagrantfile' and replace the memory setting to 2560 MB at least:

```diff
# Allocate resources
config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
-   vb.customize ["modifyvm", :id, "--memory", "2048"]
+   vb.customize ["modifyvm", :id, "--memory", "2560"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
end
```

Otherwise compilation of RDKit could fail. This requirement is only needed for compilation, not for running the server.

####### c. Restart the VM and log into it:
    
```bash
vagrant up
vagrant ssh
```

######  2. Install dependences:
    
```bash
sudo apt-get install build-essential cmake sqlite3 libsqlite3-dev libffi6 libffi-dev
sudo apt-get install libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev 
sudo apt-get install liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev
sudo apt-get install python3.4 python3.4-dev python3-tk
sudo apt-get install libboost1.54-dev libboost-system1.54-dev libboost-thread1.54-dev
sudo apt-get install libboost-serialization1.54-dev libboost-python1.54-dev libboost-regex1.54-dev
```

######  3. Install OpenBabel:

```bash 
sudo apt-get install openbabel
```
    
######  4. Download and compile RDKit:

```bash
cd /home/vagrant
wget https://github.com/rdkit/rdkit/archive/Release_2016_03_1.tar.gz
tar -xvzf Release_2016_03_1.tar.gz
cd rdkit-Release_2016_03_1
export RDBASE=$(pwd)
export PYTHONPATH=$RDBASE:$PYTHONPATH
export LD_LIBRARY_PATH=$RDBASE/lib:$LD_LIBRARY_PATH
mkdir build
cd build
cmake -D RDK_BUILD_SWIG_WRAPPERS=OFF \
-D PYTHON_LIBRARY=/env/lib/python3.4/config-3.4m-x86_64-linux-gnu/libpython3.4m.so \
-D PYTHON_INCLUDE_DIR=/env/include/python3.4m/ \
-D PYTHON_EXECUTABLE=/env/bin/python3 \
-D RDK_BUILD_AVALON_SUPPORT=ON \
-D RDK_BUILD_INCHI_SUPPORT=ON \
-D RDK_BUILD_PYTHON_WRAPPERS=ON \
-D BOOST_ROOT=/usr/ \
-D PYTHON_INSTDIR=/env/lib/python3.4/site-packages/ \
-D RDK_INSTALL_INTREE=OFF ..
```
     
######  5. Install RDKit:

```bash
cd $RDBASE/build
sudo make -j2 install
sudo ldconfig
```
         
######  6. Log out from SSH session in order to clean LD_LIBRARY_PATH and PYTHONPATH:

```bash            
exit
```  
    
######  7. Restore VM memory configuration:
####### a. Stop vagrant VM:

```bash
vagrant halt
```

####### b. Edit Vagrantfile:

Open Vagrant file '~/gpcrmd_vagrant/Vagrantfile' and replace the memory setting to 2048 MB or 
the amount that you had previous to step 1:

```diff
# Allocate resources
config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
-   vb.customize ["modifyvm", :id, "--memory", "2560"]
+   vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
end
```

######  8. Restart the VM and log into it:

```bash
 vagrant up
 vagrant ssh
```
    
######  9. Optional. Test the installation:
     
####### a. Replace 'python' command by '/env/bin/python3':

```bash
mkdir /home/vagrant/bin
ln -s /env/bin/python3 /home/vagrant/bin/python
export PATH=/home/vagrant/bin:$PATH
```
             
####### b. Run test:

```bash
export RDBASE=/home/vagrant/rdkit-Release_2016_03_1
cd $RDBASE/build
ctest
```
    
####### c. Remove link:
    
```bash
rm /home/vagrant/bin/python
```
    
####### d. Log out from SSH session in order to clean PATH:
    
```bash
exit
```

####### e. Log into the vagrant VM:
    
```bash
vagrant ssh
```
    
##### Start the built in Django development webserver

```bash
cd /protwis/sites/protwis
/env/bin/python3 manage.py runserver 0.0.0.0:8000
```
    
You're all set up. The webserver will now be accessible from http://localhost:8000

#### Windows

##### Clone the gpcrmd_vagrant repository from GitHub

Open up a shell and type

```batch
git clone --recursive https://github.com/gpcrmd/gpcrmd_vagrant.git .\gpcrmd_vagrant
cd .\protwis_vagrant
```
    
##### Fork the protwis repository (only for external collaborators with read-only permissions)

Go to https://github.com/GPCRmd/gpcrdb and click "Fork" in the top right corner

##### Clone the forked or the original repository (writing permission required)

Clone into the "shared" directory (replace your-username with your read-only GitHub username)

```batch
cd %HOMEPATH%\gpcrmd_vagrant
git clone https://github.com/your-username/gpcrdb.git shared\sites\protwis
```
    
Or with writting permissions

```batch
cd %HOMEPATH%\gpcrmd_vagrant
git clone https://github.com/GPCRmd/gpcrdb.git shared\sites\protwis
```
    
##### Start the vagrant box

This may take a few minutes

```bash
vagrant up
```
    
##### Download scripts and latest dump

1.  Download from https://github.com/GPCRmd/gpcrmd_data/releases 'prepare.sql' and the last dumpddmmyyyy.backup .
2.  Copy files into next folder: '~/gpcrmd_vagrant/shared/db/'.
3.  Rename dumpddmmyyyy.backup to 'dump.backup'.

##### Download example files

1.  Download from https://github.com/GPCRmd/gpcrmd_data/releases 'files.tar.gz'.
2.  Extract files.tar.gz into '~/gpcrmd_vagrant/shared/sites/' with your favourite compression software.
    We recommend [7-zip](http://www.7-zip.org/).

##### Log into the vagrant VM

Use an SSH client, e.g. PuTTY, with the following settings

    host: 127.0.0.1
    port: 2226
    username: vagrant
    password: vagrant

    
##### Install RDKit and OpenBabel in the VM

######  1. Increase VM memory temporary:
####### a. Stop vagrant VM:

From a new cmd.exe:

```batch
cd %HOMEPATH%\gpcrmd_vagrant
vagrant halt
```

####### b. Edit Vagrantfile:

Open Vagrant file '%HOMEPATH%\gpcrmd_vagrant\gpcrmd_vagrant\Vagrantfile' and replace the memory setting to 2560 MB at least:

```diff
# Allocate resources
config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
-   vb.customize ["modifyvm", :id, "--memory", "2048"]
+   vb.customize ["modifyvm", :id, "--memory", "2560"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
end
```

Otherwise compilation of RDKit could fail. This requirement is only needed for compilation, not for running the server.

####### c. Restart the VM and log into it:

From a cmd.exe:

```batch
cd %HOMEPATH%\gpcrmd_vagrant
vagrant up
```
    
and open an SSH connection to Vagrant VM.


######  2. Install dependences:

```bash
sudo apt-get install build-essential cmake sqlite3 libsqlite3-dev libffi6 libffi-dev
sudo apt-get install libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev 
sudo apt-get install liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev
sudo apt-get install python3.4 python3.4-dev python3-tk
sudo apt-get install libboost1.54-dev libboost-system1.54-dev libboost-thread1.54-dev
sudo apt-get install libboost-serialization1.54-dev libboost-python1.54-dev libboost-regex1.54-dev
```
    
######  3. Install OpenBabel:
    
```bash
sudo apt-get install openbabel
```
    
######  4. Download and compile RDKit:

```bash
cd /home/vagrant
wget https://github.com/rdkit/rdkit/archive/Release_2016_03_1.tar.gz
tar -xvzf Release_2016_03_1.tar.gz
cd rdkit-Release_2016_03_1
export RDBASE=$(pwd)
export PYTHONPATH=$RDBASE:$PYTHONPATH
export LD_LIBRARY_PATH=$RDBASE/lib:$LD_LIBRARY_PATH
mkdir build
cd build
cmake -D RDK_BUILD_SWIG_WRAPPERS=OFF \
-D PYTHON_LIBRARY=/env/lib/python3.4/config-3.4m-x86_64-linux-gnu/libpython3.4m.so \
-D PYTHON_INCLUDE_DIR=/env/include/python3.4m/ \
-D PYTHON_EXECUTABLE=/env/bin/python3 \
-D RDK_BUILD_AVALON_SUPPORT=ON \
-D RDK_BUILD_INCHI_SUPPORT=ON \
-D RDK_BUILD_PYTHON_WRAPPERS=ON \
-D BOOST_ROOT=/usr/ \
-D PYTHON_INSTDIR=/env/lib/python3.4/site-packages/ \
-D RDK_INSTALL_INTREE=OFF ..
```
    
######  5. Install RDKit:

```bash     
cd $RDBASE/build
sudo make -j2 install
sudo ldconfig
```
    
######  6. Log out from SSH session in order to clean LD_LIBRARY_PATH and PYTHONPATH:

```bash            
exit
```
    
######  7. Restore VM memory configuration:
####### a. Stop vagrant VM:
From a cmd.exe:

```batch
cd %HOMEPATH%\gpcrmd_vagrant
vagrant halt
```

####### b. Edit Vagrantfile:

Open Vagrant file '%HOMEPATH%\gpcrmd_vagrant\Vagrantfile' and replace the memory setting to 2048 MB or 
the amount that you had previous to step 1:

```diff
# Allocate resources
config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
-   vb.customize ["modifyvm", :id, "--memory", "2560"]
+   vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
end
```

######  8. Restart the VM and log into it:
From a cmd.exe:

```batch
cd %HOMEPATH%\gpcrmd_vagrant
vagrant up
```

and open an SSH connection to Vagrant VM.

######  9. Optional. Test the installation:
     
####### a. Replace 'python' command by '/env/bin/python3':

```bash
mkdir /home/vagrant/bin
ln -s /env/bin/python3 /home/vagrant/bin/python
export PATH=/home/vagrant/bin:$PATH
cd $RDBASE/build
```
    
####### b. Run test:

```bash     
export RDBASE=/home/vagrant/rdkit-Release_2016_03_1
cd $RDBASE/build
ctest
```
    
####### c. Remove link:

```bash         
rm /home/vagrant/bin/python
```
    
####### d. Log out from SSH session in order to clean PATH:

```bash         
exit
```
    
####### e. Log into the vagrant VM:

```bash         
vagrant ssh
```
    
##### Start the Django development webserver

```bash
cd /protwis/sites/protwis
/env/bin/python3 manage.py runserver 0.0.0.0:8000
```
    
You're all set up. The webserver will now be accessible from http://localhost:8000

#### Other notes

The protwis directory is now shared between the host machine and the virtual machine, and any changes made on the host
machine will be instantly reflected on the server.

To run django commands from the protwis directory, ssh into the VM, and use the "/env/bin/python3" command e.g

```bash
cd ~/gpcrmd_vagrant/
vagrant ssh
cd /protwis/sites/protwis
/env/bin/python3 manage.py check protein
```
    
The database administration tool Adminer is installed and accessible at http://localhost:8082/adminer. Use the
following settings

    System: PostgreSQL
    Server: localhost
    Username: protwis
    Password: protwis

##### Installing haystack
Haystack provides modular search for Django. It features a unified, familiar API that allows you to plug in different search backends (such as Solr, Elasticsearch, Whoosh, Xapian, etc.).

It is required for our query search engine. Run the following steps in a VM terminal (e.g. vagrant ssh) in order to setup Haystack:

1. Install Solr (search and indexing server) with Jetty (apache2 manager):

    ```bash
    sudo apt-get install solr-jetty
    ```

2. Install Solr python wrapper (PySolr) and Haystack for django:

    ```bash
    sudo /env/bin/pip3 install pysolr==3.6 django-haystack==2.5
    ```

3. Edit the startup configuration file of Jetty: 

    ```bash
    sudo vim /etc/default/jetty
    ```

   and set the following parameters 'NO_START=0'and JETTY_PORT=8983' for enabling running as a service and setting the listening port with the one that matches with Django.settings.
   
4. Jetty is configured for running on startup, but configuration files are in a shared folder that sets up after Jetty startup. So, we have to disable jetty auto start up with the folowing command:

    ```bash
    sudo update-rc.d jetty disable
    ```
   
5. Bugfix for Ubuntu's logging bug (wrong location for the executable 'rotatelogs'):

    ```bash
    sudo sed -i 's/^ROTATELOGS=.*$/ROTATELOGS=\/usr\/bin\/rotatelogs/' /etc/init.d/jetty
    ```

6. Replace '/etc/solr/solr.xml' by 'solr.xml' from vagrant_gpcrmd.

7. Setup directories for gpcrmd configuration files and the generated indexes. 1.

    ```bash
    sudo mkdir /var/lib/solr/collection_gpcrmd
    sudo chmod 750 /var/lib/solr/collection_gpcrmd
    sudo chown jetty /var/lib/solr/collection_gpcrmd
    sudo mkdir /var/lib/solr/collection_gpcrmd/data
    sudo chmod 750 /var/lib/solr/collection_gpcrmd/data
    sudo chown jetty /var/lib/solr/collection_gpcrmd/data
    sudo ln -s /protwis/sites/protwis/solr/collection_gpcrmd/conf /var/lib/solr/collection_gpcrmd/conf
    ```

8. Restart Jetty:

    ```bash
    sudo /etc/init.d/jetty restart
    ```

9. Build the Solr indexes from our models and database:

    ```bash
    cd /protwis/sites/protwis
    /env/bin/python3 manage.py rebuild_index
    ```

##### Installing mdsrv and preparing apache WSGI for production

0. Get the last version of the Vagrantfile. Run in your computer terminal:
    
    Linux:
    
    ```bash
    cd ~/gpcrmd_vagrant/
    git pull origin master
    ```
    Windows:
    
    ```batch
    cd %HOMEPATH%\gpcrmd_vagrant
    git pull origin master
    ```
    
    If changes have being made into Vagrantfile, restart your vagrant VM:
    
    ```
    vagrant halt
    vagrant up
    ```
    
    
1. Download last version of mdsrv and save it into "~/gpcrmd_vagrant/shared" from https://github.com/arose/mdsrv/releases. Then, run in vagrant VM terminal:

    ```bash
    tar -xvzf mdsrv.tar.gz -C /var/www/
    mv /var/www/mdsrv* /var/www/mdsrv
    chmod -R og+rX /var/www/mdsrv
    cd /var/www/mdsrv
    /env/bin/python setup.py install
    ```
2. Download https://github.com/GPCRmd/gpcrmd_puppet_modules/blob/dev/mdsrv/config/app.cfg (click on "raw" button) and saved it into "/protwis".

3. Download https://github.com/GPCRmd/gpcrmd_puppet_modules/blob/dev/mdsrv/config/mdsrv.wsgi (click on "raw" button) and saved it into "/protwis".

4. Move the files downloaded in the previous two steps by running in vagrant VM terminal:

    ```bash
    sudo mv /protwis/app.cfg /var/www/mdsrv/
    sudo mv /protwis/mdsrv.wsgi /var/www/mdsrv/
    ```


3. Change permisions for "/var/www". Replace "www-data" (Debian) by your apache2 user (e.g "apache" for RedHat and CentOS). :
    
    ```bash
    chgrp -R www-data /var/www/
    chown -R g+rX /var/www/
    chown -R g-w /var/www/
    chown -R o-rwx /var/www/
    ```
    
4. Create a simlink to mdsrv_static:

    ```bash
    sudo mv /var/www/html /var/www/html2 
    # An existent "/var/www/html" or "/var/www/html" is not necessary.
    sudo ln -s /protwis/sites/protwis/mdsrv_static  /var/www/html
    ```
    
5. Go to https://github.com/GPCRmd/gpcrmd_puppet_modules/raw/master/apache/config/virtualhost and save the plain text web page into "~/gpcrmd_vagrant/shared". Then, run in vagrant VM terminal:

   ```bash
   cd /protwis
   sudo mv virtualhost /etc/apache2/sites-available/000-default.conf 
   # "virtualhost" is the name of the downloaded file 
   ```
   
6. Configure apache2 to listen to ports 80 and 8081. Edit the file "/etc/apache2/ports.conf":

   ```bash
   sudo vi /etc/apache2/ports.conf
   ```
   
   Write the following two lines if they are missing and save the file:
   
   ```apache
   Listen 80
   Listen 8081
   ```
   
7. Restart apache2:

   Debian:
   
   ```bash
   sudo service apache2 restart
   ```
   
   RedHat/CentOS:
   
   ```bash
   /etc/init.d/httpd restart
   ```
   
##### Setting up Django for production

1. Replace the following line in protwis/settings.py:
   
    ```diff
       try:
           from protwis.settings_local import *
       except ImportError:
    -      from protwis.settings_local_development import *
    +      from protwis.settings_local_production import *  

    ```
   
2. Collect static files running the following commands in a in vagrant VM terminal:

    ```bash
    cd /protwis/sites/protwis/
    /env/bin/python3 manage.py collectstatic --no-input
    ```
3. Restart apache2:

   Debian:
   
   ```bash
   sudo service apache2 restart
   ```
   
   RedHat/CentOS:
   
   ```bash
   /etc/init.d/httpd restart
   ```
