#!/usr/bin/env bash

if [ -f ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE} ] || \
   [ -f ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE} ];
then
    echo "Uninstalling dependencies..."
    set -v \
        && buildPackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE}` \
        && runtimePackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE}` \
        && sudo yum remove -y ${runtimePackages} ${buildPackages} \
        && sudo yum clean all
fi
