#!/usr/bin/env bash

if [ -f ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE} ];
then
    echo "Installing runtime dependencies..."
    set -x \
        && runtimePackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE}` \
        && sudo yum install -y ${runtimePackages}
fi
