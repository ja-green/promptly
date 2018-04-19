SHELL 	:= /bin/bash
PROJECT  = promptly
P_HOME   = ${HOME}/.${PROJECT}
BASHRC   = ${HOME}/.bashrc

VERBOSE  = 0
FILTER   = $(if $(filter 1,${VERBOSE},,@)

.PHONY: all install update

all: install

install: ## install promptly
	${FILTER} if ! grep 'source ${HOME}/.promptly' ${BASHRC} 2>/dev/null ; then\
	    mkdir ${P_HOME};\
            cp components ${P_HOME};\
            cp promptly_ps1 ${P_HOME};\
	    echo 'source ${HOME}/.promptly' >> ${BASHRC};\
	fi

update: ## update promptly
        ${FILTER} mkdir ${P_HOME}
        ${FILTER} cp components ${P_HOME}
        ${FILTER} cp promptly_ps1 ${P_HOME}
	${FILTER} if ! grep 'source ${HOME}/.promptly' ${BASHRC} 2>/dev/null ; then\
	    echo 'source ${HOME}/.promptly' >> ${BASHRC};\
	fi

help: ## display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

