
## CentOS 7 DNS Sever

### Install BIND on DNS Server

On the VPS (virtual private server) DNS, install BIND with yum:

```bash
$ sudo yum -y install bind bind-utils
```

### Configure DNS Server

#### Configure Bind

BIND's process is known as named. As such, many of the files refer to "named" instead of "BIND".

On _dns_, open the `named.conf` file for editing:

```bash
$ sudo vi /etc/named.conf
```
Above the existing **`options`** block, create a new  **`acl`** block called "trusted". This is where we will define list of clients that we will allow recursive DNS queries from.

```vim
acl "trusted" {
        172.20.1.26; # dns - can be set to localhost
        172.20.1.23; # vpn
        172.20.1.6;  # host1
        172.20.1.8;  # host2
};
```

_Edit the options block:_

* Add the private IP address of _dns_ to the `listen-on port 53` directive (line 18).
* Comment out the `listen-on-v6` line (line 19).
* Change `allow-query` directive from "localhost" to "trusted"

```vim
options {
        listen-on port 53 { 127.0.0.1; 172.20.1.26; };
#       listen-on-v6 port 53 { ::1; };
...
		allow-query { trusted; };
```

At the end of the file, add the following line:

```bash
include "/etc/named/named.conf.local";
```

### Configure Local File

On _dns_, open the `named.conf.local` file for editing:

```bash
$ sudo vi /etc/named/named.conf.local
```

The file should be empty. Here, we will specify our forward and reverse zones.

Add the forward zone with the following lines:

```vim
zone "gianose.mooo.com" {                                            
        type master;                                                 
        file "/etc/named/zones/db.gianose.mooo.com"; # zone file path
};                                                                   
```

Add the reverse zone by with the following lines (note that our reverse zone name starts with "20.172" which is the octet reversal of "172.20"):

```vim
zone "1.20.172.in-addr.arpa" {                                     
        type master;                                             
        file "/etc/named/zones/db.172.20.1"; # 172.20.1.0/26 subnet
};                                                               
```

### Create Forward Zone File

The forward zone file is where we define DNS records for forward DNS lookups. That is, when the DNS receives a name query, "host1.gianose.mooo.com" for example, it will look in the forward zone file to resolve host1's corresponding private IP address.

Let's create the directory where our zone files will reside. According to our named.conf.local configuration, that location should be /etc/named/zones:

```bash
$ sudo chmod 755 /etc/named
$ sudo mkdir /etc/named/zones
```
Now let's edit our forward zone file:

```bash
$ sudo vi /etc/named/zones/db.gianose.mooo.com
```
__Every time you edit a zone file, you should increment the serial value before you restart the named process.__

```vim
$TTL 259200
@       IN      SOA     dnsserver.gianose.mooo.com.     dns.gianose.mooo.com. (
                        20160628     ;Serial
                        86400        ;Refresh after 1 day
                        43200        ;Retry after 12 hours
                        604800       ;Expire after 1 week
                        259200 )     ;minimum TTL 3 days

; name server - NS record
        IN      NS      dnsserver.gianose.mooo.com.

                IN      A       172.20.1.21
; 172.20.1.0/26 - A records
primeserver     IN      A       172.20.1.21
vpnserver       IN      A       172.20.1.23
dnsserver       IN      A       172.20.1.26

; CNAME - Canonical name record, Alias records
prime   IN      CNAME   primeserver
vpn     IN      CNAME   vpnserver
dns     IN      CNAME   dnsserver                                                                                                                                    
```

### Create Reverse Zone File

Reverse zone file are where we define DNS PTR records for reverse DNS lookups. That is, when the DNS receives a query by IP address, "172.20.1.23" for example, it will look in the reverse zone file(s) to resolve the corresponding FQDN, "vpn.gianose.mooo.com" in this case.

Edit the reverse zone file that corresponds to the reverse zone(s) defined in named.conf.local:

```bash
sudo vi /etc/named/zones/db.172.20.1
```

```vim
$TTL 259200                                                                    
@       IN      SOA     dnsserver.gianose.mooo.com.     dns.gianose.mooo.com. (
                        20160627   ;Serial                                     
                        86400      ;Refresh after 1 day                        
                        43200      ;Retry after 12 hours                       
                        604800     ;Expire after 1 week                        
                        259200 )   ;minimum TTL 3 days                         
                                                                               
; name server - NS record                                                      
        IN      NS      dnsserver.gianose.mooo.com.                            
                                                                               
; PTR Records                                                                  
26      IN      PTR     dnsserver.gianose.mooo.com. ; 172.20.1.26              
23      IN      PTR     vpnserver.gianose.mooo.com. ; 172.20.1.23              
21      IN      PTR     primeserver.gianose.mooo.com. ; 172.20.1.21                     
```

### Check BIND Configuration Syntax

Run the following command to check the syntax of the named.conf* files:

```bash
$ sudo named-checkconf
```
If your named configuration files have no syntax errors, you will return to your shell prompt and see no error messages.

