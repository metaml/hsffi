.DEFAULT_GOAL = help

export SHELL := $(shell type --path bash)

# ignores upper-bound constraints
NEWER=#streamly-core:ghc-prim,streamly-core:template-haskell,template-haskell
CABARGS=#--minimize-conflict-set --allow-newer='$(NEWER)'

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
	cabal clean

clobber: clean ## clobber
	find . -name \*~ -o -name '*#'| xargs rm -f

run: BIN ?= ffi
run: ## run slack
	cabal run $(BIN)

repl: ## repl
	cabal repl

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
