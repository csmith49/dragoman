.PHONY: all
all: interpret

.PHONY: clean
clean:
	rm -r ./_build
	rm ./interpret

interpret: _build/default/bin/interpret.exe
	cp ./_build/default/bin/interpret.exe ./interpret

_build/default/bin/interpret.exe: $(shell find . -name "./lib/**")
	dune build ./bin/interpret.exe