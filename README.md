# Linux Firewall & Networking Lab

## Overview
This project sets up a multi-node isolated lab environment using LXD containers on Ubuntu to practice core Linux networking, stateful packet filtering, multi-zone network segmentation, advanced firewall hardening (`iptables`), NAT routing, and kernel security.

* **Author**: Frank Fru
* **Email**: chifru19@googlemail.com
* **Website**: [frankfru.com](https://frankfru.com)
* **GitHub**: [chifru19](https://github.com/chifru19)
* **LinkedIn**: [Frank Fru on LinkedIn](https://www.linkedin.com)

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

## The 8 Core Enterprise Functions

### Part 1: Foundational Baseline (Functions 1-4)
1. **Zero-Trust Default Policies**: Enforces strict `DROP` defaults on both `INPUT` and `FORWARD` chains.
2. **Stateful Inspection**: Seamlessly permits return traffic using connection tracking (`ESTABLISHED,RELATED`).
3. **Local Loopback Allowance**: Ensures secure inter-process communication on the `lo` interface.
4. **Kernel IP Forwarding**: Enables multi-node packet routing and gateway functionality.

### Part 2: Advanced Hardening, NAT & QoS (Functions 5-8)
5. **Invalid Packet Dropping**: Instantly discards malformed or corrupted packets (`--ctstate INVALID`) across the network stack.
6. **State-Table Exhaustion Protection**: Mitigates SYN-floods and resource starvation by limiting concurrent new TCP connections per source IP using `connlimit`.
7. **Rate-Limited Audit Logging (`LOG_DROP`)**: Routes dropped traffic through a custom logging chain capped at 5 packets/minute to prevent disk-exhaustion log floods.
8. **Multi-Zone Segmentation & DoS Mitigation**: 
   * **LAN -> WAN**: Permitted for general internet egress.
   * **WAN -> DMZ**: Permitted via DNAT port forwarding (Port 8080 -> 80) with `hashlimit` protection.
   * **DMZ -> LAN**: Explicitly dropped and logged to prevent lateral threat movement.
   * **Kernel Hardening**: Enabled strict Reverse-Path Filtering (`rp_filter=1`) to block IP spoofing and hardened SSH (port 22) against brute-force attacks.

---

## Repository Structure
```text
linux-firewall-lab/
├── README.md              # Detailed project documentation
├── script/
│   └── firewall-rules.sh  # Automated 8-function enterprise firewall provisioning script
└── .gitignore             # Excludes local configuration and cache files
---

## Alignment with Healthcare IT & Managed Services (e.g., Sonextis GmbH)
* **Multi-Zone Network Segmentation:** Just as clinical networks isolate sensitive electronic medical record (EMR/PACS) databases from public portals, this lab implements rigid multi-zone boundaries (LAN/DMZ/WAN) to block lateral threat movement.
* **Resilience & High Availability:** Protection against state-table exhaustion (`connlimit`) guarantees uptime and resource availability against sudden traffic spikes or denial-of-service attempts.
* **Perimeter Defense & Data Integrity:** Strict `iptables` policies, reverse-path filtering, and invalid packet filtering adhere to the rigorous data protection and compliance standards demanded in healthcare infrastructure.
