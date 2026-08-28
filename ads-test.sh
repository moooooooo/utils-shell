#/bin/sh
# 
# this aidds type 65 DNS requests to the block list and is primarily used to help block iOS ads on my router


# iptables -I INPUT -p udp --dport 53 -d $(nvram get lan_ipaddr) -m comment --comment "DNS Type 65" -m string --hex-string "|0000410001|" --algo bm -j REJECT
iptables -I INPUT -p udp --dport 53 -d $(nvram get lan_ipaddr) -m string --hex-string "|0000410001|" --algo bm -j REJECT
# iptables -I FORWARD -p udp --dport 53 -m comment --comment "DNS Type 65" -m string --hex-string "|0000410001|" --algo bm -j REJECT
iptables -I FORWARD -p udp --dport 53 -m string --hex-string "|0000410001|" --algo bm -j REJECT
#
# to test, run:
iptables -nvL INPUT | grep 0000410001


