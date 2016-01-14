FROM centos:7.2.1511
MAINTAINER technology@vikingco.com

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
RUN set -e \
    && yum install -y sudo \
	&& yum clean all \
    && echo "Defaults:${USERNAME}    !env_reset" >> /etc/sudoers \
    && echo "Defaults:${USERNAME}    !requiretty" >> /etc/sudoers \
    && echo "Defaults:${USERNAME}    secure_path=\"$PATH\"" >> /etc/sudoers \
    && echo "${USERNAME}    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers \
    && groupadd -r -g ${GID} ${GROUPNAME} \
    && useradd -r -m -d ${ROOT} -u ${UID} -g ${GROUPNAME} -s /bin/bash ${USERNAME}
ENV UID=${UID} \
    GID=${GID} \
    USERNAME=${USERNAME} \
    GROUPNAME=${GROUPNAME}

##########################################
# Grab gosu for easy step-down from root #
##########################################
ARG ARCHITECTURE=amd64
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-${ARCHITECTURE}" \
	&& curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-${ARCHITECTURE}.asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

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
    && yum install -y ${runtimePackages} ${buildPackages} \
    && wget https://github.com/yyuu/pyenv/tarball/master -O /tmp/pyenv.tar.gz \
    && mkdir -p ${PYENV_ROOT} \
    && tar xvf /tmp/pyenv.tar.gz -C ${PYENV_ROOT} --strip 1 \
    && rm -rf /tmp/pyenv.tar.gz \
    && for pyversion in ${PYTHON_VERSIONS}; \
        do \
            pyenv install ${pyversion} \
            && pyenv local ${pyversion} \
            && pip install -r ${DEPLOYMENT_DIR}/${PYTHON_REQUIREMENTS_FILE}; \
        done \
    && pyenv global ${PYTHON_VERSIONS} \
    && find ${PYENV_ROOT} \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' + \
    && rm -rf /tmp/* \
    && yum remove -y ${buildPackages} \
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
ENTRYPOINT ["/entrypoint.sh", "runscript"]
CMD ["help"]
