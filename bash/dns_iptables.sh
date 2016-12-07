#!/bin/bash
#
# iptables configuration for DNS server.
#
# Flush all current rules from iptables
#
iptables -F
#
# Allow SSH connections on tcp port 4610
# This is essential when working on remote servers via SSH to prevent locking yourself out of the system
#
iptables -A INPUT -p tcp --dport 4610 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 4610 -m state --state ESTABLISHED -j ACCEPT
# 
# Allow outbound HTTP
#
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
# 
# Allow outbound HTTPS
#
iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
#
# Ping from inside to outside
#
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
#
# Ping from outside to inside
#
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
#
# Allows udp connections to the BIND server from the local network.
# Allows packets associated with established udp connections on port 53.
#
NETWORK=172.20.1.0/26
SERVER=172.20.1.26
iptables -A INPUT -p udp -s ${NETWORK} --sport 1024:65535 -d ${SERVER} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp -s ${SERVER} --sport 53 -d ${NETWORK} --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -s ${NETWORK} --sport 53 -d ${SERVER} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp -s ${SERVER} --sport 53 -d ${NETWORK} --dport 53 -m state --state ESTABLISHED -j ACCEPT
#
# Set access for localhost
#
iptables -I INPUT 1 -i lo -j ACCEPT
#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
#iptables -A INPUT -j DROP
#iptables -P FORWARD DROP
#iptables -P OUTPUT DROP
#
# Accept packets belonging to established and related connections
#
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#
# q1Log dropped packets
#
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOGGING -j DROP
#
# Save settings
#
/sbin/service iptables save
#
# List rules
#
iptables -L -v