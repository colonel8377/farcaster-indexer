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

# Function to kill all Node.js processes started by start_process
kill_process() {
    if [ -n "$pids" ]; then
        echo "Killing Node.js process(es): $pids"
        for pid in $pids; do
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid"
                echo "Process $pid killed."
            else
                echo "Process $pid was already terminated."
            fi
        done
    else
        echo "No Node.js processes found."
    fi
}

# Function to check if each stored PID is running
check_process() {
    all_running=true
    for pid in $pids; do
        if ! kill -0 "$pid" 2>/dev/null; then
            echo "Process $pid is not running."
            all_running=false
        fi
    done

    if $all_running; then
        echo "All processes are running: $pids"
        return 0
    else
        echo "Some processes are not running."
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