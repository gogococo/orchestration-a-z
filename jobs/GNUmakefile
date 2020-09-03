SHELL = bash
SERVICES = carts catalogue frontend infra orders payment shipping user
STOP_SERVICES = $(patsubst %, stop-%, $(SERVICES))

default: all

.PHONY: all
all: $(SERVICES)

.PHONY: stop-all
stop-all: $(STOP_SERVICES)

.PHONY: $(SERVICES)
$(SERVICES):
	nomad run $@.nomad

.PHONY: stop-%
stop-%:
	nomad stop -purge sockshop-$*
