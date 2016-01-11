#!/usr/bin/env bash

if [ -f ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE} ];
then
    echo "Uninstalling build dependencies..."
    set -v \
        && buildPackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE}` \
        && sudo yum remove -y ${buildPackages} \
        && sudo yum clean all
fi
