#!/bin/bash
set -e

# ======================================================================
# Various variables

TZ="US/Eastern"
NETDATA_URL="https://my-netdata.io/kickstart.sh"
NGINX_CONF_URL="https://raw.githubusercontent.com/mcnc-clovett/nginx_lancache/debian/etc/nginx/nginx.conf"

# ======================================================================
# Check if we're running Debian or Ubuntu.

DEBIAN_STR="NAME=\"Debian GNU/Linux\""
UBUNTU_STR="NAME=\"Ubuntu\""

if grep -q "$DEBIAN_STR" /etc/os-release; then
  DISTRO="Debian"
elif grep -q "$UBUNTU_STR" /etc/os-release; then
  DISTRO="Ubuntu"
else
  echo "This script is only tested with Debian and Ubuntu. Exiting now."
  exit 1
fi

# ======================================================================
# Install Zscaler certificate. Replace with your SSL inspection cert if needed.

mkdir -p /usr/local/share/ca-certificates/Zscaler
cat << EOF > /usr/local/share/ca-certificates/Zscaler/ZscalerRootCertificate-2048-SHA256.crt
-----BEGIN CERTIFICATE-----
MIIE0zCCA7ugAwIBAgIJANu+mC2Jt3uTMA0GCSqGSIb3DQEBCwUAMIGhMQswCQYD
VQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8GA1UEBxMIU2FuIEpvc2Ux
FTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMMWnNjYWxlciBJbmMuMRgw
FgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRA
enNjYWxlci5jb20wHhcNMTQxMjE5MDAyNzU1WhcNNDIwNTA2MDAyNzU1WjCBoTEL
MAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBK
b3NlMRUwEwYDVQQKEwxac2NhbGVyIEluYy4xFTATBgNVBAsTDFpzY2FsZXIgSW5j
LjEYMBYGA1UEAxMPWnNjYWxlciBSb290IENBMSIwIAYJKoZIhvcNAQkBFhNzdXBw
b3J0QHpzY2FsZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
qT7STSxZRTgEFFf6doHajSc1vk5jmzmM6BWuOo044EsaTc9eVEV/HjH/1DWzZtcr
fTj+ni205apMTlKBW3UYR+lyLHQ9FoZiDXYXK8poKSV5+Tm0Vls/5Kb8mkhVVqv7
LgYEmvEY7HPY+i1nEGZCa46ZXCOohJ0mBEtB9JVlpDIO+nN0hUMAYYdZ1KZWCMNf
5J/aTZiShsorN2A38iSOhdd+mcRM4iNL3gsLu99XhKnRqKoHeH83lVdfu1XBeoQz
z5V6gA3kbRvhDwoIlTBeMa5l4yRdJAfdpkbFzqiwSgNdhbxTHnYYorDzKfr2rEFM
dsMU0DHdeAZf711+1CunuQIDAQABo4IBCjCCAQYwHQYDVR0OBBYEFLm33UrNww4M
hp1d3+wcBGnFTpjfMIHWBgNVHSMEgc4wgcuAFLm33UrNww4Mhp1d3+wcBGnFTpjf
oYGnpIGkMIGhMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8G
A1UEBxMIU2FuIEpvc2UxFTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMM
WnNjYWxlciBJbmMuMRgwFgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG
9w0BCQEWE3N1cHBvcnRAenNjYWxlci5jb22CCQDbvpgtibd7kzAMBgNVHRMEBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAw0NdJh8w3NsJu4KHuVZUrmZgIohnTm0j+
RTmYQ9IKA/pvxAcA6K1i/LO+Bt+tCX+C0yxqB8qzuo+4vAzoY5JEBhyhBhf1uK+P
/WVWFZN/+hTgpSbZgzUEnWQG2gOVd24msex+0Sr7hyr9vn6OueH+jj+vCMiAm5+u
kd7lLvJsBu3AO3jGWVLyPkS3i6Gf+rwAp1OsRrv3WnbkYcFf9xjuaf4z0hRCrLN2
xFNjavxrHmsH8jPHVvgc1VD0Opja0l/BRVauTrUaoW6tE+wFG5rEcPGS80jjHK4S
pB5iDj2mUZH1T8lzYtuZy0ZPirxmtsk3135+CKNa2OCAhhFjE0xd
-----END CERTIFICATE-----
EOF

dpkg-reconfigure -f noninteractive ca-certificates

# ======================================================================
# Update the OS

DEBIAN_FRONTEND=noninteractive apt update && apt full-upgrade -y

# ======================================================================
# Install NGINX and other useful packages

DEBIAN_FRONTEND=noninteractive apt install -y sudo curl vim nginx libnginx-mod-stream unattended-upgrades

# ======================================================================
# Set up unattended upgrades

if [ $DISTRO = "Debian" ]; then
  UNATTEND_CONF='/etc/apt/apt.conf.d/50unattended-upgrades'
  sed -i -e '/Unattended-Upgrade::Origins-Pattern {/ a\        "o=Netdata,l=Netdata";' \
    -e '/Unattended-Upgrade::Origins-Pattern {/ a\        "o=amplify,l=stable";' \
    -e '/\/\/\s*"origin=Debian,codename=${distro_codename}-updates";/ s,//\s*,        ,g' \
    -e '/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/ s,//,,g' \
    -e 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|' $UNATTEND_CONF
elif [ $DISTRO = "Ubuntu" ]; then
  UNATTEND_CONF='/etc/apt/apt.conf.d/50unattended-upgrades'
  sed -i -e "/Unattended-Upgrade::Allowed-Origins {/ i\Unattended-Upgrade::Origins-Pattern {\n        \"o=Netdata,l=Netdata\";\n};" \
    -e '/\/\/\s*"${distro_id}:${distro_codename}-updates";/ s,//\s*,        ,g' \
    -e '/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/ s,//,,g' \
    -e 's|//Unattended-Upgrade::Automatic-Reboot "false";|Unattended-Upgrade::Automatic-Reboot "true";|' $UNATTEND_CONF
else
  echo "Unable to reliably set up unattended upgrade configuration, exiting."
  exit 1
fi

echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades
systemctl restart unattended-upgrades.service

# ======================================================================
# Backup stock NGINX config and overwrite with cache config, then restart

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old

mkdir -p /var/cache/nginx

curl -fsSL -o /etc/nginx/nginx.conf $NGINX_CONF_URL

systemctl restart nginx.service

# ======================================================================
# Download and setup Netdata

curl -fsSL $NETDATA_URL > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --stable-channel --non-interactive --disable-telemetry

cat << EOF > /etc/netdata/go.d/nginx.conf
jobs:
  - name: local
    url: http://127.0.0.1:8080/nginx_status
EOF

systemctl restart netdata.service
