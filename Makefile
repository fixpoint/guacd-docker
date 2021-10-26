IMAGE         := ghcr.io/fixpoint/guacd
GUACD_VERSION := 1.3.0

# http://postd.cc/auto-documented-makefile/
.DEFAULT_GOAL := help
.PHONY: help
help: ## Show this help
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	    | awk 'BEGIN {FS = ":.*?## "}; {printf "%-30s %s\n", $$1, $$2}'

.PHONY: image
image:	## Build docker image
	scripts/build.sh \
		${IMAGE} ${GUACD_VERSION} \
		--load

.PHONY: image-release
image-release:	## Build multi platform docker image
	scripts/build.sh \
		${IMAGE} ${GUACD_VERSION} \
		--push \
  		--cache-to=type=registry,ref=${IMAGE}/cache,mode=max \
		--platform linux/amd64,linux/arm64,linux/arm

.PHONY: image-release-dry
image-release-dry:	## Build multi platform docker image (dry)
	scripts/build.sh \
		${IMAGE} ${GUACD_VERSION} \
		--platform linux/amd64,linux/arm64,linux/arm

