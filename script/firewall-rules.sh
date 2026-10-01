#!/bin/bash
# Advanced Stateful Firewall Script for firewall-node

# Flush existing rules and reset counters
iptables -F
iptables -X

# Set default policies (Drop all inbound and forwarded traffic)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow established and related incoming connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Log dropped packets for auditing/skills showcase
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4

echo "Firewall rules applied successfully on firewall-node!"
