#!/bin/bash
# Enterprise Multi-Zone Stateful Firewall Script (LAN, DMZ, WAN)
# Designed for Linux LXD Lab & Enterprise Interview Demonstration

# 1. Flush existing rules and delete custom chains
iptables -F
iptables -X
iptables -t nat -F
iptables -X -t nat

# 2. Set default strict drop policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 3. Kernel Hardening & IP Forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1

# 4. Create custom audit and logging chain
iptables -N LOG_DROP
iptables -A LOG_DROP -m limit --limit 5/min -j LOG --log-prefix "Zone-Audit-Drop: " --log-level 4
iptables -A LOG_DROP -j DROP

# 5. INPUT Chain Baselines
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# DoS Mitigation on Administrative Access (SSH Port 22)
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m limit --limit 3/min --limit-burst 5 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j LOG_DROP

# 6. FORWARD Chain: Multi-Zone Inter-VLAN / Zone-to-Zone Routing Logic
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Zone 1: LAN to WAN (Allow internal trusted network out to internet)
iptables -A FORWARD -s 10.203.193.0/24 -o eth0 -j ACCEPT

# Zone 2: LAN to DMZ (Allow internal administration/updates to DMZ server)
iptables -A FORWARD -s 10.203.193.0/24 -d 10.203.193.56 -j ACCEPT

# Zone 3: WAN to DMZ (Allow public port forwarding into the web application server)
iptables -A FORWARD -p tcp -d 10.203.193.56 --dport 80 -m conntrack --ctstate NEW -j ACCEPT

# Explicitly Block DMZ to LAN (Prevent lateral movement from compromised web server)
iptables -A FORWARD -s 10.203.193.56 -d 10.203.193.0/24 -j LOG_DROP

# 7. NAT Configuration (Port Forwarding & Masquerading)
# Source NAT / Masquerading for external egress
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# Destination NAT (DNAT) mapping external port 8080 to DMZ server port 80
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 10.203.193.56:80

# 8. Unmatched Traffic Fallback to LOG_DROP
iptables -A INPUT -j LOG_DROP
iptables -A FORWARD -j LOG_DROP

echo "Multi-Zone Enterprise Firewall and Routing rules applied successfully!"
