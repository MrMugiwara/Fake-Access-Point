#!/bin/bash

echo "Killing Airbase-ng..."
pkill airbase-ng
sleep 2;
echo "Killing DHCP..."
pkill dhcpd3
sleep 5;

echo "Putting Wlan In Monitor Mode..."
airmon-ng stop wlan0 # Change to your wlan interface
sleep 5;
airmon-ng start wlan0 # Change to your wlan interface
sleep 5;
echo "Starting Fake AP..."
airbase-ng -e FreeWifi -c 11 -v wlan1 &amp; # Change essid, channel and interface
sleep 5;

ifconfig at0 up
ifconfig at0 10.0.0.254 netmask 255.255.255.0 # Change IP addresses as configured in your dhcpd.conf
route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.254

sleep 5;

iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE # Change eth3 to your internet facing interface

echo &gt; '/var/lib/dhcp3/dhcpd.leases'
ln -s /var/run/dhcp3-server/dhcpd.pid /var/run/dhcpd.pid
dhcpd3 -d -f -cf /etc/dhcp3/dhcpd.conf at0 &amp;

sleep 5;
echo "1" &gt; /proc/sys/net/ipv4/ip_forward
