#!/usr/bin/env bash

ARGS=("--dangerously-skip-permissions")

if [ "$1" = "-c" ] || [ "$1" = "--continue" ]; then
    ARGS+=("-c")
    shift
fi

if [ -n "$1" ]; then
    ARGS+=("$@")
fi

echo "Khởi động Claude Code ở chế độ bỏ qua quyền..."
claude "${ARGS[@]}"
