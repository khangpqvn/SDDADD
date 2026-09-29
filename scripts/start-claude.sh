#!/usr/bin/env bash

ARGS=()

if [ "$1" = "--dangerously-skip-permissions" ]; then
    ARGS+=("$1")
    shift
    echo "CẢNH BÁO: đang khởi động Claude Code với quyền bị bỏ qua theo lựa chọn explicit."
fi

if [ "$1" = "-c" ] || [ "$1" = "--continue" ]; then
    ARGS+=("-c")
    shift
fi

if [ -n "$1" ]; then
    ARGS+=("$@")
fi

if [ "${#ARGS[@]}" -eq 0 ] || [ "${ARGS[0]}" != "--dangerously-skip-permissions" ]; then
    echo "Khởi động Claude Code với permission mode mặc định."
fi
claude "${ARGS[@]}"
