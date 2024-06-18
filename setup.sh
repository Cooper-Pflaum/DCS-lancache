#!/bin/bash

nginx_conf="/etc/nginx/nginx.conf"

### Download nginx_lancache setup-cache.sh script ###
sudo printf '\e[0;37mDownloading nginx_lancache...\n\e[0m'
curl -o ./setup-cache.sh https://raw.githubusercontent.com/mcnc-clovett/nginx_lancache/debian/setup-cache.sh > /dev/null
printf '\e[1;32mFinished nginx_lancache download\n\n\e[0m'

printf "\e[0;37mRunning nginx_lancache setup script...\n\e[0m"
sudo chmod +x setup-cache.sh
./setup-cache.sh
printf "\e[1;32mCompleted script\n\n\n\n\e[0m"


# Prompt the user for DNS IP
echo '--------------------------------- DNS IP --------------------------------'
printf '  Please provide the DNS IPs that you use                          \n'
printf '  If you wish to provide multiple they need to be seperated by a space:  \n'
printf '    (Ex) DNS IP Address: \e[1;34m8.8.8.8 8.8.4.4    \n\e[0m'
read -p $' DNS IP Address: \e[34m'    dns_addr  # Used for line 17 in nginx.conf

printf "\n\e[0m"

echo '------------------------------- LISTEN IP -------------------------------'
printf '  This should be the IP address of this server                \n'
printf '  There will only be one that is specified for this server    \n'
printf '  It allows access to the server on port 8080   \n\n'
printf '    (Ex) Listening IP Address: \e[1;34m127.0.0.1    \n\e[0m'
read -p $' Listening IP Address: \e[34m' lst_addr # Used for line 218 in nginx.conf

printf "\n\e[0m"

echo '------------------------------ MONITOR IP ------------------------------'
printf '  This is the only IP that can access the nginx admin console      \n'
printf '  All other connections to the server will be denied           \n'
printf '  Note: This IP that you select should be able to successfully ping this server\n'
printf '  \e[1;31mWARNING:\e[0m if you set this to \e[1;31mall\e[0m, any person on the same LAN can monitor these servers \e[0m\n\n'
printf '    (Ex) Monitor IP Address: \e[1;34m127.0.0.1    \n\e[0m'
read -p $' Monitor IP Address: \e[34m'        mon_addr  # Used for line 223 in nginx.conf
printf "\n\e[0m"



old_dns="        resolver 8.8.8.8 8.8.4.4 ipv6=off;"
new_dns="        resolver $dns_addr ipv6=off;"

old_lst="		listen 127.0.0.1:8080;"
new_lst="		listen $lst_addr:8080;"

old_mon="			allow 127.0.0.1;"
new_mon="			allow $mon_addr;"
### Edit the nginx.conf file located at /etc/nginx/nginx.conf ###
sed -i "s|^$old_dns|$new_dns|" "$nginx_conf"
sed -i "s|^$old_lst|$new_lst|" "$nginx_conf"
sed -i "s|^$old_mon|$new_mon|" "$nginx_conf"

sudo printf '\e[0;37mDRestarting nginx\n\e[0m'
systemctl restart nginx
printf '\e[1;32mnginx rebooted successfully\n\n\e[0m'
