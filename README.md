# Docker Python Stack

Base image for creating a Docker image running a Python application

This builds multiple versions of the image that are tagged based on the Python
version used.


## Building
This image uses [pyenv](https://github.com/yyuu/pyenv) to be able to install specific python versions into the container.

### Single python version
This will install a single python version as the main python version.

Usage:
```bash
export PYVERSION="2.7.5"
docker build -t vikingco/python:${PYVERSION} \
    --build-arg PYTHON_VERSIONS=${PYVERSION} \
    .
```

### Multiple python versions
This will install multiple python versions and allows the user to switch using pyenv commands (e.g. pyenv local 2.7.10).

Usage:
```bash
export PYVERSIONS="2.7.5 2.7.10"
docker build -t vikingco/python:multiple \
    --build-arg PYTHON_VERSIONS=${PYVERSIONS} \
    .
```


## Using as base image

This image is mainly used to simplify a number of tasks that are common across
Python projects:
 - Wrapper for various commonly called commands

To start using the image, just inherit from it in your project's Dockerfile:

    FROM vikingco/python:2.7.5

This will give you `python`, `pip` `ipython` and `ptpython`.
Everything else you will need to install yourself by adding extra `RUN`
commands to your project's Dockerfile.

You will probably still need the following lines

    COPY deployment/requirements.txt ${DEPLOYMENT_DIR}/requirements.txt
    RUN pip install -r ${DEPLOYMENT_DIR}/requirements.txt
    COPY . ${SRC_DIR}


## docker-entrypoint.py

This is the main entrypoint of the image. It is built to comply with the [best
practices](https://docs.docker.com/articles/dockerfile_best-practices/#entrypoint).
`docker-entrypoint.py` takes a command as argument, which are listed below. Some of them are configurable by environment variables.

### Root commands
Used to start different shells.

Usage:
```bash
docker run -ti vikingco/python:<VERSION> [COMMAND] [ARG...]
```

| Command  | Description                               |
| -------: | ----------------------------------------- |
| bash     | Starts a bash shell                       |
| python   | Start a classic Python shell              |
| ptpython | Start a PTPython shell                    |
| tox      | Run tox (Make sure it is installed first) |
| help     | Show a help message                       |

### Package commands
Used to manage yum package installation for packages defined in ${DEPLOYMENT_DIR}/required_runtime_packages.txt and
${DEPLOYMENT_DIR}/required_build_packages.txt.

Usage:
```bash
docker run -ti vikingco/python:<VERSION> pkg [COMMAND] [ARG...]
```

| Command           | Description                    |
| ----------------: | ------------------------------ |
| install           | Install all dependencies       |
| install-build     | Install build dependencies     |
| install-runtime   | Install runtime dependencies   |
| uninstall         | Uninstall all dependencies     |
| uninstall-build   | Uninstall build dependencies   |
| uninstall-runtime | Uninstall runtime dependencies |
| help              | Show a help message            |


## Advanced topics

### Building with a user that matches the host user
The default user id and group id are both 1000, and the default username is "python". At buildtime, it is easy to
override this:

Usage (e.g. to match the container user with the local user):
```bash
export PYVERSION="2.7.5"
docker build -t vikingco/python:${PYVERSION} \
    --build-arg PYTHON_VERSIONS=${PYVERSION} \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    --build-arg USERNAME=$(whoami) \
    .
```
