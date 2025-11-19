install:
	mkdir -p bin
	make install -C detach
	make install -C postmail
	make install -C markdown
	make install -C tsapp
	make install -C cont
	cd pockey && make -f Installer.mk install
	@echo ''
	@echo '>>> next'
	@echo export PATH=\"$(shell pwd)/bin:\$$PATH\"

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
