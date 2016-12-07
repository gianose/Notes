#!/bin/bash
#
# iptables example configuration script
#
# Flush all current rules from iptables
#
ip6tables -F
#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT DROP
#
# Set access for localhost
#
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
#
# Accept packets belonging to established and related connections
#
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#
# Save settings
#
/sbin/service ip6tables save
#
# List rules
#
ip6tables -L -v
