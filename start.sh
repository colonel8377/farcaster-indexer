#!/bin/bash

# Flag file to check if backfill has already been completed
BACKFILL_FLAG="/tmp/backfill_done"

# Function to start the initial backfill if not already done
initial_backfill() {
    if [ ! -f "$BACKFILL_FLAG" ]; then
        echo "Starting initial backfill..."
        nohup yarn run backfill > backfill.log 2>&1 &

        # Wait for the backfill process to complete 
        while [ ! -f "$BACKFILL_FLAG" ]; do
            echo "Waiting for backfill to complete..."
            sleep 10  # Poll every 10 seconds
        done

        echo "Backfill completed successfully."
        start_streaming  # Start streaming 
    else
        echo "Backfill already completed. Proceeding to start streaming."
        start_streaming
    fi
}

# Function to start the streaming process
start_streaming() {
    nohup yarn start > streaming.log 2>&1 &
    sleep 10
    pids=$(pgrep -f node)
    if [ -n "$pids" ]; then
        echo "Streaming process started with PID(s): $pids"
    else
        echo "Failed to start the streaming process."
    fi
}

# Initial setup commands
yarn
yarn kysely:migrate

# Start the initial backfill or streaming based on the flag
initial_backfill

# Monitor the process and restart if necessary
while true; do
    sleep 60  # Check every 60 seconds
    if ! check_process; then
        echo "Restarting process..."
        kill_process
        start_streaming  # Only restart streaming after backfill has been completed
    fi
done
