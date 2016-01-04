#!/usr/bin/env bash

if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ];
then
    echo "Uninstalling run dependencies..."
    set -v \
        && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get purge -y --auto-remove ${deps}
fi
