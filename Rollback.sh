#!/bin/bash

# Run kubectl wait command with a timeout of 600 seconds
kubectl wait --for=condition=ready pods --timeout=600s &

# Capture the PID of the kubectl wait command
wait_pid=$!

# Wait for the kubectl wait command to complete or timeout
timeout=600
interval=10  # Check status every 10 seconds
while [ $timeout -gt 0 ]; do
    if ! ps -p $wait_pid > /dev/null; then
        # If kubectl wait completed before the timeout, break the loop
        break
    fi
    ((timeout -= interval))
    sleep $interval
done

if [ $timeout -le 0 ]; then
    # If the loop finished without breaking, it means kubectl wait timed out
    echo "Error: Timeout occurred while waiting for pods to be ready"
    # Add timeout handling actions here
    kill $wait_pid >/dev/null 2>&1 # Kill the kubectl wait command
else
    # If kubectl wait completed before the timeout, check its exit code
    wait $wait_pid
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "Pods are ready"
        # Add your further actions here
    else
        echo "Error: Pods are not ready, kubectl wait exited with code $exit_code"
        # Add error handling actions here
    fi
fi
