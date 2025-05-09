.PHONY: dist test build
ENV_VERSION =1.0.0
ENV_HUGO_BASE_URL ?= https://blog.sinlov.cn/
ENV_HUGO_PORT     ?= 51310
ENV_HUGO_DESTINATION_PATH ?=public
ENV_HUGO_GEN_RESOURCES    ?=resources

.PHONY: clean.hugo.dest
clean.hugo.dest:
	@$(RM) -r ${ENV_HUGO_DESTINATION_PATH}

.PHONY: clean.build
clean.build:
	@$(RM) -r ${ENV_HUGO_DESTINATION_PATH}
	$(info clean.build at path: ${ENV_HUGO_DESTINATION_PATH})
	@$(RM) .hugo_build.lock
	$(info clean.build at path: .hugo_build.lock)

.PHONY: clean.hugo.gen
clean.hugo.gen:
	@$(RM) -r ${ENV_HUGO_GEN_RESOURCES}

.PHONY: clean.hugo
clean.hugo: clean.hugo.dest clean.hugo.gen

.PHONY: clean.all
clean.all: clean.hugo

.PHONY: utils
utils:
	@echo "install hugo see documentation: https://gohugo.io/getting-started/installing/"
	npm install generate-manifest -g
	npm install uglifyjs-folder -g

.PHONY: printInfo
printInfo:
	@echo "=> Script Info version $(ENV_VERSION)"
	@echo ""
	@echo "theme use LoveIt https://github.com/HEIGE-PCloud/DoIt"
	@echo ""

.PHONY: init
init:
	@echo "=> this project use hugo more info: https://github.com/gohugoio/hugo"
	@echo "-> if not install just see https://gohugo.io/getting-started/"
	hugo version
	$(info or use git clone --recurse-submodules)
	git submodule init
	git submodule update

.PHONY: up
up:
	git status
	git pull
	git submodule update

.PHONY: upRemote
upRemote:
	git submodule update --remote --merge


.PHONY: debug
debug: clean.build
	hugo serve --disableFastRender --buildDrafts --port ${ENV_HUGO_PORT} --noHTTPCache --printPathWarnings --enableGitInfo

.PHONY: ci
ci: clean.build
	hugo serve --disableFastRender --buildDrafts --port ${ENV_HUGO_PORT} -e production

.PHONY: build
build: clean.hugo
	hugo -d ${ENV_HUGO_DESTINATION_PATH} -b ${ENV_HUGO_BASE_URL} --gc --cleanDestinationDir --minify

.PHONY: build.install
build.install:
	pnpm install

.PHONY: build.run
build.run:
	pnpm start

.PHONY: buildRepo
buildRepo: up
	hugo -d ${ENV_HUGO_DESTINATION_PATH} -b ${ENV_HUGO_BASE_URL} --gc --cleanDestinationDir --minify

.PHONY: destination
destination: clean.hugo up
	hugo -d ${ENV_HUGO_DESTINATION_PATH} -b ${ENV_HUGO_BASE_URL} --gc --cleanDestinationDir --minify
	cp static/favicon.ico ${ENV_HUGO_DESTINATION_PATH}
	cd public && generate-manifest --url=${ENV_HUGO_BASE_URL}

.PHONY: uglifyjs
uglifyjs:
	uglifyjs-folder dev/js/ -o assets/js/index.min.js

.PHONY: help
help: printInfo
	@echo "Help of task"
	@echo "make init           ~> init check"
	@echo "make utils          ~> install utils of this"
	@echo "make up             ~> update this project submodule"
	@echo "make upRemote       ~>	update this project submodule from remote"
	@echo "make debug          ~> run at http://0.0.0.0:${ENV_HUGO_PORT}/"
	@echo "make destination    ~> build hugo destination at path: ${ENV_HUGO_DESTINATION_PATH}"
	@echo ""
	@echo "=> new file as"
	@echo "rake posts title='article name'"
	@echo "=> new assets for image as:"
	@echo "rake imgNewAssets"