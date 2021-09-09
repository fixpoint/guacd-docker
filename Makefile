IMAGE=ghcr.io/fixpoint/guacd
GUACD_VERSION=1.3.0
ARGS=

# http://postd.cc/auto-documented-makefile/
.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	    | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

.PHONY: image
image:	## Build multi platform docker image (dry)
	@docker buildx build \
		${ARGS} \
		--platform linux/amd64,linux/arm64,linux/arm \
		--cache-from=${IMAGE}/cache \
		--cache-from=${IMAGE} \
		--build-arg GUACD_VERSION=${GUACD_VERSION} \
		-t ${IMAGE}:${GUACD_VERSION} \
		-t ${IMAGE}:latest \
		-f Dockerfile \
		..

.PHONY: image-push
image-push:	## Build multi platform docker image (push)
	@make ARGS="--push --cache-to=${IMAGE}/cache" image
