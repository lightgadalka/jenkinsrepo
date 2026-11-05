#!/bin/bash
set -e

echo "=== EC2 Health Check ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"

echo "--- Disk ---"
df -h /

echo "--- Memory ---"
free -h

echo "--- CPU Load ---"
cat /proc/loadavg

echo "Health check completed"
