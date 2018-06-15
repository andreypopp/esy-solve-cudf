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
