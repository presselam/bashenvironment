SOURCE_FILES=$(patsubst src/%,%,$(shell find src -type f))
DIRECTORIES=$(patsubst src/%,%,$(shell find src -type d))

INCLUDE=$(addprefix --include=, $(DIRECTORIES)) $(addprefix --include=, $(SOURCE_FILES))
EXCLUDE=--exclude='*'

RSYC_OPT=-avhc

.PHONY: diff install aptinstall

diff : $(addprefix diff-, $(SOURCE_FILES))

diff-% : $(addprefix src/, $(SOURCE_FILES))
	-colordiff src/$* ${HOME}/$* || true

diff-.bash/% : $(addprefix src/, $(SOURCE_FILES))
	-colordiff src/.bash/$* ${HOME}/.bash/$* || true

diff-bin/% : $(addprefix src/, $(SOURCE_FILES))
	-colordiff src/bin/$* ${HOME}/bin/$* || true

fake :
	rsync --dry-run $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/

sync :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) ${HOME}/ src/

install :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/

aptinstall :
	sudo apt update -y
	while read pkg; do sudo apt install -y "$$pkg"; done < ${HOME}/.aptdepends
	sudo apt update -y
