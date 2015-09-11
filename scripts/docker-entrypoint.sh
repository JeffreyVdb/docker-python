#!/bin/bash
set -e

# Include
source "${SCRIPTSDIR}/docker-python-commands.sh"

# Define help message
show_help() {
    echo """
Usage: docker run <imagename> COMMAND

Commands

bash    : Start a bash shell
tox     : Run the Tox tests. Requires 'TOXFILEDIR' and tox to be installed
python  : Run a Python shell
help    : Show this message
"""
}


# Run
case "$1" in
    bash)
        run_bash
    ;;
    tox)
        run_tox
    ;;
    python)
        run_python
    ;;
    help)
        show_help
    ;;
    *)
        show_help
    ;;
esac
