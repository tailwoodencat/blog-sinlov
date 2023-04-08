.PHONY: dist test build
ENV_VERSION = 1.0.0
ENV_HUGO_BASE_URL ?= https://blog.sinlov.cn/
ENV_HUGO_PORT ?= 51310
ENV_HUGO_DESTINATION_PATH ?= public

utils:
	@echo "install hugo see documentation: https://gohugo.io/getting-started/installing/"
	npm install generate-manifest -g
	npm install uglifyjs-folder -g

printInfo:
	@echo "=> Script Info version $(ENV_VERSION)"
	@echo ""
	@echo "theme use LoveIt https://github.com/dillonzq/LoveIt"
	@echo ""

init:
	@echo "=> this project use hugo more info: https://github.com/gohugoio/hugo"
	@echo "-> if not install just see https://gohugo.io/getting-started/"
	hugo version
	$(info or use git clone --recurse-submodules)
	git submodule init
	git submodule update

up:
	git submodule update

debug:
	hugo serve --disableFastRender --buildDrafts --port ${ENV_HUGO_PORT}

build:
	hugo

buildRepo: up
	hugo -d ${ENV_HUGO_DESTINATION_PATH} --baseUrl ${ENV_HUGO_BASE_URL} --gc --cleanDestinationDir --minify

cleanDestinationPath:
	@RM -r ${ENV_HUGO_DESTINATION_PATH}
	$(info has clean ${ENV_HUGO_DESTINATION_PATH})

destination: cleanDestinationPath up
	hugo -d ${ENV_HUGO_DESTINATION_PATH} --baseUrl ${ENV_HUGO_BASE_URL} --gc --cleanDestinationDir --minify
	cp static/favicon.ico ${ENV_HUGO_DESTINATION_PATH}
	cd public && generate-manifest --url=${ENV_HUGO_BASE_URL}

uglifyjs:
	uglifyjs-folder dev/js/ -o assets/js/index.min.js

help: printInfo
	@echo "Help of task"
	@echo "make init           ~> init check"
	@echo "make utils          ~> install utils of this"
	@echo "make debug          ~> run at http://0.0.0.0:${ENV_HUGO_PORT}/"
	@echo "make destination    ~> build hugo destination at path: ${ENV_HUGO_DESTINATION_PATH}"
	@echo ""
	@echo "=> new file as"
	@echo "rake posts title='article name'"
	@echo "=> new assets for image as:"
	@echo "rake imgNewAssets"