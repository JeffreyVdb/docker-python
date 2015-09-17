ROOTDIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

parse_python_version = $(shell echo $@ | sed "s/[^-]*-python-\(.*\)/\1/")

all: build push

push: push-python-2.7.10 push-python-3.4.3

build: build-python-2.7.10 build-python-3.4.3

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
