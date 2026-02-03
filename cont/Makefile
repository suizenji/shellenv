install: ../bin/cont ../bin/cont-conf

../bin/cont: cont
	cp $< $@
../bin/cont-conf: cont-conf
	cp $< $@

test:
	-./cont-conf rm -f
	./cont-conf new
	./cont build
	./cont never stop never ever stop ever
	./cont rebuild rmi
