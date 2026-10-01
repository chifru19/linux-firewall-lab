# Linux Firewall & Networking Lab

## Overview
This project sets up a multi-node isolated lab environment using LXD containers on Ubuntu to practice core Linux networking, stateful packet filtering, multi-zone network segmentation, advanced firewall hardening (`iptables`), NAT routing, and kernel security.

* **Author**: Frank Fru
* **Email**: chifru19@googlemail.com
* **Website**: [frankfru.com](https://frankfru.com)
* **GitHub**: [chifru19](https://github.com/chifru19)
* **LinkedIn**: [Frank Fru on LinkedIn](https://www.linkedin.com/in/frank-fru/)

---

## Lab Architecture & Multi-Zone Design
* **Host Machine (`staffmachine`)**: Ubuntu host (`192.168.64.12`) acting as the hypervisor manager.
* **Firewall Node (`firewall-node`)**: Perimeter security gateway (`10.203.193.211`) managing zone boundaries.
* **Server Node (`server-node`)**: Isolated backend/DMZ application server (`10.203.193.56`).

### Security Zones:
1. **LAN Zone (`10.203.193.0/24`)**: Trusted internal network with full egress rights.
2. **DMZ Zone (`10.203.193.56`)**: Public-facing application tier restricted from initiating traffic back into the LAN.
3. **WAN Zone**: External untrusted network mapped via NAT and port forwarding.

---

## Implementation & Advanced Security Features

### 1. Multi-Zone Zone-to-Zone Routing Rules
* **LAN $\rightarrow$ WAN**: Permitted for general internet egress.
* **WAN $\rightarrow$ DMZ**: Permitted via DNAT port forwarding (Port 8080 $\rightarrow$ 80).
* **DMZ $\rightarrow$ LAN**: Explicitly dropped and logged to prevent lateral threat movement.

### 2. Custom Chain Architecture & Rate-Limited Auditing
A dedicated custom chain (`LOG_DROP`) handles dropped packets with rate-limiting (`-m limit --limit 5/min`) to prevent system log disk-exhaustion attacks.

### 3. DoS & Brute-Force Mitigation
Protected administrative interfaces (SSH on port 22) from brute-force password attacks by restricting new connection rates (`-m limit --limit 3/min --limit-burst 5`).

### 4. Kernel Hardening & Rule Persistence
* Enabled IP forwarding (`net.ipv4.ip_forward=1`) and strict Reverse-Path Filtering (`net.ipv4.conf.all.rp_filter=1`) to block IP spoofing.
* Automated persistence via `iptables-persistent`.

---

## Repository Structure
```text
linux-firewall-lab/
├── README.md              # Detailed project documentation
├── script/
│   └── firewall-rules.sh  # Automated multi-zone firewall provisioning script
└── .gitignore             # Excludes local configuration and cache files
```
