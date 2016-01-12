ROOTDIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

parse_python_version = $(shell echo $@ | sed "s/[^-]*-python-\(.*\)/\1/")
ALL_PYTHON_VERSIONS = pypy-2.4.0 2.6.9 2.7.11 3.3.6 3.4.3 3.5.0

all: build push

push: push-python-pypy-2.4.0 push-python-2.7.11 push-python-3.4.3 push-python-all

build: build-python-pypy-2.4.0 build-python-2.7.11 build-python-3.4.3 build-python-all

build-python-all:
	docker build -t vikingco/python:all --build-arg PYTHON_VERSIONS="$(ALL_PYTHON_VERSIONS)" .

push-python-all:
	docker push vikingco/python:all

build-%: PYTHON_VERSION=$(parse_python_version)
build-%:
	docker build -t vikingco/python:$(PYTHON_VERSION) --build-arg PYTHON_VERSIONS=$(PYTHON_VERSION) .

push-%: PYTHON_VERSION=$(parse_python_version)
push-%:
	docker push vikingco/python:$(PYTHON_VERSION)
