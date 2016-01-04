#!/usr/bin/env bash

if [ -f ${DEPLOYMENTDIR}/${DEPSFILE} ] || [ -f ${DEPLOYMENTDIR}/${BUILDDEPSFILE} ];
then
    echo "Installing dependencies..."
    set -v \
        && deps=`cat ${DEPLOYMENTDIR}/${DEPSFILE}` \
        && buildDeps=`cat ${DEPLOYMENTDIR}/${BUILDDEPSFILE}` \
        && apt-get update \
        && apt-get install -y ${deps} ${buildDeps} --no-install-recommends
fi
