#!/usr/bin/env bash

hostnamectl set-hostname ${instance_name}

sudo apt update

sudo apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev

cd /usr/src/

sudo curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${asterisk_version}-current.tar.gz

sudo tar xvf asterisk-${asterisk_version}-current.tar.gz

cd asterisk-${asterisk_version}*/

sudo contrib/scripts/get_mp3_source.sh

public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

sed -i "s/PUBLIC_IP/$public_ip/g" /home/ubuntu/config/extensions.conf

sudo contrib/scripts/install_prereq install

sudo ./configure

sudo make

sudo make install

sudo make samples

sudo make config

sudo make install-logrotate

sudo rsync -av /home/ubuntu/config/ /etc/asterisk/

reboot

#for observing the compile and setup process: 
#watch tail -n 50 /var/log/cloud-init-output.log