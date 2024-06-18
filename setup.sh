#!/bin/bash

nginx_conf="/etc/nginx/nginx.conf"


### Update server ###
sudo apt update
sudo apt upgrade -y

### Download nginx_lancache setup-cache.sh script ###
printf '\n\n\e[1;33mDownloading nginx_lancache...\n\e[0m'
curl -o ./setup-cache.sh https://raw.githubusercontent.com/mcnc-clovett/nginx_lancache/debian/setup-cache.sh > /dev/null
printf '\e[1;32mFinished nginx_lancache download\n\n\e[0m'

### Run the nginx_lancache script ###
printf "\e[0;37mRunning nginx_lancache setup script...\n\e[0m"
sudo chmod +x setup-cache.sh
./setup-cache.sh
rm setup-cache.sh

printf "\n"

# Prompt the user for IPs
printf '--------------------------------- DNS IP --------------------------------'
printf '  Please provide the DNS IPs that you use\n'
printf '  If you wish to provide multiple they need to be seperated by a space:\n'
printf '    (Ex) DNS IP Address: \e[1;34m8.8.8.8 8.8.4.4\n\e[0m'
printf ' DNS IP Address: \e[34m'
read -r dns_addr 

printf "\n\e[0m"

printf '------------------------------ MONITOR IP ------------------------------'
printf '  This is the only IP that can access the nginx admin console\n'
printf '  All other connections to the server will be denied\n'
printf '  Note: This IP that you select should be able to successfully ping this server\n'
printf '  \e[1;31mWARNING:\e[0m if you set this to \e[1;31mall\e[0m, any person on the same LAN can monitor these servers\e[0m\n\n'
printf '    (Ex) Monitor IP Address: \e[1;34m127.0.0.1\n\e[0m'
printf 'Monitor IP Address: \e[34m'
read -r mon_addr

printf "\n\e[0m"


### Edit the nginx.conf file located at /etc/nginx/nginx.conf ###
ip_addr=$(hostname -I | awk '{print $1}')

echo "machine IP: $ip_addr"

old_dns="        resolver 8.8.8.8 8.8.4.4 ipv6=off;"
new_dns="        resolver $dns_addr ipv6=off;"

old_lst="        listen 127.0.0.1:8080;"
new_lst="        listen $(hostname -I):8080;"

old_mon="			allow 127.0.0.1;"
new_mon="			allow $mon_addr;"

sed -i "s|^$old_dns|$new_dns|" "$nginx_conf" # Edits lines 17 and 61 in /etc/nginx/nginx.conf
sed -i "s|^$old_lst|$new_lst|" "$nginx_conf" # Edits line 218 in /etc/nginx/nginx.conf 
sed -i "s|^$old_mon|$new_mon|" "$nginx_conf" # Edits line 223 in /etc/nginx/nginx.conf

printf '\e[0;37mDRestarting nginx\n\e[0m'
systemctl restart nginx
printf '\e[1;32mnginx rebooted successfully\n\n\e[0m'

# Prompt the user to remove the script file
read -p "Do you want to remove this script file? (y/n) " remove_script
if [[ $remove_script =~ ^[Yy]$ ]]; then
    rm -- "$0"
    printf '\e[1;32mScript file removed successfully.\n\e[0m'
else
    printf '\e[1;33mScript file not removed.\n\e[0m'
fi


