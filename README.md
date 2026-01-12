# Tenable Vulnerability Scan of Azure Win11 Machines
Microsoft seems to have recently updated the VM images created in the Azure environment to automatically set up rules to block incoming traffic from Tenable Vulnerability Scanners. This script run from within the Win11 VM Powershell will enable Tenable Vulnerability Scanning.

## Setting up Virtual Machine

Created Azure Win11 VM following LogNPacific procedure in video Scanning Windows Authenticated vs. Unauthenticated and implementing powershell script in the notes to that resource.

## Setting up Tenable Scanner

DISASTIG scanning template created following LogNPacific procedure in DISASTIG Scan Template resource video. Credentialed scan created from that template to be run in tests

# Testing log

This is a record of the steps followed in testing, including part of powershell script executed, attempted scan, and whether or not scan ran. All scans are run through Tenable and are Windows11 DISASTIG scan type.

## Scan attempt with baseline settings of LogNPacific minus Firewall disablement

No access, scan did not execute effectively

## Scan attempt after enabling administrative shares

No access, scan did not execute effectively

## Enabling and starting windows services

No access, scan did not execute effectively

## Enabling Required Windows Firewall Groups

No access, scan did not execute effectively

## Explicitly allow SMB and RPC ports locally

Scan ran successfully and identified vulnerabilities, info items, and Audit items

## Try running scan with step 5 after setting up VM including script in notes from video Scanning Windows Authenticated vs. Unauthenticated

Scan ran successfully, meaning that step 5 is the only necessary step if script from video notes is run prior to this script

## Try running scan with step 5 after setting up VM WITHOUT running script in notes from video Scanning Windows Authenticated vs. Unauthenticated

Scan ran for a prolonged period of time, similar to a successful scan, however, no vulnerabilities or info items were returned

## Try running script with Step 2 (which does the same thing as the script from procedure video), and Step 5 Allow SMB and RPC ports locally

Scan ran with expected vulnerabilities successfully identified

# Conclusion

In order to run vulnerability scan in a microsoft Azure Windows11 VM from Tenable without disabling firewalls, certain baseline settings need to be modified.

While the original script provided by ChatGPT was more comprehenisive, testing revealed that only two of the 8 steps were necessary to successfully run vulnerability scans. 

In the interest of security, best practice would be to modify the least number of configurations possible to allow vulnerability scans and it was therefore determined that the final script should only include the following adjustments:

1. Disable UAC Remote Token Filtering
2. Explicitly allow SMB and RPC Ports Locally

Modifying these setting effectively allows for Tenable scanning of Azure Win11 Pro VM's without disabling firewalls






