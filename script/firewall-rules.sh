#!/bin/bash
# Advanced Stateful Firewall Script with Custom Chains, Logging, and DoS Mitigation

# Flush existing rules and delete custom chains
iptables -F
iptables -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 1. Create a custom chain for logging and dropping
iptables -N LOG_DROP

# Rules inside the custom chain:
iptables -A LOG_DROP -m limit --limit 5/min -j LOG --log-prefix "IPTables-Audit-Drop: " --log-level 4
iptables -A LOG_DROP -j DROP

# 2. Baseline Allow Rules on INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3. DoS / Brute-Force Mitigation on SSH (Port 22)
# Allow new SSH connections only if they don't exceed 3 per minute (burst of 5), otherwise send to LOG_DROP
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m limit --limit 3/min --limit-burst 5 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j LOG_DROP

# 4. Send remaining unmatched inbound traffic to our custom LOG_DROP chain
iptables -A INPUT -j LOG_DROP

echo "Firewall rules with DoS mitigation applied successfully!"
