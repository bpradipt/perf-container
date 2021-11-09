IMAGE ?= quay.io/bpradipt/perf
TAG ?= $(shell git describe --tags --always)
RELEASE_TAG := $(shell cat VERSION)
ARCH ?= $(shell uname -m)

ifeq ($(ARCH), x86_64)
	IMAGE_ARCH = $(IMAGE)-amd64
else
	IMAGE_ARCH = $(IMAGE)-$(ARCH)
endif


image:  ## Builds a Linux based image
	podman build -t "$(IMAGE_ARCH):$(TAG)" .

push: image ## Pushes the image to dockerhub, REQUIRES SPECIAL PERMISSION
	podman push "$(IMAGE_ARCH):$(TAG)"

release: image ## Pushes the image with latest and version tag to dockerhub, REQUIRES SPECIAL PERMISSION
	podman tag "$(IMAGE_ARCH):$(TAG)" "$(IMAGE_ARCH):$(RELEASE_TAG)"
	podman tag "$(IMAGE_ARCH):$(TAG)" "$(IMAGE_ARCH):latest"
	podman push "$(IMAGE_ARCH):$(RELEASE_TAG)"
	podman push "$(IMAGE_ARCH):latest"

manifest: release ## Create multi-arch manifest
	podman manifest create $(IMAGE):$(RELEASE_TAG) \
		docker://$(IMAGE)-amd64:$(RELEASE_TAG) \
		docker://$(IMAGE)-ppc64le:$(RELEASE_TAG)

	podman manifest create $(IMAGE):latest \
		docker://$(IMAGE)-amd64:latest \
		docker://$(IMAGE)-ppc64le:latest

	podman manifest push $(IMAGE):$(RELEASE_TAG) docker://$(IMAGE):$(RELEASE_TAG)
	podman manifest push $(IMAGE):latest docker://$(IMAGE):latest

help: ## Shows the help
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
        awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ''

.PHONY: image push release manifest help
