SOURCE_FILES=$(patsubst src/%,%,$(wildcard src/.[a-zA-Z]*))
BIN_FILES=$(patsubst src/%,%,$(wildcard bin/*))

INCLUDE= $(addprefix --include=, $(SOURCE_FILES))
BIN_INCLUDE= $(addprefix --include=, $(BIN_FILES))

EXCLUDE=--exclude='*.bak' --exclude='*'
RSYC_OPT=-avhc

INSTALL_FILES=( $(addprefix $(HOME)/.,$(SOURCE_FILES)) )

.PHONY: diff install uninstall aptinstall bin

test :
	@echo $(BIN_INCLUDE)


diff: $(addprefix diff-, $(SOURCE_FILES))
	
diff-% : $(addprefix src/, $(SOURCE_FILES))
	-colordiff src/$* ${HOME}/$* || true

fake :
	rsync --dry-run $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/
	rsync $(RSYC_OPT) $(BIN_INCLUDE) $(EXCLUDE) bin/ $(HOME)/bin/


sync :
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) ${HOME}/ src/
	rsync $(RSYC_OPT) $(BIN_INCLUDE) $(EXCLUDE) $(HOME)/bin/ bin/

install : 
	rsync $(RSYC_OPT) $(INCLUDE) $(EXCLUDE) src/ ${HOME}/
	rsync $(RSYC_OPT) $(BIN_INCLUDE) $(EXCLUDE) bin/ $(HOME)/bin/

aptinstall : 
	sudo apt update -y
	while read pkg; do sudo apt install -y "$$pkg"; done < aptdepends
	sudo apt update -y
