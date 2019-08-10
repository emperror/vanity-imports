# A Self-Documenting Makefile: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

OS = $(shell uname)

GOBIN_VERSION = 0.0.10
VANGEN_VERSION = 1.0.0

.PHONY: build
build: vangen ## Build the site
	cp -r static/* public/

bin/gobin: bin/gobin-${GOBIN_VERSION}
	@ln -sf gobin-${GOBIN_VERSION} bin/gobin
bin/gobin-${GOBIN_VERSION}:
	@mkdir -p bin
ifeq (${OS}, Darwin)
	curl -L https://github.com/myitcv/gobin/releases/download/v${GOBIN_VERSION}/darwin-amd64 > ./bin/gobin-${GOBIN_VERSION} && chmod +x ./bin/gobin-${GOBIN_VERSION}
endif
ifeq (${OS}, Linux)
	curl -L https://github.com/myitcv/gobin/releases/download/v${GOBIN_VERSION}/linux-amd64 > ./bin/gobin-${GOBIN_VERSION} && chmod +x ./bin/gobin-${GOBIN_VERSION}
endif

bin/vangen: bin/vangen-${VANGEN_VERSION}
	@ln -sf vangen-${VANGEN_VERSION} bin/vangen
bin/vangen-${VANGEN_VERSION}: bin/gobin
	@mkdir -p bin
	GOBIN=bin/ bin/gobin 4d63.com/vangen@v${VANGEN_VERSION}
	@mv bin/vangen bin/vangen-${VANGEN_VERSION}

.PHONY: vangen
vangen: bin/vangen ## Build golang files
	bin/vangen -out public/golang/

.PHONY: clean
clean: ## Remove built files
	rm -rf public/

.PHONY: list
list: ## List all make targets
	@${MAKE} -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

.PHONY: help
.DEFAULT_GOAL := help
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Variable outputting/exporting rules
var-%: ; @echo $($*)
varexport-%: ; @echo $*=$($*)
