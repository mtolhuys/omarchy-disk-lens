.DEFAULT_GOAL := help

.PHONY: help test validate update install dev-install

help:
	@printf '%s\n' \
		'Omarchy Disk Lens development commands:' \
		'  make update       Install the exact current working tree locally' \
		'  make dev-install  Alias-compatible explicit development install' \
		'  make test         Run the source test suite' \
		'  make validate     Test and validate the Omarchy plugin manifest'

test:
	./bin/test

validate: test
	omarchy plugin validate .

# Explicitly mutates the current user's Omarchy session. The script snapshots
# the complete working tree, so committed and uncommitted development changes
# are both represented in the installed plugin.
update: dev-install

# Friendly alias for users who naturally reach for `make install`.
install: dev-install

dev-install:
	./bin/dev-install
