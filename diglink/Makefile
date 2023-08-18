URL :=
DEPTH := 1
DOMAIN :=

define encode
$(shell perl -MURI::Escape -e 'print uri_escape("$(1)");')
endef

define decode
$(shell printf "%b" "$(subst %,\\x,$1)")
endef

define schema-host
$(shell echo '$1' | sed -E 's%^(https?://[^/]+).*%\1%')
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
	make $(call encode,$(URL)).link.all
ifneq ($(DEPTH),1)
#	make all DEPTH=$$(( $(DEPTH) - 1 ))
	cat $(subst /,%2F,$(URL)).link | xargs -I{} make all URL='{}' DEPTH=$$(( $(DEPTH) - 1 ))
endif

.PRECIOUS: %.html
%.html:
	curl $(call decode,$*) > $@

%.link.all: %.html
	cat $< | \
          ag -o ' href="[^"]+"' | \
          sed -E 's/.*href="([^"]+)"/\1/g' | \
          sed 's%^/%$(subst %2F,/,$<)/%' | \
          sort -u > $@

%.link: %.link.all
ifneq ($(DOMAIN),)
	cat $< | grep -E "$(DOMAIN)" > $@
else
	cat $< > $@
endif

clean:
	rm -f *.html *.link
