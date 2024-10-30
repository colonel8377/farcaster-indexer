#!/bin/bash

# Function to start the process
start_process() {
    nohup yarn run backfill > backfill.log 2>&1 &
    sleep 10
    pids=$(pgrep -f node)
    if [ -n "$pids" ]; then
        echo "Process started with PID(s): $pids"
    else
        echo "Failed to start the process."
    fi
}

# Function to kill the Node.js processes
kill_process() {
    if [ -n "$pids" ]; then
        echo "Killing Node.js process(es): $pids"
        for pid in $pids; do
            kill -9 "$pid" 2>/dev/null
            echo "Process $pid killed."
        done
    else
        echo "No Node.js processes found."
    fi
}

# Function to check if any Node.js process is running
check_process() {
    if [ -n "$pids" ] && pgrep -f node > /dev/null; then
        echo "Process(es) running: $pids"
        return 0
    else
        echo "No processes are running."
        return 1
    fi
}

# Initial setup commands
yarn
yarn kysely:migrate

# Start the process initially
start_process

# Monitor the process
while true; do
    sleep 60  # Check every 60 seconds
    if ! check_process; then
        echo "Restarting process..."
        kill_process
        start_process
    fi
done