ROOTDIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

parse_python_version = $(shell echo $@ | sed "s/[^-]*-python-\(.*\)/\1/")
ALL_PYTHON_VERSIONS = pypy-2.4.0 2.6.9 2.7.10 3.3.6 3.4.3 3.5.0

all: build push

push: push-python-pypy-2.4.0 push-python-2.7.10 push-python-3.4.3 push-python-all

build: build-python-pypy-2.4.0 build-python-2.7.10 build-python-3.4.3 build-python-all

build-python-all:
	@echo "\
pythonversions: $(ALL_PYTHON_VERSIONS)\n\
" > data-all.yml
	docker run \
		-v $(ROOTDIR)/Dockerfile.j2:/data/Dockerfile.j2 \
		-v $(ROOTDIR)/data-all.yml:/data/data.yml \
		sgillis/jinja2cli Dockerfile.j2 data.yml > Dockerfile
	docker build -t vikingco/python:all .
	@rm data-all.yml
	@rm Dockerfile

push-python-all:
	docker push vikingco/python:all

build-%: PYTHON_VERSION=$(parse_python_version)
build-%:
	@echo "\
pythonversions: $(PYTHON_VERSION)\n\
" > data$(PYTHON_VERSION).yml
	docker run \
		-v $(ROOTDIR)/Dockerfile.j2:/data/Dockerfile.j2 \
		-v $(ROOTDIR)/data$(PYTHON_VERSION).yml:/data/data.yml \
		sgillis/jinja2cli Dockerfile.j2 data.yml > Dockerfile
	docker build -t vikingco/python:$(PYTHON_VERSION) .
	@rm data$(PYTHON_VERSION).yml
	@rm Dockerfile

push-%: PYTHON_VERSION=$(parse_python_version)
push-%:
	docker push vikingco/python:$(PYTHON_VERSION)
