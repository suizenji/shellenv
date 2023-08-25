URL :=
DEPTH := 1
FILTER := .*
ARGS :=

define encode
$(shell perl -MURI::Escape -e 'print uri_escape("$(1)");')
endef

define decode
$(shell perl -MURI::Escape -e 'print uri_unescape("$(1)");')
endef

define schema-host
$(shell printf '%s' '$(call decode,$1)' | sed -E 's%^(https?://[^/]+).*%\1%')
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
	@cat $(call encode,$(URL)).link | \
          perl -MURI::Escape -nE 'say uri_escape($$_) . ".link"' | sed 's/%0A//' | \
          xargs make -j FILTER="$(FILTTER)" $(ARGS)
	@cat $(call encode,$(URL)).link | \
          perl -MURI::Escape -nE 'say uri_escape($$_) . ".link"' | sed 's/%0A//' | \
          xargs cat | sort -u | \
          perl -MURI::Escape -nE 'say uri_unescape($$_) . ".link"' | sed 's/%0A//' | \
          xargs -I{} -P0 make all FILTER="$(FILTTER)" ARGS=$(ARGS) DEPTH=$$(( $(DEPTH) - 1 )) URL='{}'
endif

.PRECIOUS: %.html
%.html:
	curl '$(call decode,$*)' > $@

%.link.all: %.html
	cat $< | \
          ag -o ' href="[^"]+"' | \
          sed -E 's/.*href="([^"]+)"/\1/gi' | \
          sed 's%^/%$(call schema-host,$*)/%' | \
          sed 's%^../%$(call schema-host,$*)/%' | \
          sed 's%^#%#$(call schema-host,$*)%' | \
          sort -u > $@

%.link: %.link.all
	cat $< | grep -E "$(FILTER)" | tee -a $@ > /dev/null

clean:
	rm -f *.html *.link.all *.link
