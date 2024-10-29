#!/bin/bash

# Function to start the process
start_process() {
    nohup yarn run backfill > backfill.log 2>&1 &
    PID=$!
    echo "Process started with PID: $PID"
}

# Function to check if the process is running
check_process() {
    if ps -p $PID > /dev/null; then
        echo "Process is running."
        return 0
    else
        echo "Process is not running."
        return 1
    fi
}
yarn
yarn kysely:migrate
# Start the process initially
start_process

# Monitor the process
while true; do
    sleep 60  # Check every 60 seconds
    if ! check_process; then
        echo "Restarting process..."
        start_process
    fi
done