.PHONY: dist test build
ENV_VERSION =1.0.0
ENV_HUGO_BASE_URL ?= https://blog.sinlov.cn/
ENV_HUGO_PORT     ?= 41310
ENV_HUGO_DESTINATION_PATH ?=public
ENV_HUGO_GEN_RESOURCES    ?=resources
# theme set
ENV_THEME_PATH            ?=themes/DoIt
ENV_THEME_VERSION         ?=v0.4.2

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
ifeq ($(OS),Windows_NT)
	$(info windows install by: scoop install main/hugo-extended)
else
	$(info macos install by: brew install hugo)
endif
	$(info and node kit)
	$(info npx generate-manifest)
	$(info npx uglifyjs-folder)

.PHONY: printInfo
printInfo:
	@echo "=> Script Info version $(ENV_VERSION)"
	@echo ""
	@echo "theme use LoveIt https://github.com/HEIGE-PCloud/DoIt with version ${ENV_THEME_VERSION}"
	@echo ""

.PHONY: theme.change.version
theme.change.version:
	git submodule set-branch --branch ${ENV_THEME_VERSION} ${ENV_THEME_PATH}

.PHONY: init
init:
	@echo "=> this project use hugo more info: https://github.com/gohugoio/hugo"
	@echo "-> if not install just see https://gohugo.io/getting-started/"
	hugo version
	$(info or use git clone --recurse-submodules)
	git submodule update --init --recursive

.PHONY: up
up:
	git status
	git pull
	git submodule update

.PHONY: up.env
up.env:
	git submodule foreach git log --oneline -n 1

.PHONY: up.submodule.diff
up.diff:
	@git submodule foreach git log ORIG_HEAD --remotes --oneline -n 1
	@git submodule foreach git log --oneline -n 1

.PHONY: up.submodule.remote.env
up.remote.env:
	git submodule foreach git log ORIG_HEAD --remotes --oneline -n 1

.PHONY: up.remote
up.remote:
	git submodule update --remote --merge

.PHONY: up.remote.force
up.remote.force:
	git submodule update --remote --merge --force

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
	cd public && npx generate-manifest --url=${ENV_HUGO_BASE_URL}

.PHONY: uglifyjs
uglifyjs:
	npx uglifyjs-folder dev/js/ -o assets/js/index.min.js

.PHONY: help
help: printInfo
	@echo "=> Help of task"
	@echo "make init                        ~> init check"
	@echo "make utils                       ~> install utils of this project"
	@echo ""
	@echo "make up                          ~> update this project submodule"
	@echo "make up.diff                     ~> show diff of this project submodule"
	@echo "make up.remote                   ~> update this project submodule from remote"
	@echo "make up.remote.force             ~> update this project submodule from remote to main latest"
	@echo "make theme.change.version        ~> change theme version from ${ENV_THEME_VERSION}"
	@echo "make debug                       ~> run at http://0.0.0.0:${ENV_HUGO_PORT}/"
	@echo "make destination                 ~> build hugo destination at path: ${ENV_HUGO_DESTINATION_PATH}"
	@echo ""
	@echo "-> new assets for image as:"
	@echo "rake imgNewAssets"
	@echo ""
	@echo "-> new blog file as"
	@echo "rake posts cg='' title='article name'"
	@echo ""