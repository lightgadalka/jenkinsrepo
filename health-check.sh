#!/bin/bash

echo "=== Health Check ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"

echo "--- Disk ---"
df -h /

echo "--- Memory ---"
free -h

echo "--- CPU load ---"
cat /proc/loadavg

echo "Health check completed"
