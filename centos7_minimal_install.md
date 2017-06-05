	### Centos 7 Minimal Install 

[TOC]

####  Get the machine on the network.

a. Get network device name: `${DEVICE}`
```bash
$ DEVICE=$(ip link show)
```
b.  Utilize `vi` to open the network interface configuration file[^1] 
```bash
$ vi /etc/sysconfig/network-scripts/ifcfg-${DEVICE}
```
c. Populate the network interface configuration file with the following:
```vim
	HWADDR=xx:xx:xx:xx:xx:xx
	UUID=${UUID}
	DEVICE=eth0
	BOOTPROTO=static
	IPADDR=xxx.xxx.xxx.xxx
	NETMASK=xxx.xxx.xxx.xxx
	GATEWAY=xxx.xxx.xxx.xxx
	NM_CONTROLLED=no
	PERSISTENT_DHCLIENT=1
	ONBOOT=yes
	TYPE=Ethernet
	DEFROUTE=yes
	PEERDNS=yes
	PEERROUTES=yes
	IPV4_FAILURE_FATAL=yes
	IPV6INIT=yes
	IPV6_AUTOCONF=yes
	IPV6_DEFROUTE=yes
	IPV6_PEERDNS=yes
	IPV6_PEERROUTES=yes
	IPV6_FAILURE_FATAL=no
	NAME=enp0s3
```
d. Restart the network service.

```bash
$ systemctl restart network.service 
```
e. Verify 
```bash
$ systemctl status network.service -l
$ ip address show ${DEVICE} | grep inet | grep -v inet6
```

#### Set Hostname and DNS

a. Utilize `vi` to open `/etc/sysconfig/network`
```bash
$ vi /etc/sysconfig/network
```
b. Populate `/etc/sysconfig/network` with the following:
```vim
	HOSTNAME=${HOSTNAME}.${DOMAIN}
	DNS1=xxx.xxx.xxx.xxx
	DNS2=8.8.8.8
	SEARCH=${DOMAIN}
```
c. Utilize `vi` to open `/etc/hosts`
```bash
$ vi /etc/hosts
```
d. Append the following to `/etc/hosts`
```vim
	xxx.xxx.xxx.xxx     ${HOSTNAME}     ${HOSTNAME}.${DOMAIN}
```
e.  User `hostnamectl` to set the hostname
```bash
$ hostnamectl set-hostname ${HOSTNAME}
$ hostnamectl set-hostname ${HOSTNAME}.${DOMAIN} --static
```
f. Verify
```bash
$ hostnamectl status
```
g. Restate Network
```bash
$ systemctl restart network.service
```
#### Add the admin user and give sudo rights.

```bash
$ useradd ${ADMIN}
$ visudo
```
Add to following to line 99
```vim
${ADMIN}     ALL=(ALL)     NOPASSWD: ALL
```

```bash
$ passwd ${ADMIN}
```

####  Secure copy `sli_iptables.sh` and `id_rsa.pub`
```bash
$ scp ${USERNAME}@${REMOTE}:~/Dropbox/scripts/bash/sli_iptables.sh .
$ scp ${USERNAME}@${REMOTE}:~/Dropbox/scripts/bash/sli_ip6tables.sh .
$ scp ${USERNAME}@${REMOTE}:~/.ssh/id_rsa.pub .
```

#### Secure OpenSSH

a. Open `/etc/ssh/sshd_config` with `vi`
```bash
$ vi /etc/ssh/sshd_config
```
b. Alter **line 17** as follows in order to change the port the OpenSSH listen on:
```vim
Port xxxx
```
c. Alter **line 49** as follows in order to prevent root login:
```vim
PermitRootLogin no
```
d. Add the following to **line 53** in order to limit users allowed to login:
```vim
AllowUsers ${ADMIN}
```
e. Alter **line 77** as follows in order to disable password authentication:
```vim
PasswordAuthentication no
```

##### Add public key to `authorized_keys`
a. Go to the admin user's home directory `$ cd /home/${admin}`.
b. Create the .ssh directory `$ mkdir .ssh`, and generate an ssh key `$ ssh-keygen -t rsa`.
c. Create the `authorized_keys` file within the ssh directory `$ touch .ssh/authorized_keys`.
d. Copy the public key from `${REMOTE}` computer into `.ssh/authorized_keys`:
`$ sudo cat ${ROOT}/id_rsa.pub > .ssh/authorized_keys` 
e. As the admin user to the following
```bash
$ chmod 700 ~/.ssh && \
> chmod 600 ~/.ssh/id_rsa && \
> chmod 600 ~/.ssh/authorized_keys
```

#### Update all available software

```bash
$ sudo yum -y update
```

##### Install the EPEL Repo

```bash
$ sudo yum install epel-release
```

#### Install semanager

```bash
$ sudo yum -y install policycoreutils-python
```

#### Update selinux, labeling the chosen ssh port correctly.

```bash
$ semanage port -a -t ssh_port_t -p tcp xxxx
```

#### Mask firewalld and enable iptables

a. Install iptables:
```bash
root@${HOSTNAME}:~$ yum -y install iptables-services
```
b. Mask firewalld
```bash
root@${HOSTNAME}:~$ systemctl mask firewalld.service
```
c. Enable iptables
```bash
root@${HOSTNAME}:~$ systemctl enable iptables.service
root@${HOSTNAME}:~$ systemctl enable ip6tables.service
```
d. Stop firewalld and start the iptables:
```bash
root@${HOSTNAME}:~$ systemctl stop firewalld.service
root@${HOSTNAME}:~$ systemctl start iptables.service
root@${HOSTNAME}:~$ systemctl start ip6tables.service
```
e. Execute `/root/sli_iptables.sh
```bash
root@${HOSTNAME}:~$ ./sli_iptables.sh
```

### Extra 

#### For networking purposes

``` bash 
yum -y install bind-utils
yum -y install net-tools
yum -y install nmap
```

[^1]: `/etc/sysconfig/network-scripts/ifcfg-${DEVICE}`