The named-checkzone command can be used to check the correctness of your zone files. 

Check forward zone:

```bash
$ sudo named-checkzone gianose.mooo.com /etc/named/zones/db.gianose.mooo.com
```

Expected response: 

```bash
zone gianose.mooo.com/IN: loaded serial 20160624
OK
```

Check reverse zone:

```bash
sudo named-checkzone 1.20.172.in-addr.arpa /etc/named/zones/db.172.20.1
```

Expected response: 

```bash
zone 1.20.172.in-addr.arpa/IN: loaded serial 20160624
OK
```

### Iptables Rules

#### Note:
* _DNS queries less than __512 bytes__ are transferred using __UDP__ protocol_ 
* _Queries __`>= 512`__ are handled via __TCP__ protocol such as zone transfer._
* _`named`/`bind`listens via UDP/TCP on port 53._
* _The client (browser, `dig`, `nmap`, ... etc) send request via ports `>= 1024`_


Copy `dns_iptables.sh` script to local machine:
```bash
$ scp ${USER}@${REMOTE}:../../dns_iptables.sh .
```
Execute script as __root__:
```bash
$ ./dns_iptables
```

### Configuring Permissions, Ownership, and SELinux

```bash
chgrp named -R /var/named && \
chown -v root:named /etc/named.conf && \
restorecon -rv /var/named && \
restorecon /etc/named.conf
```

### Start BIND

Start BIND:

```bash
$ sudo systemctl start named
```

Enable it, to start on boot:

```bash
$ sudo systemctl enable named
```

### Configure DNS Clients


#### CentOS Clients

```bash
sudo vi /etc/sysconfig/network
```

Append the following line to `/etc/sysconfig/network`

```vim
DNS1=172.20.1.26
DNS2=172.20.1.1
SEARCH=gianose.mooo.com
```

Restart the network service.

```bash
$ sudo systemctl restart network.service 
```

### OS X

Disable [System Integrity Protection (SIP)](https://en.wikipedia.org/wiki/System_Integrity_Protection) by following the following steps:

1. Reboot.
2. Press Cmd+R to enter Recovery mode.
3. Open Utilities->Terminal.
4. Run the command csrutil disable.
5. Reboot. You are back in OS X with SIP disabled.

Open <abbr title="/System/Library/LaunchDaemons/com.apple.mDNSResponder.plist">com.apple.mDNSResponder.plist</abbr>:

```bash
$ sudo vi /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
```

Add the following to line 18 of <abbr title="/System/Library/LaunchDaemons/com.apple.mDNSResponder.plist">com.apple.mDNSResponder.plist</abbr>:

```vim
<string>-AlwaysAppendSearchDomains</string>
```

Lines 16 through 19 should appear as follows:
```bash
<array>
  <string>/usr/sbin/mDNSResponder</string>
  <string>-AlwaysAppendSearchDomains</string>
</array>

```

Unload and reload the `mDNSResponder` launch daemon:

```bash
$ sudo launchctl unload /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
$ sudo launchctl load /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
```
 

In _System Preferences->Network_ select your decide connection click _Advanced_ select the _DNS_ table. Add both `172.20.1.26` & `172.20.1.1` to _DNS Server_ and add `gianose.mooo.com` to _Search Domains_.

### Test Clients

#### Forward Lookup

Using `nslookup` :

```bash
nslookup prime
```

Successful output:

```bash
Server:		172.20.1.26
Address:	172.20.1.26#53

prime.gianose.mooo.com	canonical name = primeserver.gianose.mooo.com.
Name:	primeserver.gianose.mooo.com
Address: 172.20.1.21
```

#### Reverse Lookup

Using `nslookup` :

```bash
nslookup 172.20.1.23
```

Successful output:

```bash
Server:		172.20.1.26
Address:	172.20.1.26#53

23.1.20.172.in-addr.arpa	name = vpnserver.gianose.mooo.com.
```

----
#### Renable SIP

1. Reboot.
2. Press Cmd+R to enter Recovery mode.
3. Open Utilities->Terminal.
4. Run the command csrutil enable.
5. Reboot.

----

### Resources

1. [How To Configure BIND as a Private Network DNS Server on CentOS 7](https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-centos-7)
2. [Zone Files](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/3/html/Reference_Guide/s1-bind-zone.html)
3. [Setting Up DNS Server On CentOS 7](http://www.unixmen.com/setting-dns-server-centos-7/)
4. [Configure an iptables firewall for BIND DNS servers on a local network](https://grockdoc.com/bind/9.9.5/articles/configure-an-iptables-firewall-for-bind-dns-servers-on-a-local-network-ubuntu_6d3aa7b9-03a0-4180-b072-a180f32fa76e/)
5. [Linux Iptables block or open DNS / bind service port 53](http://www.cyberciti.biz/tips/linux-iptables-12-how-to-block-or-open-dnsbind-service-port-53.html)
6. [Top 30 Nmap Command Examples For Sys/Network Admins](http://www.cyberciti.biz/networking/nmap-command-examples-tutorials/)