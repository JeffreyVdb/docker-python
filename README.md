# Docker Python Stack

Base image for creating a Docker image running a Python application

This builds multiple versions of the image that are tagged based on the Python
version used.

## Usage

This image is mainly used to simplify a number of tasks that are common across
Python projects:
 - Wrapper for various commonly called commands
 - Testing with tox

To start using the image, just inherit from it in your project's Dockerfile:

    FROM vikingco/python:3.4

This will give you `python`, `pip` `ipython`, `ptpython` and `git-core`.
Everything else you will need to install yourself by adding extra `RUN`
commands to your project's Dockerfile.

You will probably still need the following lines

    COPY deployment/requirements.txt ${DEPLOYMENTDIR}/requirements.txt
    RUN pip install -r ${DEPLOYMENTDIR}/requirements.txt
    COPY . ${SRCDIR}


### docker-entrypoint.sh

This is the main entrypoint of the image. It is built to comply with the [best
practices](https://docs.docker.com/articles/dockerfile_best-practices/#entrypoint).
`docker-entrypoint.sh` takes a command as argument, which are listed below. Some of them are configurable by environment variables.

#### bash
Starts a bash shell

#### tox
Runs tox tests

Env variable | Required | Description
--- | --- | ---
TOXFILEDIR | No | Specify name of directory where the `tox.ini` file exists if it differs from `./`

##### advanced topics

*   build dependencies:

    Since running tox will create new virtual environments, in most cases it is required to have additional system
    packages available. A straightforward example would be `libpg-dev` which is required if you are installing psycopg2.

    Those 'build dependencies' can be provided via the `builddeps.txt` file, that can be added in the `deployment`
    directory.

    **WARNING: These build dependencies will be installed before running tox, and uninstalled afterwards. Make sure that
    your application does not depend on these build dependencies directly!**

    Env variable | Required | Description
    --- | --- | ---
    BUILDDEPSFILE | No | Provide name of `builddeps.txt` if it differs from `builddeps.txt`

#### python
Start a classic Python shell

#### ptpython
Start a PTPython shell

#### help
Show a help message
