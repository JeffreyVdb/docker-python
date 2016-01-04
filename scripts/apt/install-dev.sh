#!/usr/bin/env bash

if [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
then
    echo "Installing build dependencies..."
    set -v \
        && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
        && apt-get update \
        && apt-get install -y ${buildDeps} --no-install-recommends
fi
