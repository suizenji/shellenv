install: ../bin/detach

../bin/detach: detach
	cp $< $@

test:
	touch file1 file2
	./detach file1 file2
	test ! -e file1 && test ! -e file2
	./detach ls | grep '/detach/file1'
	./detach ls | grep '/detach/file2'
	./detach pop
	test -e file2 && test ! -e file1
	./detach clear
	! ./detach ls | grep '/detach/file1'

clean:
	rm -rf ~/.detach file1 file2
