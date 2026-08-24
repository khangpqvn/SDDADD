#!/usr/bin/env bash

ARGS=("--dangerously-skip-permissions")

if [ "$1" == "-c" ] || [ "$1" == "--continue" ]; then
    ARGS+=("-c")
    shift
fi

if [ -n "$1" ]; then
    ARGS+=("$@")
fi

echo "Starting Claude Code with Skip Permissions mode..."
claude "${ARGS[@]}"
