#!/usr/bin/env bash
dest=$1
dport=$2
via=$3
vport=$4
sudo iptables -t nat -A OUTPUT -p tcp \
  -d $dest --dport $dport -j DNAT --to-destination 127.0.0.1:$vport
sudo iptables -t nat -I OUTPUT -p tcp \
  -d $via --dport $dport -j DNAT --to-destination $dest:$dport
