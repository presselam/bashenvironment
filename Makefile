SOURCE_FILES=$(patsubst src/%,%,$(shell find src -type f))
DIRECTORIES=$(patsubst src/%,%,$(shell find src -type d))

INCLUDE=$(addprefix --include=, $(DIRECTORIES)) $(addprefix --include=, $(SOURCE_FILES))
EXCLUDE=--exclude='*'

RSYC_OPT=-avhc

.PHONY: install aptinstall

diff : 
	diff -rwaq src/.bash ${HOME}/.bash || true
	for file in src/bin/*; do        \
		diff -waq $$file ${HOME}/bin/ || true; \
	done


fake :
	rsync --dry-run $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/

sync :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) ${HOME}/ src/

install :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/
	ln -fs ${HOME}/.bash/bashrc ${HOME}/.bashrc
	ln -fs ${HOME}/.bash/bash_logout ${HOME}/.bash_logout
	ln -fs ${HOME}/.bash/dots/inputrc ${HOME}/.inputrc
	ln -fs ${HOME}/.bash/dots/dircolors ${HOME}/.dircolors


aptinstall :
	sudo apt update -y
	while read pkg; do sudo apt install -y "$$pkg"; done < ${HOME}/.aptdepends
	sudo apt update -y
