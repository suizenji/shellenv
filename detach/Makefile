install: ../bin/detach

../bin/detach: detach
	cp $< $@

test:
	mkdir file1
	touch file1/file file2
	./detach file1 file2
	test ! -e file1 && test ! -e file2
	./detach ls | grep '/detach/file1'
	./detach ls | grep '/detach/file2'
	./detach pop
	test -e file2 && test ! -e file1
	./detach clear
	! ./detach ls | grep '/detach/file1'

clean:
	rm -rf file1 file2

uninstall: clean
	rm -rf ~/.detach
