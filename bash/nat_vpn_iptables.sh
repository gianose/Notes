#!/bin/bash
#
# iptables example configuration script
#
# Flush all current rules from iptables
#
iptables -F
#
# Allow SSH connections on tcp port 4610
# This is essential when working on remote servers via SSH to prevent locking yourself out of the system
#
iptables -A INPUT -p tcp --dport 4610 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 4610 -j ACCEPT
#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
#
# Set access for localhost
#
iptables -A INPUT -i lo -j ACCEPT
#
# Accept packets belonging to established and related connections
#
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#
#Allow ipsec traffic
#
iptables -A INPUT -m policy --dir in --pol ipsec -j ACCEPT
iptables -A FORWARD -m policy --dir in --pol ipsec -j ACCEPT
#
#Forwarding rules for VPN
#
iptables -A FORWARD -i ppp+ -p all -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
#
# ****NAT VPN TRAFFIC*****
#
# iptables -t nat -A POSTROUTING -s 172.20.1.0/26 -o enp0s3 -m policy --dir out --pol none -j MASQUERADE
iptables -t nat -I POSTROUTING -s 172.20.2.0/28 -d 172.20.1.0/26  -j RETURN
iptables -t nat -A POSTROUTING -s 172.20.2.0/28 -d 0.0.0.0/8 -j MASQUERADE
#
#Ports for Openswan / xl2tpd
#
iptables -A INPUT -m policy --dir in --pol ipsec -p udp --dport 1701 -j ACCEPT
iptables -A INPUT -p udp --dport 500 -j ACCEPT
iptables -A OUTPUT -p udp --sport 500 -j ACCEPT
iptables -A INPUT -p udp --dport 4500 -j ACCEPT
iptables -A OUTPUT -p udp --sport 4500 -j ACCEPT
#
# Save settings
#
/sbin/service iptables save
#
# List rules
#
iptables -L -v