ROOTDIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

python_version = $(shell echo $@ | sed "s/[^-]*-python\(.*\)/\1/")

all: build push

push: push-python2.7 push-python3.4

build: build-python2.7 build-python3.4

build-%: PYTHON_VERSION=$(python_version)
build-%:
	@echo "\
pythonversion: $(PYTHON_VERSION)-slim\n\
" > data$(PYTHON_VERSION).yml
	docker run \
		-v $(ROOTDIR)/Dockerfile.j2:/data/Dockerfile.j2 \
		-v $(ROOTDIR)/data$(PYTHON_VERSION).yml:/data/data.yml \
		sgillis/jinja2cli Dockerfile.j2 data.yml > Dockerfile
	docker build -t vikingco/python:$(PYTHON_VERSION) .
	@rm data$(PYTHON_VERSION).yml
	@rm Dockerfile

push-%: PYTHON_VERSION=$(python_version)
push-%:
	docker push vikingco/python:$(PYTHON_VERSION)
