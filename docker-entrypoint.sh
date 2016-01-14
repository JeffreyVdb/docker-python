#!/usr/bin/env bash
set -e

chown -R ${UID}:${GID} ${SRC_DIR}
exec gosu ${USERNAME} "$@"
