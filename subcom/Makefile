DIST := ~/opt/subcom
BIN := ~/bin
COM := $(BIN)/subcom

help:
	@echo 'Usage:'	
	@echo '	install subcom command:		make install'
	@echo '	uninstall subcom command:	make uninstall'

install:
	test ! -e $(DIST)
	test ! -e $(COM)
	chmod +x comp.exp filter.pl subcom.sh
	-mkdir -p $(DIST)
	cp ./* $(DIST)
	-mkdir -p $(BIN)
	-ln -s $(DIST)/subcom.sh $(COM)

uninstall:
	-unlink $(COM)
	-rmdir $(BIN)
	-rm -r $(DIST)

test:
	bash ./test.sh
