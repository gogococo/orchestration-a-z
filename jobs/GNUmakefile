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
	nomad run \
		-ca-cert=nomad-ca.pem \
		-client-cert=nomad-cli-cert.pem \
		-client-key=nomad-cli-key.pem \
		$@.nomad

.PHONY: stop-%
stop-%:
	nomad stop -purge sockshop-$*
