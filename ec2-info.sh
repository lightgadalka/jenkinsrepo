#!/bin/bash
set -e

echo "=== EC2 Instance Information ==="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "Uptime: $(uptime -p)"
echo "Kernel: $(uname -r)"

TOKEN=$(curl -fsS --max-time 3 -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60" \
  http://169.254.169.254/latest/api/token) || TOKEN=""

if [ -n "$TOKEN" ]; then
    INSTANCE_ID=$(curl -fsS --max-time 3 \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id) || INSTANCE_ID="unknown"
else
    INSTANCE_ID="unknown"
fi

echo "Instance ID: $INSTANCE_ID"
