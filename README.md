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









