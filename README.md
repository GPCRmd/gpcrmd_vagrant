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

    1. Download from Dropbox/dbdesign/DESIGN/dumps/ 'prepare.sql' and 'protwis5.backup'.
    1. Copy files in a new folder: 'shared/db/'.

##### Download example files

    1. Download from Dropbox/dbdesign/data the folder 'files'.
    1. Copy 'files' in 'shared/'.
    

##### Log into the vagrant VM

    vagrant ssh


#### Run scripts and restore database
    Run following commands (type password 'protwis' when asked):

    cd /protwis/db/
    psql -U protwis -h localhost protwis < prepare.sql
    pg_restore --verbose --clean -h localhost -U protwis -d protwis protwis5.backup

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

    cd ~/gpcrmd_vagrant
    git clone https://github.com/your-username/gpcrdb.git shared\sites\protwis

Or with writting permissions

    cd ~/gpcrmd_vagrant
    git clone https://github.com/GPCRmd/gpcrdb.git shared\sites\protwis

##### Start the vagrant box

This may take a few minutes

    vagrant up

##### Download scripts and latest dump

    1. Download from Dropbox/dbdesign/DESIGN/dumps/ 'prepare.sql' and 'protwis5.backup'.
    1. Copy files in a new folder: 'shared/db/'.

##### Download example files

    1. Download from Dropbox/dbdesign/data the folder 'files'.
    1. Copy 'files' in 'shared/'.

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
    pg_restore --verbose --clean -h localhost -U protwis -d protwis protwis5.backup

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
