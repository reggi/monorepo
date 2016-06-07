
## usage

# make wrap package=reggi command=gitignore-create
# make gitignore-create
# make wrap command=babel-install-preset module=es2015 package=reggi
# make babel-install-preset module=es2015

## variables

MKFILE_PATH=$(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MKFILE_DIR:=$(shell cd $(shell dirname $(MKFILE_PATH)); pwd)
MKFILE_DIR=$(word 1, $(subst /packages, ,$(THIS_MKFILE_DIR)))
EMAIL=`git config --get user.email`
VERSION=`cat lerna.json | json version`
GITHUB_ORIGN=`git -C ${CURDIR} remote get-url origin`
MYMAKE=${MAKE} -f ${MKFILE_PATH}
NPM=${MKFILE_DIR}/node_modules/.bin/ied

## helpers

ied:
	${NPM} install ${install}

log:
	# echo ${MKFILE_PATH}
	# echo ${MKFILE_DIR}
	# echo ${UPPER_MKFILE_DIR}

wrap:
	cd packages/${package}/ && ${MYMAKE} ${command}

## npm

npm-local:
	mkdir ./npm ;\
	cd ./npm ;\
	${MKFILE_DIR}/node_modules/.bin/local-npm ;\
	npm set registry http://127.0.0.1:5080 ;\

npm-regular:
	npm set registry https://registry.npmjs.org ;\

## general

build:
	${MKFILE_DIR}/node_modules/.bin/lerna run build ;\

test:
	${MKFILE_DIR}/node_modules/.bin/lerna run test ;\

## git / Github

gitignore-create:
	touch .gitignore ;\
	echo 'node_modules' >> .gitignore ;\
	echo 'npm' >> .gitignore ;\
	echo '.DS_Store' >> .gitignore ;\

## babel

babel-install-preset:
	${NPM} install --save-dev babel-preset-${module}
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'if (!this.babel) this.babel = {}' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'if (!this.babel.presets) this.babel.presets = []' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.babel.presets.push("'${module}'")' ;\

babel-install-plugin:
	${NPM} install --save-dev babel-plugin-${module}
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'if (!this.babel) this.babel = {}' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'if (!this.babel.plugins) this.babel.plugins = []' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.babel.plugins.push("'${module}'")' ;\

babel-ready:
	${MYMAKE} babel-install-preset module=es2015
	${MYMAKE} babel-install-preset module=stage-2
	${MYMAKE} babel-install-plugin module=transform-async-to-generator
	${MYMAKE} babel-install-plugin module=transform-runtime
	${MYMAKE} babel-package

babel-package:
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.main = "./lib/index"' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.esnext = "./src/index"' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.scripts.build = "babel ./src --out-dir ./lib"' ;\

## testing

ava-ready:
	${NPM} install ava babel-register --save-dev ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'if (!this.ava) this.ava = {}' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'if (!this.ava.require) this.ava.require = []' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.ava.require.push("babel-register")' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.ava.failFast = true' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.ava.babel = "inherit"' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.scripts.test = "ava"' ;\

## package

package-add-repository:
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.repository = {}' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.repository.type = "git"' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.repository.url = "'$(GITHUB_ORIGN)/master/packages/$(package)'"' ;\

package-ready:
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.version = "'$(VERSION)'"' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.author = "'$(EMAIL)'"' ;\

package-create:
	cd ./packages ;\
	mkdir $(package) ;\
	cd $(package) ;\
	ln ${MKFILE_PATH} ./Makefile
	npm init -y ;\
	mkdir src lib test ;\
	touch ./src/index.js ;\
	touch ./lib/index.js ;\
	touch ./test/index.js ;\
	touch ./README.md
	${MYMAKE} wrap package=${package} command=babel-ready
	${MYMAKE} wrap package=${package} command=ava-ready
	${MYMAKE} wrap package=${package} command=package-ready
	${MYMAKE} wrap package=${package} command=package-add-repository

package-onboard:
	cd ./packages/${package} ;\
	ln ${MKFILE_PATH} ./Makefile ;\

# meta

monorepo-init:
	npm init -y ;\
	git init ;\
	npm install json ied lerna@2.0.0-beta.16 --save-dev ;\
	${MKFILE_DIR}/node_modules/.bin/lerna init ;\
	${MYMAKE} gitignore-create ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.scripts.test = "make test"' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.scripts.build = "make build"' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'delete this.main' ;\
	${MKFILE_DIR}/node_modules/.bin/json -I -f package.json -e 'this.keywords.push("monorepo")' ;\
	${MYMAKE} package-ready ;\
	echo 'please add a git remote origin'
