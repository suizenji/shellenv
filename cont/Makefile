install: ../bin/cont

../bin/cont: cont
	cp $< $@

test:
	./cont conf -o
	./cont build
	./cont never stop never ever stop ever
	./cont rebuild rmi
