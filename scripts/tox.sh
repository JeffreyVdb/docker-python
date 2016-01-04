#!/usr/bin/env bash

if [ -f ${TOXFILEDIR}/tox.ini ];
then
    trap ./docker-entrypoint.py apt uninstall-dev EXIT INT TERM

    ./docker-entrypoint.py apt install-dev

    echo "Running Tox Tests..."
    cd ${TOXFILEDIR} \
        && tox "$@"

    trap - EXIT
    ./docker-entrypoint.py apt uninstall-dev
    exit 0
else
    echo "ERROR: toxini file 'tox.ini' not found"
    exit 1
fi
