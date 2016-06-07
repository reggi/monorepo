# Monorepo

I've turned to the humble [`monorepo`](https://github.com/babel/babel/blob/master/doc/design/monorepo.md), for the answer to my [JavaScript organizational woes](https://news.ycombinator.com/item?id=11849063). This repo is fueled by [`lerna`](https://github.com/lerna/lerna), an excellent tool for managing multiple modules within one repo.

I've resorted to the `Makefile` to preform automated tasks using unix scripts and npm modules. I have for the time being, hardlinked (`ln`) the `Makefile` into each of the packages. This file is the source of all truth, with just the Makefile alone you can start a fresh `monorepo`.

## `make` commands

### `package-create`

```sh
make package-create package=<package-name>
```

This will setup a new package using `babel` syntax and `ava` the test runner.

### `babel-install-preset` and `babel-install-plugin`

```sh
make babel-install-preset module=es2015
```

```sh
make babel-install-plugin module=transform-async-to-generator
```

This will install the module (using `ied`) and add it to the `babel` configuration in `package.json`.

### `test`

This runs `lerna run test`

### `build`

This runs `lerna run build`
