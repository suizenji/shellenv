URL :=
DEPTH := 1
FILTER :=

define encode
$(shell perl -MURI::Escape -e 'print uri_escape("$(1)");')
endef

define decode
$(shell printf "%b" "$(subst %,\\x,$1)")
endef

define schema-host
$(shell echo '$(call decode,$1)' | sed -E 's%^(https?://[^/]+).*%\1%')
endef

help:
	@echo save HTMLs

# make code URL='https://www.google.com/foo/bar?test=te& st'
code:
	@echo '$(URL)'
	@echo '$(call encode,$(URL))'
	@echo '$(call decode,$(call encode,$(URL)))'
	@echo '$(call schema-host,$(URL))'

rec:
	@echo depth is $(DEPTH)
	@echo next depth is $$(( $(DEPTH) - 1 ))
ifneq ($(DEPTH),1)
	make rec DEPTH=$$(( $(DEPTH) - 1 ))
endif

# make all URL='https://www.google.com'
all:
	make $(call encode,$(URL)).link
ifneq ($(DEPTH),1)
#	make all DEPTH=$$(( $(DEPTH) - 1 ))
	@cat $(call encode,$(URL)).link | perl -MURI::Escape -nE 'say uri_escape($$_) . ".link"' | xargs make
endif

.PRECIOUS: %.html
%.html:
	curl $(call decode,$*) > $@

%.link.all: %.html
	cat $< | \
          ag -o ' href="[^"]+"' | \
          sed -E 's/.*href="([^"]+)"/\1/g' | \
          sed 's%^/%$(call schema-host,$*)/%' | \
          sort -u > $@

%.link: %.link.all
ifneq ($(FILTER),)
	cat $< | grep -E "$(FILTER)" > $@
else
	cat $< > $@
endif

clean:
	rm -f *.html *.link.all *.link
