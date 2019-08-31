lib=$(shell find ./lib -iname "**.ml" -o -iname "**.mli")
tests=$(shell find ./tests -iname "*.json")

.PHONY: all
all: interpret

.PHONY: clean
clean:
	@rm -r ./_build
	@rm ./interpret

interpret: _build/default/bin/interpret.exe
	@cp ./_build/default/bin/interpret.exe ./interpret

_build/default/bin/interpret.exe: $(lib)
	@dune build ./bin/interpret.exe

.PHONY: test
test: $(tests)
tests/%.json: interpret
	@printf "%-20.20s %59s\n" $* $(shell ./interpret -t -i $@)