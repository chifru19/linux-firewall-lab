#!/bin/bash
# Advanced Stateful Firewall Script with Custom Chains, Logging, DoS Mitigation, NAT, and Kernel Hardening

# Flush existing rules and delete custom chains
iptables -F
iptables -X
iptables -t nat -F
iptables -X -t nat

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 1. Kernel Hardening and IP Forwarding
# Enable IP Forwarding (Crucial for NAT/Routing)
sysctl -w net.ipv4.ip_forward=1
# Enforce strict Reverse-Path Filtering against IP spoofing on all interfaces
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1

# 2. Create a custom chain for logging and dropping
iptables -N LOG_DROP
iptables -A LOG_DROP -m limit --limit 5/min -j LOG --log-prefix "IPTables-Audit-Drop: " --log-level 4
iptables -A LOG_DROP -j DROP

# 3. Baseline Allow Rules on INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 4. DoS / Brute-Force Mitigation on SSH (Port 22)
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m limit --limit 3/min --limit-burst 5 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j LOG_DROP

# 5. FORWARD chain rules (Routing traffic between containers/networks)
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Forward HTTP traffic to backend server
iptables -A FORWARD -p tcp -d 10.203.193.56 --dport 80 -m conntrack --ctstate NEW -j ACCEPT

# 6. NAT Configuration (Port Forwarding & Masquerading)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.203.193.56:80

# 7. Send remaining unmatched traffic to LOG_DROP
iptables -A INPUT -j LOG_DROP
iptables -A FORWARD -j LOG_DROP

echo "Advanced firewall, NAT, and Kernel Hardening rules applied successfully!"
