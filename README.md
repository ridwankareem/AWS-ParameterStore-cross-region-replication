# AWS SSM Parameter Replication

This script replicates AWS SSM parameters (e.g., URLs, secrets) from one region to another, supporting encrypted parameters. It only updates destination values when changes are detected.

## Usage

Run this command " chmod +x replicate-prod-params.sh " to apply permission.


Run script with this command " ./replicate-prod-params.sh "


## Requirements

- AWS CLI configured with sufficient permissions.
- `jq` installed for JSON parsing.

## How it works

- Scans all SSM parameters matching a prefix in the source region.
- Checks if the value is different in the destination region.
- Updates only changed parameters.
