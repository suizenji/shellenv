install: ../bin/cont ../bin/cconf

../bin/cont: cont
	cp $< $@
../bin/cconf: cconf
	cp $< $@

test:
	./cconf new -f
	./cont build
	./cont never stop never ever stop ever
	./cont rebuild rmi
