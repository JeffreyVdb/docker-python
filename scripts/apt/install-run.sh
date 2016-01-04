#!/usr/bin/env bash

if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ];
then
    echo "Installing run dependencies..."
    set -v \
        && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
        && apt-get update \
        && apt-get install -y ${deps} --no-install-recommends
fi
