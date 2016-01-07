#!/usr/bin/env bash

if [ -f ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE} ] || \
   [ -f ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE} ];
then
    echo "Installing dependencies..."
    set -x \
        && buildPackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE}` \
        && runtimePackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE}` \
        && sudo yum install -y ${runtimePackages} ${buildPackages}
fi
