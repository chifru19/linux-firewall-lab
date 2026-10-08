#!/bin/bash
set -e

echo "[*] Applying Enterprise Firewall & Kernel Hardening Baseline..."

# 1. Enable IP Forwarding & Reverse-Path Filtering
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1

# 2. Flush existing rules and set Zero-Trust default policies
iptables -F
iptables -t nat -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 3. Stateful Inspection & Loopback Allowance
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# 4. Invalid Packet Protection
iptables -N LOG_DROP 2>/dev/null || true
iptables -F LOG_DROP
iptables -A LOG_DROP -m limit --limit 5/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
iptables -A LOG_DROP -j DROP

iptables -A INPUT -m conntrack --ctstate INVALID -j LOG_DROP

# 5. State-Table Exhaustion Protection (connlimit on port 8080)
iptables -A INPUT -p tcp --dport 8080 -m connlimit --connlimit-above 30 --connlimit-mask 32 -j LOG_DROP

# 6. Save Rules Permanently
netfilter-persistent save
echo "[+] Firewall rules and kernel hardening applied successfully."
