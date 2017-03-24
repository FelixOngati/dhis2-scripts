#!/bin/bash
#
# Starting DHIS2 install

#add PPA
apt-get install software-properties-common
add-apt-repository -y ppa:bobjolliffe/dhis2-tools
add-apt-repository -y ppa:webupd8team/java
apt-get -y update

#accept oracle license
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

#install java8 and dhis2-tools
apt-get -y install oracle-java8-installer
apt-get -y install dhis2-tools


# Uncomment below to install postgres and nginx servers on this machine
apt-get -y install nginx postgresql
echo "The dhis2-tools are now installed. You may also want to"
echo "install nginx and postgresql servers on this machine. You"
echo "can do so by running:"
echo
echo "apt-get install nginx postgresql"
echo
echo "You should check out the DHIS2 documentation for Postgres performance tuning and more configuration help: https://goo.gl/8GGtIB"
echo
echo "Type 'apropos dhis2' to see available manual pages."
