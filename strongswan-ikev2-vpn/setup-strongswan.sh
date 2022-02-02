#!/usr/bin/env bash

# Author: github/3n3a
# Shell Script Template: https://betterdev.blog/minimal-safe-bash-script-template/
# Setup for Ubuntu SErver 18-04: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-ikev2-vpn-server-with-strongswan-on-ubuntu-18-04-2
# Setup for Ubuntu Server 20-04: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-ikev2-vpn-server-with-strongswan-on-ubuntu-20-04

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] -c "VPN root CA" -u admin -p 12345678 -d vpn.example.com

Setup script used on new cloud-vms in order to very quickly setup an IKEV2 VPN-Server.
For the VPN-Software Strongswan is being used, with IPSec for Authentication. The Script
sets up the integrated UFW Firefwall, but if your Cloud-Provider has Port Rules you should
add an ALLOW record for the UDP Ports: 500 and 4500.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-c, --ca-name	Name of Certificate Authority created
-u, --username	Username for IKEV2 Authentication
-p, --password	Password for IKEV2 Authentication
-d, --domain	Domainname that has A/CNAME which points to Public-IP/DNS-Name of Server
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -c | --ca-name)
		ca_name="${2-}"
		shift
    ;;
    -u | --username)
		vpn_usr="${2-}"
		shift
      ;;
    -p | --password)
		vpn_pw="${2-}"
		shift
    ;;
    -d | --domain)
		server_domain_or_IP="${2-}"
		shift
    ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params
  [[ -z "${ca_name-}" ]] && die "Missing required parameter: ca-name"
  [[ -z "${vpn_usr-}" ]] && die "Missing required parameter: username"
  [[ -z "${vpn_pw-}" ]] && die "Missing required parameter: password"
  [[ -z "${server_domain_or_IP-}" ]] && die "Missing required parameter: domain"

  return 0
}

parse_params "$@"
setup_colors

# beginning functions
update_system-all() {
	sudo apt -qq update
	msg "Updated System with APT."
}

install_pkgs_20-4() {
	sudo apt -qq install -y strongswan strongswan-pki libcharon-extra-plugins libcharon-extauth-plugins libstrongswan-extra-plugins
	msg "Installed Packages Necessary for Strongswan"
}

install_pkgs_18-4() {
	sudo apt -qq install -y strongswan strongswan-pki
	msg "Installed Packages Necessary for Strongswan"
}

create_ca-all() {
	mkdir -p ~/pki/{cacerts,certs,private}
	chmod 700 ~/pki
	ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/ca-key.pem
	ipsec pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem --type rsa --dn "CN=${ca_name}" --outform pem > ~/pki/cacerts/ca-cert.pem
	msg "Created Certificate Authority Certificate"
}

