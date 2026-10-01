# Linux Firewall & Networking Lab

## Overview
This project sets up a multi-node isolated lab environment using LXD containers on Ubuntu to practice core Linux networking, stateful packet filtering, and firewall hardening (`iptables`).

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

## Step-by-Step Implementation

### 1. Environment Initialization
Provisioned lightweight LXD containers to bypass KVM restrictions on the host:
```bash
sudo lxd init --auto
lxc launch ubuntu:24.04 firewall-node
lxc launch ubuntu:24.04 server-node
```

### 2. Connectivity Validation
Verified network communication between containers:
```bash
lxc exec firewall-node -- ping -c 3 10.203.193.56
```

### 3. Firewall Hardening (`iptables`)
Implemented a secure baseline stateful firewall policy on `firewall-node`:

* Set default drop policies for incoming and forwarded traffic:
  ```bash
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT ACCEPT
  ```
* Allowed established and related connections to maintain return traffic:
  ```bash
  iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  ```
* Allowed internal loopback traffic:
  ```bash
  iptables -A INPUT -i lo -j ACCEPT
  ```
