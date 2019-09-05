SCRIPTS_TO_TEST := $(shell cat all_scripts.txt)

test:
		@shellcheck --exclude=SC1090,SC1091 ${SCRIPTS_TO_TEST}

installhook:
		@cp -v shellcheck-hook .git/hooks/pre-commit
		@chmod +x .git/hooks/pre-commit

install:
		@./setup.sh

.PHONY: test