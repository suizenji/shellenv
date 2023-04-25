install:
	make install -C detach
	make install -C postmail
	cd pockey && make -f Installer.mk install
	@echo ''
	@echo '>>> next'
	@echo export PATH=\"\$$PATH:$(shell pwd)/bin\"

uninstall:
	rm ./bin/*

test:
	make test -C detach
	make test -C postmail
	cd pockey && make -f Installer.mk test

clean:
	make clean -C detach
	make clean -C postmail
	cd pockey && make -f Installer.mk clean
