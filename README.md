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

    git clone --recursive https://github.com/GPCRmd/gpcrmd_vagrant.git ~/gpcrmd_vagrant
    cd ~/gpcrmd_vagrant

##### Fork the gpcrdb repository (only for external collaborators with read-only permissions)

Go to https://github.com/GPCRmd/gpcrdb and click "Fork" in the top right corner

##### Clone the forked or the original repository (writing permission required)

Clone into the "shared" directory (replace your-username with your read-only GitHub username)

    cd ~/gpcrmd_vagrant
    git clone https://github.com/your-username/gpcrdb.git shared/sites/protwis

Or with writting permissions

    cd ~/gpcrmd_vagrant
    git clone https://github.com/GPCRmd/gpcrdb.git shared/sites/protwis


##### Start the vagrant box

This may take a few minutes

    vagrant up

##### Download scripts and latest dump

    1. Download from Dropbox/dbdesign/DESIGN/dumps/ 'prepare.sql' and the last dumpddmmyyyy.backup .
    2. Copy files into next folder: '~/gpcrmd_vagrant/shared/db/'.

##### Download example files

    1. Download from Dropbox/dbdesign/data the folder 'files'.
    2. Copy 'files' into '~/gpcrmd_vagrant/shared/sites/'.
    

##### Log into the vagrant VM

    vagrant ssh


#### Run scripts and restore database
    Run following commands (type password 'protwis' when asked):

    cd /protwis/db/
    psql -U protwis -h localhost protwis < prepare.sql
    pg_restore --verbose -h localhost -U protwis -d protwis dumpddmmyyyy.backup

#### Install RDKit and OpenBabel in the VM
     1. Install dependences:
    
         sudo apt-get install build-essential cmake sqlite3 libsqlite3-dev libffi6 libffi-dev
         sudo apt-get install libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev 
         sudo apt-get install liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev
         sudo apt-get install python3.4 python3.4-dev python3-tk
         sudo apt-get install libboost1.54-dev libboost-system1.54-dev libboost-thread1.54-dev
         sudo apt-get install libboost-serialization1.54-dev libboost-python1.54-dev libboost-regex1.54-dev
         
     2. Install OpenBabel:
     
         sudo apt-get install openbabel
         
     3. Download and compile RDKit:
     
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
     
     4. Optional. Test the build:
     
         a. Replace 'python' command by '/env/bin/python':
         
             mkdir /home/vagrant/bin
             ln -s /env/bin/python /home/vagrant/bin/python
             export PATH=/home/vagrant/bin:$PATH
             cd $RDBASE/build
             
         b. Run test:
         
             ctest
             
         c. Remove link:
         
             rm /home/vagrant/bin/python
             
         d. Log out from SSH session in order to clean PATH:
         
            exit
            
         e. Log into the vagrant VM:
         
            vagrant ssh
     
     5. Install RDKit:
     
         cd $RDBASE/build
         sudo make -j2 install
         sudo ldconfig
         
     6. Log out from SSH session in order to clean LD_LIBRARY_PATH:
            
         exit
         
     7. Log into the vagrant VM:
     
         vagrant ssh                  

##### Start the built in Django development webserver

    cd /protwis/sites/protwis
    /env/bin/python3 manage.py runserver 0.0.0.0:8000

You're all set up. The webserver will now be accessible from http://localhost:8000

#### Windows

##### Clone the gpcrmd_vagrant repository from GitHub

Open up a shell and type

    git clone --recursive https://github.com/gpcrmd/gpcrmd_vagrant.git .\gpcrmd_vagrant
    cd .\protwis_vagrant

##### Fork the protwis repository (only for external collaborators with read-only permissions)

Go to https://github.com/GPCRmd/gpcrdb and click "Fork" in the top right corner

##### Clone the forked or the original repository (writing permission required)

Clone into the "shared" directory (replace your-username with your read-only GitHub username)

    cd %HOMEPATH%\gpcrmd_vagrant
    git clone https://github.com/your-username/gpcrdb.git shared\sites\protwis

Or with writting permissions

    cd %HOMEPATH%\gpcrmd_vagrant
    git clone https://github.com/GPCRmd/gpcrdb.git shared\sites\protwis

##### Start the vagrant box

This may take a few minutes

    vagrant up

##### Download scripts and latest dump

    1. Download from Dropbox\dbdesign\DESIGN\dumps\ 'prepare.sql' and the last dumpddmmyyyy.backup .
    2. Copy files into next folder: %HOMEPATH%\gpcrmd_vagrant\shared\db\ .

##### Download example files

    1. Download from Dropbox\dbdesign\data the folder 'files'.
    2. Copy 'files' into %HOMEPATH%\gpcrmd_vagrant\shared\sites\ .

##### Log into the vagrant VM

Use an SSH client, e.g. PuTTY, with the following settings

    host: 127.0.0.1
    port: 2226
    username: vagrant
    password: vagrant

#### Run scripts and restore database
    Run following commands (type password 'protwis' when asked):

    cd /protwis/db/
    psql -U protwis -h localhost protwis < prepare.sql
    pg_restore --verbose -h localhost -U protwis -d protwis dumpddmmyyyy.backup
    
#### Install RDKit and OpenBabel in the VM
     1. Install dependences:
    
         sudo apt-get install build-essential cmake sqlite3 libsqlite3-dev libffi6 libffi-dev
         sudo apt-get install libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev 
         sudo apt-get install liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev
         sudo apt-get install python3.4 python3.4-dev python3-tk
         sudo apt-get install libboost1.54-dev libboost-system1.54-dev libboost-thread1.54-dev
         sudo apt-get install libboost-serialization1.54-dev libboost-python1.54-dev libboost-regex1.54-dev
         
     2. Install OpenBabel:
     
         sudo apt-get install openbabel
         
     3. Download and compile RDKit:
     
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
     
     4. Optional. Test the build:
     
         a. Replace 'python' command by '/env/bin/python':
         
             mkdir /home/vagrant/bin
             ln -s /env/bin/python /home/vagrant/bin/python
             export PATH=/home/vagrant/bin:$PATH
             cd $RDBASE/build
             
         b. Run test:
         
             ctest
             
         c. Remove link:
         
             rm /home/vagrant/bin/python
             
         d. Log out from SSH session in order to clean PATH:
         
            exit
            
         e. Log into the vagrant VM:
         
            vagrant ssh
     
     5. Install RDKit:
     
         cd $RDBASE/build
         sudo make -j2 install
         sudo ldconfig
         
     6. Log out from SSH session in order to clean LD_LIBRARY_PATH:
            
         exit
         
     7. Log into the vagrant VM:
     
         vagrant ssh
         

##### Start the Django development webserver

    cd /protwis/sites/protwis
    /env/bin/python3 manage.py runserver 0.0.0.0:8000

You're all set up. The webserver will now be accessible from http://localhost:8000

#### Other notes

The protwis directory is now shared between the host machine and the virtual machine, and any changes made on the host
machine will be instantly reflected on the server.

To run django commands from the protwis directory, ssh into the VM, and use the "/env/bin/python3" command e.g

    cd ~/gpcrmd_vagrant/
    vagrant ssh
    cd /protwis/sites/protwis
    /env/bin/python3 manage.py check protein

The database administration tool Adminer is installed and accessible at http://localhost:8001/adminer. Use the
following settings

    System: PostgreSQL
    Server: localhost
    Username: protwis
    Password: protwis
