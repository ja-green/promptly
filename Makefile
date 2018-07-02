SHELL 	:= /bin/bash
PROJECT  = promptly
P_HOME   = ${HOME}/.${PROJECT}
BASHRC   = ${HOME}/.bashrc

REPO	 = $(shell pwd)
LIB	 = $(REPO)/lib
BIN      = $(REPO)/bin
TST	 = $(REPO)/test
BLD	 = $(REPO)/build
CPNT	 = $(REPO)/component.d

LIBS	 = $(wildcard $(LIB)/*.sh)
CMDS	 = $(wildcard $(BIN)/*.sh)
MAIN	 = $(REPO)/$(PROJECT)

.PHONY: all install update test help

all: install

install:
	@ $(BLD)/install.sh

test:
	@ $(TST)/run_bats.sh

help:
	@ grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

