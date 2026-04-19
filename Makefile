SOURCE_DIR := ./
DEST_DIR := $(HOME)/DEV/repo/skin.nimbus/
RSYNC_OPTS := -avh --delete
EXCLUDE_OPTS := --exclude='.git/' --exclude='.gitignore' --exclude='._*' --exclude='.!*' --exclude='.DS_Store' --exclude='*.pyo' --exclude='*.pyc' --exclude='cache/' --exclude='Thumbs.db'
m ?= ""
SHELL := /bin/bash
.PHONY: all sync sync-media sync-all test_sync status add commit push clean help check_dest check_case
all: help
help:
	@echo "Available targets:"
	@echo "  make sync       - Sync non-media changes to Mac Git repo (fast)"
	@echo "  make sync-media - Sync media changes + repack textures (slow)"
	@echo "  make sync-all   - Sync everything (equivalent to old behavior)"
	@echo "  make status     - Git status in Mac repo"
	@echo "  make add        - Git add in Mac repo"
	@echo "  make commit m=\"Message\" - Commit in Mac repo"
	@echo "  make push       - Git push from Mac repo"
check_dest:
	@if [ ! -d "$(DEST_DIR).git" ]; then echo "ERROR: Git repo not found at $(DEST_DIR)"; exit 1; fi
check_case:
	@python3 scripts/check_case.py "$(SOURCE_DIR)xml"
sync: check_dest check_case
	@rsync $(RSYNC_OPTS) $(EXCLUDE_OPTS) --exclude='media/' --exclude='Textures.xbt' "$(SOURCE_DIR)" "$(DEST_DIR)"
	@echo "Sync complete (non-media)."
sync-media: check_dest
	@MEDIA_CHANGES=$$(rsync $(RSYNC_OPTS) -i $(EXCLUDE_OPTS) --exclude='Textures.xbt' "$(SOURCE_DIR)media/" "$(DEST_DIR)media/" | grep -c '^[<>ch.d]'); \
	if [ "$$MEDIA_CHANGES" -gt 0 ]; then \
		echo "$$MEDIA_CHANGES media file(s) changed, packing textures..."; \
		TexturePacker -dupecheck -input "$(DEST_DIR)media" -output "$(DEST_DIR)media/Textures.xbt"; \
	else \
		echo "No media changes, skipping."; \
	fi
sync-all: sync sync-media
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
