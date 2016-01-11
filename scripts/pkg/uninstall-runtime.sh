#!/usr/bin/env bash

if [ -f ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE} ];
then
    echo "Uninstalling runtime dependencies..."
    set -v \
        && runtimePackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE}` \
        && sudo yum remove -y ${runtimePackages} \
        && sudo yum clean all
fi
