DIST := ~/opt/cop
BIN := ~/bin
COM := $(BIN)/cop

help:
	@echo 'Usage:'	
	@echo '	install command:	make install'
	@echo '	uninstall command:	make uninstall'

install:
	test ! -e $(DIST)
	test ! -e $(COM)
	chmod +x cop
	-mkdir -p $(DIST)
	cp ./* $(DIST)
	-mkdir -p $(BIN)
	-ln -s $(DIST)/cop $(COM)

uninstall:
	-unlink $(COM)
	-rmdir $(BIN)
	-rm -r $(DIST)

test:
	bash ./test.sh
