include env
DIST := ~/opt
BIN := ~/bin

help:
	@echo 'Usage:'	
	@echo '	install command:	make install'
	@echo '	uninstall command:	make uninstall'
	@echo 'debug'
	@echo '	PJ=[$(PJ)]'
	@echo '	COM=[$(COM)]'

install:
	test ! -e $(DIST)/$(PJ)
	test ! -e $(BIN)/$(COM)

	mkdir -p $(DIST)/$(PJ)
	cp ./* $(DIST)/$(PJ)

	-mkdir -p $(BIN)
	ln -s $(DIST)/$(PJ)/$(COM) $(BIN)/$(COM)

uninstall:
	-unlink $(BIN)/$(COM)
	-rmdir $(BIN)
	-rm -r $(DIST)/$(COM)

test:
	bash ./test.sh
