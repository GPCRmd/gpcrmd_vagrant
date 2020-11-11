#! /bin/bash

# THINGS missing in the script and must be done:
# - Upgrading DB postgresql data from version 9.3 to 9.5: https://www.postgresql.org/docs/9.5/upgrading.html
# - Installing and configuring Certibot: https://certbot.eff.org/lets-encrypt/centosrhel7-apache
# - Update config files from apache 2.2 to 2.4 format.
# - Enable ports 80 and 443 in the firewall

# enable alternative repos
yum -y install epel-release centos-release-scl
# disable SELinux
setenforce 0; sed -ir 's/^\\(\s*SELINUX=\\)enforcing\\b/\\1disabled/' /etc/selinux/config
# set locale (if CentOS installed with US English)
sh -c "echo 'export LC_ALL=en_US.UTF-8' >> /etc/environment"
sh -c "echo 'export LANG=en_US.UTF-8' >> /etc/environment"

# install tools
yum -y install git openbabel expect htop wget clustal-omega perl-Archive-Tar perl-Digest-MD5 
yum -y install perl-List-MoreUtils argtable argtable-devel
rpm -i https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.11.0/ncbi-blast-2.11.0+-1.x86_64.rpm

# install postgresql
postgresql_version="9.5"
postgresql_version2="95"
postgresql_service_name="postgresql-${postgresql_version}"
yum -y install "https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm"
yum -y install postgresql${postgresql_version2} postgresql${postgresql_version2}-contrib
yum -y install postgresql${postgresql_version2}-server postgresql${postgresql_version2}-devel
/usr/pgsql-${postgresql_version}/bin/postgresql${postgresql_version2}-setup initdb

# add postgresql to path
PROFILED_FILE="/etc/profile.d/pgsql${postgresql_version2}.sh";
echo "export PATH=\$PATH:/usr/pgsql-${postgresql_version}/bin/" > "$PROFILED_FILE";
source "$PROFILED_FILE"

# allow postgres password auth
sed -i 's/ident/md5/g' /var/lib/pgsql/${postgresql_version}/data/pg_hba.conf

# OLD gandalf uses postgreSQL 9.3. Data requieres migracion: https://www.postgresql.org/docs/9.5/upgrading.html

#start postgres and setup postgres at start-up
systemctl start postgresql-${postgresql_version};systemctl enable postgresql-${postgresql_version}

# install solr
yum -y install java-1.8.0-openjdk
yum -y install lsof curl logrotate
curl -sLO https://archive.apache.org/dist/lucene/solr/6.4.2/solr-6.4.2.tgz
tar xzf solr*.tgz solr*/bin/install_solr_service.sh --strip-components=2
bash ./install_solr_service.sh solr*.tgz -f
mkdir -p /var/solr/data/collection_gpcrmd/
mkdir -p /var/solr/data/collection_gpcrmd/data
cp core.properties /var/solr/data/collection_gpcrmd/core.properties
ln -s /var/solr/data/collection_gpcrmd/conf /protwis/sites/protwis/solr/collection_gpcrmd/conf/
service solr restart


# install python
yum -y install python34 python34-devel PyYAML libyaml libyaml-devel libffi libffi-devel libjpeg-turbo-devel
yum -y install zlib zlib-devel gcc-c++
if [ -f /usr/local/bin/python3 ]; then
    ln -s /usr/bin/python3.4 /usr/local/bin/python3
fi

# install pip
curl -sL https://bootstrap.pypa.io/3.4/get-pip.py > get-pip.py;python3 get-pip.py
pip3 install pathlib2 virtualenv

# create virtual environment
virtualenv -p python3 /env

# install boost
yum -y install libicu libicu-devel perl
bash boost.sh
echo '/usr/local/lib' > '/etc/ld.so.conf.d/usr_local_lib.conf'; ldconfig

# install pip packages
source "/etc/profile.d/pgsql${postgresql_version2}.sh"
/env/bin/pip3 install psycopg2<2.7
/env/bin/pip3 install django<1.10 numpy scipy cython pysolr<3.7 flask Pillow PyYAML==3.12
/env/bin/pip3 install matplotlib<3.1 ipython certifi django-debug-toolbar<1.10 biopython<1.68 xlrd
/env/bin/pip3 install djangorestframework<3.5 django-rest-swagger==0.3.10 XlsxWriter sphinx requests<2.12
/env/bin/pip3 install cairocffi defusedxml mdtraj django-graphos django-haystack<2.6 django-revproxy
/env/bin/pip3 install django-sendfile pandas bokeh==1.2.0
/env/bin/pip3 install mdsrv
mkdir -p /env/lib/python3.4/site-packages/mdsrv
ln -s /env/lib64/python3.4/site-packages/mdsrv/webapp /env/lib/python3.4/site-packages/mdsrv/webapp

# install apache
yum -y install httpd httpd-devel mod_xsendfile
systemctl enable httpd.service

# install mod-wsgi
/env/bin/pip3 install mod-wsgi

# Copy from OLD gandalf to new gandalf /etc/httpd and /var/www without following symlinks
# and preserving owner and group names and permissions.

# Update config files from apache 2.2 to 2.4 format.

# Enable ports 80 and 443 in the firewall.

# edit config files coming from OLD gandalf to remove the old LoadModule wsgi_module
echo 'LoadModule wsgi_module /env/lib64/python3.4/site-packages/mod_wsgi/server/mod_wsgi-py34.cpython-34m.so' >> /etc/httpd/conf/httpd.conf

systemctl restart httpd.service

# install and configure certibot: https://certbot.eff.org/lets-encrypt/centosrhel7-apache

# install rdkit
yum -y install cmake sqlite sqlite-devel tcl-devel tk-devel readline-devel bzip2-devel libtiff-devel
yum -y install freetype-devel libwebp-devel lcms2-devel cairo
curl -sLo /protwis/conf/protwis_puppet_modules/rdkit/rdkit.tar.gz https://github.com/rdkit/rdkit/archive/Release_2016_03_1.tar.gz
bash rdkit.sh /usr/local

systemctl restart httpd.service

