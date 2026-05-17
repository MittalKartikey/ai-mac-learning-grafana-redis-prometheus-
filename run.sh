#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo: sudo ./run.sh"
  exit 1
fi

echo "Starting environment setup..."

if [ -f "requirements.txt" ]; then
    pip3 install --no-cache-dir -r requirements.txt
else
    echo "Warning: requirements.txt not found."
fi

docker compose down &> /dev/null
docker compose up -d

sleep 5

python3 store_redis.py > store_redis.log 2>&1 &
INGEST_PID=$!

cleanup() {
    echo "Shutting down services..."
    kill $INGEST_PID 2>/dev/null
    docker compose down
    mn -c &> /dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

echo "Launching Mininet Topology..."
echo "Grafana Dashboard is available at: http://localhost:3000"

python3 topo.py