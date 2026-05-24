#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo: sudo ./run.sh"
  exit 1
fi

echo "Starting environment setup..."

if [ -f "requirements.txt" ]; then
    pip3 install --no-cache-dir -r requirements.txt --break-system-packages
else
    echo "Warning: requirements.txt not found."
fi

docker compose down &> /dev/null
docker compose up -d

sleep 5

cleanup() {
    echo "Shutting down services..."
    docker compose down
    mn -c &> /dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

echo "Launching Mininet Topology..."
echo "Grafana Dashboard is available at: http://localhost:3000"

# The Master Pipe: Connects the topology output directly to the Prometheus handler!
python3 topo.py | /home/acer/r1_mac_env/bin/python3 store_redis.py