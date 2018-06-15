.DEFAULT_GOAL: bootstrap
.DELETE_ON_ERROR:

RELEASE_TAG ?= latest
ESY_EXT := $(shell command -v esy 2> /dev/null)
BIN = $(PWD)/node_modules/.bin

b:: build-dev
build-dev::
	@esy b jbuilder build -j 4 --dev
build::
	@esy b

bootstrap::
ifndef ESY_EXT
	$(error "esy command is not avaialble, run 'npm install -g esy'")
endif
	@esy install
	@esy build

clean::
	@rm -rf _build

RELEASE_ROOT = $(PWD)/_release
RELEASE_FILES = esySolveCudfCommand.exe \
                esySolveCudfCommandDarwin.exe \
                esySolveCudfCommandLinux.exe \
                package.json \
                LICENSE \
                postinstall.sh

publish: build-release
	@(cd $(RELEASE_ROOT) && npm publish --access public --tag $(RELEASE_TAG))
	@git push && git push --tags

bump-major-version:
	@npm version major

bump-minor-version:
	@npm version minor

bump-patch-version:
	@npm version patch

build-release:
	@rm -rf $(RELEASE_ROOT)
	@mkdir $(RELEASE_ROOT)
	@$(MAKE) $(RELEASE_FILES:%=$(RELEASE_ROOT)/%)

$(RELEASE_ROOT)/esySolveCudfCommand.exe:
	@echo "#!/bin/bash\necho 'error: esy-solve is installed incorrectly'" > $(@)
	@chmod +x $(@)

$(RELEASE_ROOT)/esySolveCudfCommandLinux.exe: build-linux
	@cp scripts/docker-build/esySolveCudfCommand.exe $(@)

$(RELEASE_ROOT)/esySolveCudfCommandDarwin.exe: build
	@cp _build/default/bin/esySolveCudfCommand.exe $(@)

define MAKE_PACKAGE_JSON
let esyJson = require('./package.json');
let packageJson = require('./package.release.json');
console.log(JSON.stringify(Object.assign(
  packageJson,
	{
		name: esyJson.name,
		version: esyJson.version,
		license: esyJson.license,
		description: esyJson.description
	}
), null, 2));
endef
export MAKE_PACKAGE_JSON

$(RELEASE_ROOT)/package.json: package.release.json
	@node -e "$$MAKE_PACKAGE_JSON" > $(@)

$(RELEASE_ROOT)/%: %
	@cp $(<) $(@)

build-linux:
	@make BUILDOUT=bin/esySolveCudfCommand.exe -C scripts/docker-build build
