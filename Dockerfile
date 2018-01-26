FROM gcc:7
LABEL maintainer="technology@unleashed.be"

ARG SU_EXEC_VERSION=v0.2

WORKDIR /tmp/
RUN set -xe \
    && git clone --branch=${SU_EXEC_VERSION} --depth=1 https://github.com/ncopa/su-exec \
    && cd su-exec \
    && make

FROM centos:7.4.1708
LABEL maintainer="technology@unleashed.be"

######################
# Define root folder #
######################
ENV ROOT=/data

####################################
# Setup python versions to install #
####################################
ARG PYTHON_VERSIONS=2.7.5

##################################
# Define global environment vars #
##################################
ENV PYTHONUNBUFFERED=1 \
    SRC_DIR=${ROOT}/src \
    CONF_SRC=./conf \
    CONF_DIR=${ROOT}/conf \
    DEPLOYMENT_SRC=./deployment \
    DEPLOYMENT_DIR=${ROOT}/deployment \
    SCRIPTS_SRC=./scripts \
    SCRIPTS_DIR=${ROOT}/scripts \
    REQUIRED_BUILD_PACKAGES_FILE=os/required_build_packages.txt \
    REQUIRED_RUNTIME_PACKAGES_FILE=os/required_runtime_packages.txt  \
    PYTHON_REQUIREMENTS_FILE=python/requirements.txt \
    PYENV_ROOT=${ROOT}/.pyenv

###############
# Define PATH #
###############
ENV PATH ${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:$PATH

######################
# Setup default user #
######################
ARG UID=1000
ARG GID=1000
ARG USERNAME=python
ARG GROUPNAME=python

# Add user
RUN set -xe \
    && groupadd -r -g ${GID} ${GROUPNAME} \
    && useradd -r -m -d ${ROOT} -u ${UID} -g ${GROUPNAME} -s /bin/bash ${USERNAME}

ENV UID=${UID} \
    GID=${GID} \
    USERNAME=${USERNAME} \
    GROUPNAME=${GROUPNAME}

#############################################
# Grab su-exec for easy step-down from root #
#############################################
COPY --from=0 /tmp/su-exec/su-exec /sbin/su-exec

##############################
# Copy deployment into image #
##############################
COPY ${DEPLOYMENT_SRC} ${DEPLOYMENT_DIR}

#################
# Install pyenv #
#################
RUN set -x \
    && buildPackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_BUILD_PACKAGES_FILE}` \
    && runtimePackages=`cat ${DEPLOYMENT_DIR}/${REQUIRED_RUNTIME_PACKAGES_FILE}` \
    && yum -y makecache \
    && yum install -y ${runtimePackages} ${buildPackages} patch wget tar bzip2 make \
    && wget https://github.com/yyuu/pyenv/tarball/master -O /tmp/pyenv.tar.gz \
    && mkdir -p ${PYENV_ROOT} && chown -R ${UID}:${GID} ${PYENV_ROOT} \
    && su-exec ${USERNAME} tar xvf /tmp/pyenv.tar.gz -C ${PYENV_ROOT} --strip 1 \
    && rm -rf /tmp/pyenv.tar.gz \
    && cd ${ROOT} \
    && for pyversion in ${PYTHON_VERSIONS}; \
        do \
            su-exec ${USERNAME} pyenv install ${pyversion} \
            && su-exec ${USERNAME} pyenv local ${pyversion} \
            && su-exec ${USERNAME} pip install -r ${DEPLOYMENT_DIR}/${PYTHON_REQUIREMENTS_FILE}; \
        done \
    && su-exec ${USERNAME} pyenv global ${PYTHON_VERSIONS} \
    && find ${PYENV_ROOT} \
		\( \( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \) \
		-prune -exec rm -rf {} + \
    && rm -rf /tmp/* \
    && yum remove -y ${buildPackages} -- -systemd \
    && yum clean all

###########################
# Create source directory #
###########################
RUN mkdir -p ${SRC_DIR}

###########################
# Copy scripts into image #
###########################
COPY ${SCRIPTS_SRC} ${SCRIPTS_DIR}

##############################
# Copy entrypoint into image #
##############################
COPY docker-entrypoint.sh /entrypoint.sh
COPY runscript.py /usr/bin/runscript

#######################
# Set default workdir #
#######################
WORKDIR ${SRC_DIR}

###################
# Set run command #
###################
ENTRYPOINT ["/entrypoint.sh", "/usr/bin/runscript"]
CMD ["help"]
