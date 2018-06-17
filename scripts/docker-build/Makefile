.DEFAULT_GOAL: build
.DELETE_ON_ERROR:

INPUT_DIR = /tmp/esy-linux-build-input
OUTPUT_DIR = /tmp/esy-linux-build-output

prepare:
	@echo "linux-build: packing sources tarball..."
	@rm -rf $(INPUT_DIR) $(OUTPUT_DIR)
	@mkdir $(INPUT_DIR) $(OUTPUT_DIR)
	@(cd $(PWD) && git archive -o $(PWD)/src.tar.gz HEAD)
	@mv $(PWD)/src.tar.gz $(INPUT_DIR)/src.tar.gz
	@(cd $(INPUT_DIR) && tar -xzf src.tar.gz)
	@cp -rf $(PWD)/node_modules $(INPUT_DIR)/node_modules
	@rm -rf $(INPUT_DIR)/node_modules/.cache
	@cp Makefile $(INPUT_DIR)/Makefile

docker-image-id:
	@echo "linux-build: preparing docker image..."
	@docker build -q . > $(@)

esy: docker-image-id prepare
	@echo "linux-build: running build in docker container..."
	@docker run \
		--volume $(HOME)/.esy-linux:/root/.esy \
		--volume $(INPUT_DIR):/src \
		--volume $(OUTPUT_DIR):/out \
		-it $(shell cat docker-image-id) bash -c 'cd /src && make BUILDOUT=$(BUILDOUT) build-on-target'
	@cp -rf $(OUTPUT_DIR)/$(shell basename $(BUILDOUT)) ./

build:
ifndef BUILDOUT
	$(error "BUILDOUT is not defined, run like make BUILDOUT=... build")
endif
	@$(MAKE) esy

clean:
	@rm -rf $(BUILDOUT)

build-on-target:
	@esy build
	@cp -rf _build/default/$(BUILDOUT) /out/$(shell basename $(BUILDOUT))
