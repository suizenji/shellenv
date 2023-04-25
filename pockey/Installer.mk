install: ../bin/pockey

../bin/pockey: Makefile
	cp $< $@

test:
	make test

clean:
	make clean
