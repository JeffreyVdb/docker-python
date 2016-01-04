#!/usr/bin/env bash

if [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
then
    echo "Uninstalling build dependencies..."
    set -v \
        && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get purge -y --auto-remove ${buildDeps}
fi
