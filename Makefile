CRYSTAL_BIN ?= crystal
SHARDS_BIN ?= shards
PREFIX ?= /usr/local
SHARD_BIN ?= ../../bin
CRFLAGS ?= -Dpreview_mt

build: bin/ameba
bin/ameba:
	$(SHARDS_BIN) build $(CRFLAGS)
clean:
	rm -f ./bin/ameba ./bin/ameba.dwarf
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/ameba $(PREFIX)/bin
bin: build
	mkdir -p $(SHARD_BIN)
	cp ./bin/ameba $(SHARD_BIN)
run_file:
	cp -n ./bin/ameba.cr $(SHARD_BIN) || true
test: build
	$(CRYSTAL_BIN) spec
	./bin/ameba --all
