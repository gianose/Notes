#!/bin/bash

# Libreswan required packages

yum -y install nss-devel
yum -y install nspr-devel
yum -y install pkgconfig
yum -y install pam-devel
yum -y install libcap-ng-devel
yum -y install libselinux-devel
yum -y install curl-devel
yum -y install flex
yum -y install bison
yum -y install gcc
yum -y install make
yum -y install fipscheck-devel
yum -y install unbound-devel 
yum -y install libevent-devel 
yum -y install xmlto
 
# Specific to CentOS 7  
yum -y install audit-libs-devel
yum -y install systemd-devel

# Specific to IKEv1 with L2TP
yum -y install ppp
yum -y install xl2tpd

yum -y install libreswan


