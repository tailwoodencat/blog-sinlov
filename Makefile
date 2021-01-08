.PHONY: dist test build
ENV_VERSION = 1.0.0
ENV_HUGO_BASE_URL ?= http://vercel.com/
ENV_HUGO_PORT ?= 51310
ENV_HUGO_DESTINATION_PATH ?= public

printInfo:
	@echo "=> Script Info version $(ENV_VERSION)"
	@echo ""
	@echo "theme use LoveIt https://github.com/dillonzq/LoveIt"
	@echo ""

init:
	@echo "=> this project use hugo more info: https://github.com/gohugoio/hugo"
	@echo "-> if not install just see https://gohugo.io/getting-started/"
	hugo version
	# or use git clone --recurse-submodules
	git submodule init
	git submodule update

debug:
	hugo serve --disableFastRender --buildDrafts --port ${ENV_HUGO_PORT}

build:
	hugo

cleanDestinationPath:
	@if [ -d ${ENV_HUGO_DESTINATION_PATH} ]; \
	then rm -rf ${ENV_HUGO_DESTINATION_PATH} && echo "~> cleaned ${ENV_HUGO_DESTINATION_PATH}"; \
	else echo "~> has cleaned ${ENV_HUGO_DESTINATION_PATH}"; \
	fi

destination: cleanDestinationPath
	hugo -d ${ENV_HUGO_DESTINATION_PATH} --baseUrl ${ENV_HUGO_BASE_URL} --gc
	cp static/favicon.ico ${ENV_HUGO_DESTINATION_PATH}

uglifyjs:
	npm install uglifyjs-folder -g
	uglifyjs-folder dev/js/ -o assets/js/index.min.js

help: printInfo
	@echo "Help of task"
	@echo "make init           ~> init check"
	@echo "make debug          ~> run at http://0.0.0.0:${ENV_HUGO_PORT}/"
	@echo "make destination    ~> build hugo destination at path: ${ENV_HUGO_DESTINATION_PATH}"
	@echo ""
	@echo "=> new file as"
	@echo "rake posts title='article name'"
	@echo "=> new assets for image as:"
	@echo "rake imgNewAssets"