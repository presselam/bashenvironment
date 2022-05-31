SOURCE_FILES=$(patsubst src/%,%,$(wildcard src/.[a-zA-Z]*))
SOURCE_FILES+=$(patsubst src/%,%,$(wildcard src/.bash/*))
SOURCE_FILES+=$(patsubst src/%,%,$(wildcard src/.bash/ftplugin/*))
SOURCE_FILES+=$(patsubst src/%,%,$(wildcard src/bin/*))

INCLUDE=--include='bin' $(addprefix --include=, $(SOURCE_FILES))

EXCLUDE=--exclude='*.bak' --exclude='*'
RSYC_OPT=-avhc

.PHONY: diff install uninstall aptinstall bin

diff: $(addprefix diff-, $(SOURCE_FILES))
	
diff-% : $(addprefix src/, $(SOURCE_FILES))
	-colordiff src/$* ${HOME}/$* || true

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
