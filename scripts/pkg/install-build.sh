#!/usr/bin/env bash

if [ -f ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE} ];
then
    echo "Installing build dependencies..."
    set -x \
        && buildPackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE}` \
        && sudo yum install -y ${buildPackages}
fi
