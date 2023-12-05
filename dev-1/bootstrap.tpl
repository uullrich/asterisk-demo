#!/usr/bin/env bash
export HOME=/home/ubuntu

hostnamectl set-hostname ${instance_name}

apt update

apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev

cd /usr/src/

curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${asterisk_version}-current.tar.gz

tar xvf asterisk-${asterisk_version}-current.tar.gz

cd asterisk-${asterisk_version}*/

contrib/scripts/get_mp3_source.sh

public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

sed -i "s/PUBLIC_IP/$public_ip/g" /home/ubuntu/config/extensions.conf

contrib/scripts/install_prereq install

./configure

make

make install

make samples

make config

make install-logrotate

rsync -av /home/ubuntu/asterisk/config/ /etc/asterisk/

echo "Setting up NodeJS Environment"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
echo 'export NVM_DIR="/home/ubuntu/.nvm"' >> /home/ubuntu/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/ubuntu/.bashrc

# Dot source the files to ensure that variables are available within the current shell
. /home/ubuntu/.nvm/nvm.sh
. /home/ubuntu/.profile
. /home/ubuntu/.bashrc

echo "Installing Node Version ${node_version}"
cd /home/ubuntu
echo ${node_version} >> .nvmrc
nvm install
nvm ls

chown -R 1000:1000 "/home/ubuntu/.npm"

reboot

#for observing the compile and setup process : 
#watch tail -n 50 /var/log/cloud-init-output.log