#!/usr/bin/env bash

# Install all dependencies
install_deps(){
    if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ] || [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
    then
        echo "Installing dependencies..."
        set -v \
            && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
            && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
            && apt-get update \
            && apt-get install -y ${deps} ${buildDeps} --no-install-recommends
    fi
}

# Install build dependencies
install_run_deps(){
    if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ];
    then
        echo "Installing run dependencies..."
        set -v \
            && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
            && apt-get update \
            && apt-get install -y ${deps} --no-install-recommends
    fi
}

# Install build dependencies
install_build_deps(){
    if [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
    then
        echo "Installing build dependencies..."
        set -v \
            && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
            && apt-get update \
            && apt-get install -y ${buildDeps} --no-install-recommends
    fi
}

# Uninstall all dependencies
uninstall_deps(){
    if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ] || [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
    then
        echo "Uninstalling dependencies..."
        set -v \
            && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
            && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
            && rm -rf /var/lib/apt/lists/* \
            && apt-get purge -y --auto-remove ${deps} ${buildDeps}
    fi
}

# Uninstall run dependencies
uninstall_run_deps(){
    if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ];
    then
        echo "Uninstalling run dependencies..."
        set -v \
            && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
            && rm -rf /var/lib/apt/lists/* \
            && apt-get purge -y --auto-remove ${deps}
    fi
}

# Uninstall build dependencies
uninstall_build_deps(){
    if [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
    then
        echo "Uninstalling build dependencies..."
        set -v \
            && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
            && rm -rf /var/lib/apt/lists/* \
            && apt-get purge -y --auto-remove ${buildDeps}
    fi
}

# Dependencies help
deps_show_help() {
    echo """
Usage: docker run <imagename> apt COMMAND

Commands

install         : Install all dependencies
uninstall       : Uninstall all dependencies
install-run     : Install run dependencies
uninstall-run   : Uninstall run dependencies
install-dev     : Install dev dependencies
uninstall-dev   : Uninstall dev dependencies
help            : Show this message
"""
}

# Dependencies entrypoint
deps(){
    case "$1" in
        install)
            install_deps
        ;;
        uninstall)
            uninstall_deps
        ;;
        install-run)
            install_run_deps
        ;;
        uninstall-run)
            uninstall_run_deps
        ;;
        install-dev)
            install_build_deps
        ;;
        uninstall-dev)
            uninstall_build_deps
        ;;
        help)
            deps_show_help
        ;;
        *)
            deps_show_help
        ;;
    esac
}
