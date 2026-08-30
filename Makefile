.PHONY: test validate dev-install

test:
	./bin/test

validate: test
	omarchy plugin validate .

# Explicitly mutates the current user's Omarchy session. The script snapshots
# the complete working tree, so committed and uncommitted development changes
# are both represented in the installed plugin.
dev-install:
	./bin/dev-install
