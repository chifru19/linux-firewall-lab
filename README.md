# Linux Firewall & Networking Lab

## Overview
This project sets up a multi-node isolated lab environment using LXD containers on Ubuntu to practice core Linux networking, stateful packet filtering, advanced firewall hardening (`iptables`), NAT routing, and kernel security.

* **Author**: Frank Fru
* **Email**: chifru19@googlemail.com
* **Website**: [frankfru.com](https://frankfru.com)
* **GitHub**: [chifru19](https://github.com/chifru19)
* **LinkedIn**: [Frank Fru on LinkedIn](https://www.linkedin.com)

---

## Lab Architecture
* **Host Machine (`staffmachine`)**: Ubuntu host (`192.168.64.12`) acting as the hypervisor manager.
* **Firewall Node (`firewall-node`)**: Container acting as the network perimeter security gateway (`10.203.193.211`).
* **Server Node (`server-node`)**: Backend container simulating an internal application server (`10.203.193.56`).

---

## Implementation & Advanced Security Features

### 1. Environment Initialization & Connectivity
Provisioned lightweight LXD containers to bypass KVM restrictions on the host and validated internal container communication.

### 2. Custom Chain Architecture & Rate-Limited Auditing
A dedicated custom chain (`LOG_DROP`) handles dropped packets with rate-limiting (`-m limit --limit 5/min`) to prevent disk exhaustion.

### 3. DoS & Brute-Force Mitigation
Protected SSH (port 22) against brute-force attacks by restricting new connection rates.

### 4. Network Address Translation (NAT)
Configured Destination NAT (DNAT) for port forwarding and Source NAT (Masquerading) for egress traffic.

### 5. Kernel Hardening & Rule Persistence
Enabled IP forwarding, strict reverse-path filtering, and automated persistence via `iptables-persistent`.
