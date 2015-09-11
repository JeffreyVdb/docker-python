#!/bin/bash
set -e

# Define help message
show_help() {
    echo """
Usage: docker run <imagename> COMMAND

Commands

bash    : Start a bash shell
tox     : Run the Tox tests. Requires 'TOXFILEDIR' and tox to be installed
shell   : Start a Django Python shell. Requires 'APPDIR' and 'MANAGEFILE'
python  : Run a Python shell
help    : Show this message
"""
}

# Install build dependencies
install_build_deps(){
    if [ -f ${DEPLOYMENTDIR}/builddeps.txt ];
    then
        echo "Installing build dependencies..."
        set -e \
            && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
            && echo ${buildDeps} \
            && apt-get update \
            && apt-get install -y ${buildDeps}
    fi
}

# Uninstall build dependencies
uninstall_build_deps(){
    if [ -f ${DEPLOYMENTDIR}/builddeps.txt ];
    then
        echo "Uninstalling build dependencies..."
        set -e \
            && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
            && echo ${buildDeps} \
            && rm -rf /var/lib/apt/lists/* \
            && find /usr/local \
                \( -type d -a -name test -o -name tests \) \
                -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
                -exec rm -rf '{}' + \
            && apt-get purge -y --auto-remove ${buildDeps}
    fi
}

# Define manage.py name
if [ -z $MANAGEFILE ]; then
    export MANAGEFILE=manage.py
fi

# Run
case "$1" in
    bash)
        /bin/bash "${@:2}"
    ;;
    tox)
        trap uninstall_build_deps EXIT INT TERM

        install_build_deps

        echo "Running Tox Tests..."
        cd ${TOXFILEDIR} \
            && tox "${@:2}"

        trap - EXIT
        uninstall_build_deps
        exit 0
    ;;
    help)
        show_help
    ;;
    python)
        ptipython "${@:2}"
    ;;
    *)
        show_help
    ;;
esac