create_server_cert-all() {
	ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/server-key.pem
	ipsec pki --pub --in ~/pki/private/server-key.pem --type rsa | ipsec pki --issue --lifetime 1825 --cacert ~/pki/cacerts/ca-cert.pem --cakey ~/pki/private/ca-key.pem --dn "CN=${server_domain_or_IP}" --san "${server_domain_or_IP}" --flag serverAuth --flag ikeIntermediate --outform pem >  ~/pki/certs/server-cert.pem
	sudo cp -r ~/pki/* /etc/ipsec.d/
	msg "Created Server Certificate"
}

config_strongswan_18-4() {
	sudo mv /etc/ipsec.conf{,.original}
	cat > /etc/ipsec.conf <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=@${server_domain_or_IP}
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=8.8.8.8,8.8.4.4
    rightsendcert=never
    eap_identity=%identity
EOF
    msg "Created Ipsec.conf with configuration"
}

config_strongswan_20-4() {
	sudo mv /etc/ipsec.conf{,.original}
	cat > /etc/ipsec.conf <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn ikev2-vpn
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=@${server_domain_or_IP}
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=8.8.8.8,8.8.4.4
    rightsendcert=never
    eap_identity=%identity
    ike=chacha20poly1305-sha512-curve25519-prfsha512,aes256gcm16-sha384-prfsha384-ecp384,aes256-sha1-modp1024,aes128-sha1-modp1024,3des-sha1-modp1024!
    esp=chacha20poly1305-sha512,aes256gcm16-ecp384,aes256-sha256,aes256-sha1,3des-sha1!
EOF
    msg "Created Ipsec.conf with configuration"
}

config_auth_ipsec-all() {
	cat > /etc/ipsec.secrets <<EOF
: RSA "server-key.pem"
${vpn_usr} : EAP "${vpn_pw}"
EOF
	msg "Created Ipsec.secrets with credentials"
}

restart_strongswan_18-4() {
	sudo systemctl restart strongswan
	msg "Restarted Strongswan"
}

restart_strongswan_20-4() {
	sudo systemctl restart strongswan-starter
	msg "Restarted Strongswan"
}

config_ufw-all() {
	sudo ufw allow OpenSSH
	sudo ufw enable
	sudo ufw allow 500,4500/udp
	DEFAULT_NETWORK_INTERFACE=$(ip route | grep default | awk '{print $5}')
	sudo cat > /etc/ufw/before.rules <<EOF
#
# rules.before
#
# Rules that should be run before the ufw command line added rules. Custom
# rules should be added to one of these chains:
#   ufw-before-input
#   ufw-before-output
#   ufw-before-forward
#

*nat
-A POSTROUTING -s 10.10.10.0/24 -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
-A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE
COMMIT

*mangle
-A FORWARD --match policy --pol ipsec --dir in -s 10.10.10.0/24 -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
COMMIT

# Don't delete these required lines, otherwise there will be errors
*filter
:ufw-before-input - [0:0]
:ufw-before-output - [0:0]
:ufw-before-forward - [0:0]
:ufw-not-local - [0:0]
# End required lines

-A ufw-before-forward --match policy --pol ipsec --dir in --proto esp -s 10.10.10.0/24 -j ACCEPT
-A ufw-before-forward --match policy --pol ipsec --dir out --proto esp -d 10.10.10.0/24 -j ACCEPT

# allow all on loopback
-A ufw-before-input -i lo -j ACCEPT
-A ufw-before-output -o lo -j ACCEPT

# quickly process packets for which we already have a connection
-A ufw-before-input -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A ufw-before-output -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A ufw-before-forward -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# drop INVALID packets (logs these in loglevel medium and higher)
-A ufw-before-input -m conntrack --ctstate INVALID -j ufw-logging-deny
-A ufw-before-input -m conntrack --ctstate INVALID -j DROP

# ok icmp codes for INPUT
-A ufw-before-input -p icmp --icmp-type destination-unreachable -j ACCEPT
-A ufw-before-input -p icmp --icmp-type time-exceeded -j ACCEPT
-A ufw-before-input -p icmp --icmp-type parameter-problem -j ACCEPT
-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT

# ok icmp code for FORWARD
-A ufw-before-forward -p icmp --icmp-type destination-unreachable -j ACCEPT
-A ufw-before-forward -p icmp --icmp-type time-exceeded -j ACCEPT
-A ufw-before-forward -p icmp --icmp-type parameter-problem -j ACCEPT
-A ufw-before-forward -p icmp --icmp-type echo-request -j ACCEPT

# allow dhcp client to work
-A ufw-before-input -p udp --sport 67 --dport 68 -j ACCEPT

#
# ufw-not-local
#
-A ufw-before-input -j ufw-not-local

# if LOCAL, RETURN
-A ufw-not-local -m addrtype --dst-type LOCAL -j RETURN

# if MULTICAST, RETURN
-A ufw-not-local -m addrtype --dst-type MULTICAST -j RETURN

# if BROADCAST, RETURN
-A ufw-not-local -m addrtype --dst-type BROADCAST -j RETURN

# all other non-local packets are dropped
-A ufw-not-local -m limit --limit 3/min --limit-burst 10 -j ufw-logging-deny
-A ufw-not-local -j DROP

# allow MULTICAST mDNS for service discovery (be sure the MULTICAST line above
# is uncommented)
-A ufw-before-input -p udp -d 224.0.0.251 --dport 5353 -j ACCEPT

# allow MULTICAST UPnP for service discovery (be sure the MULTICAST line above
# is uncommented)
-A ufw-before-input -p udp -d 239.255.255.250 --dport 1900 -j ACCEPT

# don't delete the 'COMMIT' line or these rules won't be processed
COMMIT
EOF
	cat > /etc/ufw/sysctl.conf <<EOF
#
# Configuration file for setting network variables. Please note these settings
# override /etc/sysctl.conf and /etc/sysctl.d. If you prefer to use
# /etc/sysctl.conf, please adjust IPT_SYSCTL in /etc/default/ufw. See
# Documentation/networking/ip-sysctl.txt in the kernel source code for more
# information.
#

# Uncomment this to allow this host to route packets between interfaces
## added by strongswan config
net/ipv4/ip_forward=1
net/ipv6/conf/default/forwarding=1
net/ipv6/conf/all/forwarding=1

# Disable ICMP redirects. ICMP redirects are rarely used but can be used in
# MITM (man-in-the-middle) attacks. Disabling ICMP may disrupt legitimate
# traffic to those sites. 
## added by strongswan config
net/ipv4/conf/all/accept_redirects=0
net/ipv4/conf/default/accept_redirects=0
net/ipv6/conf/all/accept_redirects=0
net/ipv6/conf/default/accept_redirects=0

## added by strongswan config
net/ipv4/conf/all/send_redirects=0
net/ipv4/ip_no_pmtu_disc=1

# Ignore bogus ICMP errors
net/ipv4/icmp_echo_ignore_broadcasts=1
net/ipv4/icmp_ignore_bogus_error_responses=1
net/ipv4/icmp_echo_ignore_all=0

# Don't log Martian Packets (impossible addresses)
# packets
net/ipv4/conf/all/log_martians=0
net/ipv4/conf/default/log_martians=0

#net/ipv4/tcp_fin_timeout=30
#net/ipv4/tcp_keepalive_intvl=1800

# Uncomment this to turn off ipv6 autoconfiguration
#net/ipv6/conf/default/autoconf=1
#net/ipv6/conf/all/autoconf=1

# Uncomment this to enable ipv6 privacy addressing
#net/ipv6/conf/default/use_tempaddr=2
#net/ipv6/conf/all/use_tempaddr=2
EOF
	sudo ufw disable
	sudo ufw enable
	msg "Configured UFW and the Kernel for IP forwarding "
}

print_cert() {
	msg "${RED}Root Certificate:${GREEN}"
	sudo cat /etc/ipsec.d/cacerts/ca-cert.pem
	msg "${NOFORMAT}"
}

ubuntu_20-4() {
	update_system-all
	install_pkgs_20-4
	create_ca-all
	create_server_cert-all
	config_strongswan_20-4
	config_auth_ipsec-all
	restart_strongswan_20-4
	config_ufw-all
	print_cert
}

ubuntu_18-4() {
	update_system-all
	install_pkgs_18-4
	create_ca-all
	create_server_cert-all
	config_strongswan_18-4
	config_auth_ipsec-all
	restart_strongswan_18-4
	config_ufw-all
	print_cert
}
# end user functions
UBUNTU_VERSION=$(lsb_release -r | awk '{print $2}')
if [ $UBUNTU_VERSION = "20.04" ]; then
	msg "Started Setup on Ubuntu ${UBUNTU_VERSION}"
	#ubuntu_20-4
elif [ $UBUNTU_VERSION = "18.04" ]; then
	msg "Started Setup on Ubuntu ${UBUNTU_VERSION}"
	#ubuntu_18-4
else
	echo "Not a supported Ubuntu Version / Not even Ubuntu!"
	echo
	msg "${RED}Inputted Params for Debug:${NOFORMAT}"
	msg "CA: ${ca_name}"
	msg "USR: ${vpn_usr}"
	msg "PW: ${vpn_pw}"
	msg "DO: ${server_domain_or_IP}"
fi
