# Brand Indicators for Message Identification for UK Government

This repository provides the Terraform code and configuration files for the BIMI (Brand Indicators for Message Identification) pilot service. It is currently deployed and being tested on the **security.gov.uk** domain and with the GC3 (Government Cyber Coordination Centre), with the aim of rolling this out more broadly across the entire `gov.uk` domain in the future.

## Overview

BIMI is a security enhancement for email that allows brand-controlled logos to appear within supported email clients, helping recipients identify legitimate messages at a glance. This pilot is intended to demonstrate feasibility, measure impact, and ensure readiness for a wider rollout.

## Deployment

- **Initial Environment**: The BIMI pilot is initially deployed to security.gov.uk.
- **Wider Rollout**: Pending successful evaluation, configurations from this repository will support deploying BIMI for the `gov.uk` domains.

## Contents

- **Terraform Configuration**: Contains infrastructure-as-code definitions for deploying and managing BIMI services.
  - S3 for containing the assets such as SVG and PEM files
  - CloudFront for serving assets
  - CloudFront Functions for handling redirects and setting response headers

---

Supported by the Government Digital Service and the Securing Government Services team - <manage-bimi@digital.cabinet-office.gov.uk>.
