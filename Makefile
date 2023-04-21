install:
	make install -C detach
	make install -C postmail

uninstall:
	rm ./bin/*

test:
	make test -C detach
	make test -C postmail

clean:
	make clean -C detach
	make clean -C postmail
