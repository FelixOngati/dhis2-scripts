#!/bin/bash
#       ____  __  ______________ 
#      / __ \/ / / /  _/ ___/__ \
#     / / / / /_/ // / \__ \__/ /
#    / /_/ / __  // / ___/ / __/ 
#   /_____/_/ /_/___//____/____/
#
#   Installation stackscript
#
#<UDF name="myuser" label="Username:">
#<UDF name="ssh" label="SSH Public Key:">
#<UDF name="sshport" label="SSH Port:" default="22">
#<UDF name="hostname" label="The hostname for the new Linode.">
#<UDF name="fqdn" label="The new Linode's Fully Qualified Domain Name">

# enable firewall
ufw enable

# This updates the packages on the system from the distribution repositories.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y


# This sets the variable $IPADDR to the IP address the new Linode receives.
IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')

# This section sets the hostname.
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname

# This section sets the Fully Qualified Domain Name (FQDN) in the hosts file.
echo $IPADDR $FQDN $HOSTNAME >> /etc/hosts

# Create administrative user
useradd -m -G sudo -s /bin/bash ${MYUSER}

# Perform tasks for new user
# set a temporary password
echo $(</dev/urandom tr -dc A-Za-z0-9 | head -c 10) > /home/$MYUSER/passwd.txt
chmod 600 /home/$MYUSER/passwd.txt
echo "${MYUSER}:$(cat /home/${MYUSER}/passwd.txt)" | chpasswd

# This sets your public key on your Linode
mkdir /home/$MYUSER/.ssh
echo "${SSH}" >> /home/$MYUSER/.ssh/authorized_keys
chmod 600 /home/$MYUSER/.ssh/authorized_keys

# make sure user owns everything
chown -R $MYUSER.$MYUSER /home/$MYUSER

# Tighten up ssh
# Disables password authentication
sed -i 's/#*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config
# Disable root login
sed -i 's/PermitRootLogin [a-zA-Z]*/PermitRootLogin no/' /etc/ssh/sshd_config
# Change Port
sed -i "s/Port [0-9]*/Port $SSHPORT/" /etc/ssh/sshd_config
# This restarts the SSH service
service ssh restart

# Allow ssh through firewall
ufw limit $SSHPORT/tcp

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
