.DEFAULT_GOAL = help

export SHELL := $(shell type --path bash)

buildc: ## build continuously
	watchexec --exts cabal,hs --  cabal build --jobs '$$ncpus' $(CABARGS) 2>&1 \
        | source-highlight --src-lang=haskell --out-format=esc

build: ## build
	cabal build --jobs='$$ncpus' | source-highlight --src-lang=haskell --out-format=esc

install: ## install
	cabal install --install-method=copy --overwrite-policy=always --installdir=bin exe:babel

test: ## test
	cabal test

lint: ## lint
	hlint app src

clean: ## clean
	find . -name \*~ -o -name '*#'| xargs rm -f
	cabal clean

clobber: clean ## clobber
	rm -rf dist-newstyle

run: BIN ?= ffi
run: ## run slack
	cabal run $(BIN)

repl: ## repl
	cabal repl

etc-src: ## install c/c++ source
	if [ -d etc/c/basilisk ]; then \
		cd etc/c/basilisk && git pull --rebase; \
	else \
		mkdir -p etc/c && git clone git@github.com:AVSLab/basilisk.git etc/c/; \
	fi	

dev: ## nix develop
	nix develop

package: ## nix build default package
	nix build --impure --verbose --option sandbox relaxed

help: ## help
	-@grep --extended-regexp '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sed 's/^Makefile://1' \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'
	-@ghc --version
	-@cabal --version
	-@hlint --version
