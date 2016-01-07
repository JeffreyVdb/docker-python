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

######################
# Setup default user #
######################
ARG UID=1000
ARG GID=1000
ARG USERNAME=python
RUN set -e \
    && yum install -y sudo \
	&& yum clean all \
    && echo "Defaults:${USERNAME}    !env_reset" >> /etc/sudoers \
    && echo "Defaults:${USERNAME}    !requiretty" >> /etc/sudoers \
    && echo "${USERNAME}    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers \
    && groupadd -g ${GID} ${USERNAME} \
    && useradd -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
    && mkdir -p ${ROOT} \
    && chown -R ${UID}:${GID} ${ROOT}
USER ${USERNAME}

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
    && pythonRequirements=`cat ${DEPLOYMENT_DIR}/${PYTHON_REQUIREMENTS_FILE}` \
    && sudo yum install -y ${runtimePackages} ${buildPackages} \
    && wget https://github.com/yyuu/pyenv/tarball/master -O /tmp/pyenv.tar.gz \
    && mkdir -p ${PYENV_ROOT} \
    && tar xvf /tmp/pyenv.tar.gz -C ${PYENV_ROOT} --strip 1 \
    && rm -rf /tmp/pyenv.tar.gz \
    && sudo touch ./.python-version && sudo chown ${UID}:${GID} ./.python-version \
    && for pyversion in ${PYTHON_VERSIONS}; \
        do \
            pyenv install ${pyversion} \
            && pyenv local ${pyversion} \
            && pip install ${pythonRequirements}; \
        done \
    && pyenv global ${PYTHON_VERSIONS} \
    && find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' + \
    && sudo rm -rf /tmp/* \
	&& sudo yum remove -y ${buildPackages} \
	&& sudo yum clean all

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
COPY docker-entrypoint.py /usr/local/bin/runscript

#######################
# Set default workdir #
#######################
WORKDIR ${SRC_DIR}

###################
# Set run command #
###################
ENTRYPOINT ["runscript"]
CMD ["help"]
