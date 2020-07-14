#!/bin/bash
# A script to prepare the source Machine for Data Transfer 
# Data in <...> needs to be changed according to use case

export PATH=/usr/local/etc:/sbin:/usr/sbin:/etc:/usr/etc:/usr/etc/yp:/usr/local/bin:/bin:/usr/bin:/usr/bin/X11:/root/bin

NAME=$(nmcli c s | grep -v "eno1" | tail -n 1 | awk '{ print $1}')
UUID=$(nmcli c s | grep -v "eno1" | tail -n 1 | awk '{ print $2}')

echo $(date) "SOURCE-BOOT (Data Transfer Source), $NAME 192.168.1.2" >> < /scratch/startup.log >

mv /etc/sysconfig/network-scripts/ifcfg-$NAME /etc/sysconfig/network-scripts/ifcfg-$NAME.org

echo TYPE="Ethernet" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo PROXY_METHOD="none" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo BROWSER_ONLY="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo BOOTPROTO="none" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo IPADDR="192.168.1.2" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo PREFIX="24" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo IPV4_FAILURE_FATAL="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo IPV6INIT="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo IPV6_AUTOCONF="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo IPV6_DEFROUTE=no="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo IPV6_FAILURE_FATAL="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo IPV6_ADDR_GEN_MODE="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo NAME=$NAME >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo UUID=$UUID >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo DEVICE="$NAME" >> /etc/sysconfig/network-scripts/ifcfg-$NAME
echo ONBOOT="yes" >> /etc/sysconfig/network-scripts/ifcfg-$NAME


/sbin/ifdown $NAME; /sbin/ifup $NAME

systemctl start nfs 

rm -f /etc/exports

# One Folder to be exported 
echo -e "</PATH> @trust 192.168.1.1(rw,sync,subtree_check,no_root_squash)" > /etc/exports
# Multiple Folders
for folder in $(df -h | grep "</net/$(hostname)/fs.>" | grep -o '...$')
do
        echo -e "</net/$(hostname)/$folder> @trust 192.168.1.1(rw,sync,subtree_check,no_root_squash)" >> /etc/exports
done

/usr/sbin/exportfs -rv

echo $(date) "The Workstation is prepared for File Transfer" >> </scratch/startup.log>
echo -e "File Transfer ready on the old $(hostname) Machine \\n $(df -h | grep "</net/$(hostname)/fs>")" | mail -s "File Transfer Source" <e-mail>
