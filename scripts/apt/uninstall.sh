#!/usr/bin/env bash

if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ] || [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
then
    echo "Uninstalling dependencies..."
    set -v \
        && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
        && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get purge -y --auto-remove ${deps} ${buildDeps}
fi
