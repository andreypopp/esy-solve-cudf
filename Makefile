.DEFAULT_GOAL: bootstrap
.DELETE_ON_ERROR:

PLATFORM = $(shell node -p "process.platform")
VERSION = $(shell node -p "require('./package.json').version")
NPM_RELEASE_TAG ?= latest
ESY_RELEASE_TAG ?= v$(VERSION)
ESY_EXT := $(shell command -v esy 2> /dev/null)

b:: build-dev
build-dev::
	@esy b dune build
build::
	@esy b

bootstrap::
ifndef ESY_EXT
	$(error "esy command is not avaialble, run 'npm install -g esy'")
endif
	@git submodule init
	@git submodule update
	@esy

clean::
	@rm -rf _build

#
# Platform Specific Release
#

PLATFORM_RELEASE_NAME = _platformrelease/esy-solve-cudf-$(ESY_RELEASE_TAG)-$(PLATFORM).tgz
PLATFORM_RELEASE_ROOT = _platformrelease/$(PLATFORM)
PLATFORM_RELEASE_FILES = \
	esySolveCudfCommand.exe

platform-release: $(PLATFORM_RELEASE_NAME)

$(PLATFORM_RELEASE_NAME)::
	@echo "Creating $(PLATFORM_RELEASE_NAME)"
	@rm -rf $(PLATFORM_RELEASE_ROOT)
	@$(MAKE) $(PLATFORM_RELEASE_FILES:%=$(PLATFORM_RELEASE_ROOT)/%)
	@tar czf $(@) -C $(PLATFORM_RELEASE_ROOT) .
	@rm -rf $(PLATFORM_RELEASE_ROOT)

$(PLATFORM_RELEASE_ROOT)/esySolveCudfCommand.exe: _esy/default/build/default/bin/esySolveCudfCommand.exe
	@mkdir -p $(@D)
	@cp $(<) $(@)

#
# Release
#

RELEASE_ROOT = _release
RELEASE_FILES = \
	platform-linux \
	platform-darwin \
	platform-win32 \
	esySolveCudfCommand.exe \
	postinstall.js \
	LICENSE \
	README.md \
	package.json

release:
	@echo "Creating $(ESY_RELEASE_TAG) release"
	@rm -rf $(RELEASE_ROOT)
	@mkdir -p $(RELEASE_ROOT)
	@$(MAKE) -j $(RELEASE_FILES:%=$(RELEASE_ROOT)/%)

$(RELEASE_ROOT)/esySolveCudfCommand.exe:
	@mkdir -p $(@D)
	@echo "#!/bin/sh\necho 'error: esy-solve-cudf is not installed correctly...'; exit 1" > $(@)
	@chmod +x $(@)

$(RELEASE_ROOT)/platform-linux $(RELEASE_ROOT)/platform-darwin $(RELEASE_ROOT)/platform-win32: PLATFORM=$(@:$(RELEASE_ROOT)/platform-%=%)
$(RELEASE_ROOT)/platform-linux $(RELEASE_ROOT)/platform-darwin $(RELEASE_ROOT)/platform-win32:
	@mkdir $(@)
	@wget \
		-q --show-progress \
		-O $(RELEASE_ROOT)/$(PLATFORM).tgz \
		'https://github.com/andreypopp/esy-solve-cudf/releases/download/$(ESY_RELEASE_TAG)/esy-solve-cudf-$(ESY_RELEASE_TAG)-$(PLATFORM).tgz'
	@tar -xzf $(RELEASE_ROOT)/$(PLATFORM).tgz -C $(@)
	@rm $(RELEASE_ROOT)/$(PLATFORM).tgz

define MAKE_PACKAGE_JSON
let esyJson = require('./package.json');
console.log(JSON.stringify(Object.assign(
	{
		"bin": {
			"esy-solve-cudf": "esySolveCudfCommand.exe"
		},
		"scripts": {
			"postinstall": "node ./postinstall.js"
		}
	},
	{
		name: esyJson.name,
		version: esyJson.version,
		license: esyJson.license,
		description: esyJson.description
	}
), null, 2));
endef
export MAKE_PACKAGE_JSON

$(RELEASE_ROOT)/package.json:
	@node -e "$$MAKE_PACKAGE_JSON" > $(@)

$(RELEASE_ROOT)/%: $(PWD)/%
	@mkdir -p $(@D)
	@cp $(<) $(@)
