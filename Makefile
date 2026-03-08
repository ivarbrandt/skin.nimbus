SOURCE_DIR := ./
DEST_DIR := $(HOME)/DEV/repo/skin.nimbus/
RSYNC_OPTS := -avh --delete
EXCLUDE_OPTS := --exclude='.git/' --exclude='.gitignore' --exclude='._*' --exclude='.DS_Store' --exclude='*.pyo' --exclude='*.pyc' --exclude='cache/' --exclude='Thumbs.db'
m ?= ""
SHELL := /bin/bash
.PHONY: all sync test_sync status add commit push clean help check_dest
all: help
help:
	@echo "Available targets:"
	@echo "  make sync       - Sync changes to Mac Git repo ($(DEST_DIR))"
	@echo "  make status     - Git status in Mac repo"
	@echo "  make add        - Git add in Mac repo"
	@echo "  make commit m=\"Message\" - Commit in Mac repo"
	@echo "  make push       - Git push from Mac repo"
check_dest:
	@if [ ! -d "$(DEST_DIR).git" ]; then echo "ERROR: Git repo not found at $(DEST_DIR)"; exit 1; fi
sync: check_dest
	@rsync $(RSYNC_OPTS) $(EXCLUDE_OPTS) "$(SOURCE_DIR)" "$(DEST_DIR)"
	@echo "Sync complete."
test_sync: check_dest
	@rsync $(RSYNC_OPTS) --dry-run $(EXCLUDE_OPTS) "$(SOURCE_DIR)" "$(DEST_DIR)"
status: check_dest
	@git -C "$(DEST_DIR)" status
add: check_dest
	@git -C "$(DEST_DIR)" add .
commit: check_dest
	@if [ -z "$(m)" ]; then echo "Usage: make commit m=\"message\""; exit 1; fi
	@git -C "$(DEST_DIR)" commit -m "$(m)"
push: check_dest
	@git -C "$(DEST_DIR)" push
