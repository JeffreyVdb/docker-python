#!/usr/bin/env bash

# Include
source "./docker-dependencies-commands.sh"

# Run make
run_make(){
    make "$@"
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
    python "$@"
}

# Run ptpython
run_ptpython(){
    ptipython "$@"
}
