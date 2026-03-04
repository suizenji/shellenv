install: ../bin/detach

../bin/detach: detach
	cp $< $@

test: test_runner.sh
	./test_runner.sh

# Legacy test (uses real ~/.detach; run manually if needed)
test-legacy:
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

test-sample:
	echo 1 > first.txt
	echo 2 > second.txt
	echo 3 > third.txt

clean:
	rm -rf file1 file2 first.txt second.txt third.txt

uninstall: clean
	rm -rf ~/.detach
