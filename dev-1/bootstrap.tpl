#!/usr/bin/env bash
export HOME=/home/ubuntu

hostnamectl set-hostname ${instance_name}

apt update

apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev certbot apache2 python3-certbot python3-certbot-apache

cd /usr/src/

curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${asterisk_version}-current.tar.gz

tar xvf asterisk-${asterisk_version}-current.tar.gz

cd asterisk-${asterisk_version}*/

contrib/scripts/get_mp3_source.sh

public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

sed -i "s/PUBLIC_IP/$public_ip/g" /home/ubuntu/asterisk/config/extensions.conf

#inject passwords
sed -i "s/ARI_PASSWORD/${ari_password}/g" /home/ubuntu/asterisk/config/ari.conf
sed -i "s/PW_PHONE_01/${pw_phone_01}/g" /home/ubuntu/asterisk/config/pjsip.conf

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

#Configure Apache2
a2enmod ssl
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_wstunnel
rsync -av /home/ubuntu/apache/config/000-default.conf /etc/apache2/sites-enabled/
rsync -av /home/ubuntu/apache/config/ports.conf /etc/apache2/
sed -i "s/DOMAIN/${domain_name}/g" /etc/apache2/sites-enabled/000-default.conf
service apache2 restart
certbot -d ${domain_name} -m ${domain_contact_mail} --agree-tos -n --apache
cat /home/ubuntu/apache/config/000-default-le-ssl.conf >> /etc/apache2/sites-enabled/000-default-le-ssl.conf
sed -i "s/DOMAIN/${domain_name}/g" /etc/apache2/sites-enabled/000-default-le-ssl.conf

git clone https://github.com/InnovateAsterisk/Browser-Phone.git
sudo cp -r Browser-Phone/Phone/* /var/www/html/

mkdir -p /etc/asterisk/keys
ln -s /etc/letsencrypt/live/${domain_name}/privkey.pem /etc/asterisk/keys/asterisk.key
ln -s /etc/letsencrypt/live/${domain_name}/cert.pem /etc/asterisk/keys/asterisk.crt

reboot

#for observing the compile and setup process: 
#watch tail -n 50 /var/log/cloud-init-output.log