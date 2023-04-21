install:
	make install -C detach
	make install -C postmail

uninstall:
	rm ./bin/*
