install:
	echo TODO

test:
	touch file
	./detach file
	test ! -e file
	./detach ls | grep '/detach/file'
	./detach pop
	test -e file

clean:
	rm -rf ~/.detach file
