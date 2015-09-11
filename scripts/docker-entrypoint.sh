#!/usr/bin/env bash
set -e

# Include
source "${SCRIPTSDIR}/docker-python-commands.sh"

# Define help message
show_help() {
    echo """
Usage: docker run <imagename> COMMAND

Commands

bash        : Start a bash shell
tox         : Run the Tox tests. Requires 'TOXFILEDIR' and tox to be installed
python      : Run a classic python shell
ptpython    : Run a ptpython shell
help        : Show this message
"""
}


# Run
case "$1" in
    bash)
        run_bash "${@:2}"
    ;;
    tox)
        run_tox "${@:2}"
    ;;
    python)
        run_python "${@:2}"
    ;;
    ptpython)
        run_ptpython "${@:2}"
    ;;
    help)
        show_help
    ;;
    *)
        show_help
    ;;
esac
