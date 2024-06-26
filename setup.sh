#!/bin/bash

nginx_conf="/etc/nginx/nginx.conf"


### Update server ###
sudo apt update
sudo apt upgrade -y

### Download nginx_lancache setup-cache.sh script ###
echo -e '\n\n\e[1;33mDownloading nginx_lancache...\n\e[0m'
curl -o ./setup-cache.sh https://raw.githubusercontent.com/mcnc-clovett/nginx_lancache/debian/setup-cache.sh > /dev/null
echo -e '\e[1;32mFinished nginx_lancache download\n\n\e[0m'

### Run the nginx_lancache script ###
echo -e "\e[0;37mRunning nginx_lancache setup script...\n\e[0m"
sudo chmod +x setup-cache.sh
./setup-cache.sh
rm setup-cache.sh



# Prompt the user for IPs
echo -e "--------------------------------- DNS IP --------------------------------"
echo -e "  Please provide the DNS IPs that you use\n"
echo -e "  If you wish to provide multiple they need to be seperated by a space:\n"
echo -e "    (Ex) DNS IP Address: \e[1;34m8.8.8.8 8.8.4.4\n\e[0m"
echo -e -n "DNS IP Address: \e[34m"
read -r dns_addr 

echo -e "\n\e[0m"

echo -e "------------------------------ MONITOR IP ------------------------------"
echo -e "  This is the only IP that can access the nginx admin console\n"
echo -e "  All other connections to the server will be denied\n"
echo -e "  Note: This IP that you select should be able to successfully ping this server\n"
echo -e "  \e[1;31mWARNING:\e[0m if you set this to \e[1;31mall\e[0m, any person on the same LAN can monitor these servers\e[0m\n\n"
echo -e "    (Ex) Monitor IP Address: \e[1;34m127.0.0.1\n\e[0m"
echo -e -n "Monitor IP Address: \e[34m"
read -r mon_addr

echo -e "\n\e[0m"


### Edit the nginx.conf file located at /etc/nginx/nginx.conf ###
ip_addr=$(hostname -I | awk '{print $1}')

old_dns="        resolver 8.8.8.8 8.8.4.4 ipv6=off;"
new_dns="        resolver $dns_addr ipv6=off;"

old_lst="		listen 127.0.0.1:8080;"
new_lst="		listen $ip_addr:8080;"

old_mon="			allow 127.0.0.1;"
new_mon="			allow $mon_addr;"

sed -i "s|^$old_dns|$new_dns|" "$nginx_conf" # Edits lines 17 and 61 in /etc/nginx/nginx.conf
sed -i "s|^$old_lst|$new_lst|" "$nginx_conf" # Edits line 218 in /etc/nginx/nginx.conf 
sed -i "s|^$old_mon|$new_mon|" "$nginx_conf" # Edits line 223 in /etc/nginx/nginx.conf

echo -e '\e[0;37mRestarting nginx\n\e[0m'
systemctl restart nginx
echo -e '\e[1;32mnginx rebooted successfully\n\n\e[0m'

# Prompt the user to remove the script file
read -p "Do you want to remove this script file? (y/n) " remove_script
if [[ $remove_script =~ ^[Yy]$ ]]; then
    rm -- "$0"
    echo -e '\e[1;32mScript file removed successfully.\n\e[0m'
else
    echo -e '\e[1;33mScript file not removed.\n\e[0m'
fi


