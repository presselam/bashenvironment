SOURCE_FILES=bash_aliases bash_functions bash_logout bashrc dircolors aptdepends
INSTALL_FILES=( $(addprefix $(HOME)/.,$(SOURCE_FILES)) )

.PHONY: diff install uninstall aptinstall

diff: $(addprefix diff-, $(SOURCE_FILES))
	
diff-% : $(SOURCE_FILES)
	@echo Comparing: $* 
	-colordiff $(addprefix $(HOME)/.,$*) $*

install: $(addprefix inst-, $(SOURCE_FILES))

inst-% : $(SOURCE_FILES)
	-rsync -zvh $* $(addprefix $(HOME)/.,$*)

uninstall: $(addprefix unin-, $(SOURCE_FILES))

unin-% : $(SOURCE_FILES)
	-rm $(addprefix $(HOME)/.,$*)

sync: $(addprefix sync-, $(SOURCE_FILES))

sync-% : $(SOURCE_FILES)
	-rsync  $(addprefix $(HOME)/.,$*) $*


aptinstall : 
	sudo apt update -y
	while read pkg; do sudo apt install -y "$$pkg"; done < aptdepends
	sudo apt update -y
