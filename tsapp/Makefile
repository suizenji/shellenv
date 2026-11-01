install: ../bin/create-tsapp ../bin/setup-tsmod ../bin/tsapp

test: test_runner.sh create-tsapp
	./test_runner.sh

../bin/create-tsapp: create-tsapp
	cp $< $@

../bin/setup-tsmod: setup-tsmod
	cp $< $@

../bin/tsapp: tsapp
	cp $< $@
