#!/usr/bin/env python3
"""
Interview Preparation Tool for Sonextis GmbH
Target Project: Linux Firewall & Networking Lab
Author: Frank Fru
"""

import argparse

def main():
    parser = argparse.ArgumentParser(description="Prepare for IT interviews with tailored project alignments.")
    parser.add_argument("--target", required=True, help="Target company name")
    parser.add_argument("--project", required=True, help="Featured project name")
    args = parser.parse_args()

    print(f"[*] Initializing interview prep for target: {args.target}")
    print(f"[*] Loading technical profile: {args.project}")
    print("\n" + "="*40)
    print("KEY HEALTHCARE IT ALIGNMENT POINTS:")
    print("="*40)
    print("1. Zero-Trust & Stateful Filtering -> Healthcare Compliance & Data Integrity")
    print("2. Multi-Zone Segmentation (LAN/DMZ) -> Preventing Lateral Threat Movement / Ransomware Protection")
    print("3. Rate-Limiting & DoS Mitigation -> 24/7 Operational Uptime for Clinics & MVZ")
    print("\n[+] Preparation profile successfully configured for Sonextis GmbH in Donauwörth!\n")

if __name__ == "__main__":
    main()
