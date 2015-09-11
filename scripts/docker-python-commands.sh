#!/usr/bin/env bash

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

# Run bash
run_bash(){
    /usr/bin/env bash "$@"
}

# Run tox
run_tox(){
    if [ -f ${TOXFILEDIR}/tox.ini ];
    then
        trap uninstall_build_deps EXIT INT TERM

        install_build_deps

        echo "Running Tox Tests..."
        cd ${TOXFILEDIR} \
            && tox "$@"

        trap - EXIT
        uninstall_build_deps
        exit 0
    else
        echo "Could not find tox.ini!"
        exit 1
    fi
}

# Run python
run_python(){
    ptipython "$@"
}
