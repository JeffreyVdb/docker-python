#!/usr/bin/env bash
set -e

if [ $(id -u) -eq 0 ]; then
    su-exec "$USERNAME" test -w "$SRC_DIR" || chown -R -- "${UID}:${GID}" "$SRC_DIR"
    exec su-exec "$USERNAME" "$0" "$@"
fi

exec "$@"
