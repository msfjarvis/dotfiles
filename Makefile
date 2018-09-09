SCRIPTS_TO_TEST := build-caesium build-kernel build-twrp aliases apps aliases common functions gitshit hastebin kronic-build

test:
		@shellcheck ${SCRIPTS_TO_TEST}

installhook:
		@cp -v shellcheck-hook .git/hooks/pre-commit
		@chmod +x .git/hooks/pre-commit

.PHONY: test