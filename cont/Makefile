install: ../bin/cont

../bin/cont: cont
	cp $< $@

test:
	-./cont conf -d
	./cont conf
	! ./cont conf
	./cont conf -f
	./cont build
	./cont never stop never ever stop ever
	./cont rebuild rmi
