SCRIPTS_TO_TEST := aliases apps build-caesium build-kernel common files functions gitshit hastebin kronic-build
SCRIPTS_TO_TEST += setup.sh server system ssh-copy-id-github.sh telegram setup/bat.sh setup/diff-so-fancy.sh setup/fd.sh
SCRIPTS_TO_TEST += setup/gdrive.sh setup/hub.sh setup/ripgrep.sh setup/shellcheck.sh setup/xclip.sh

test:
		@shellcheck --exclude=SC1090,SC1091 ${SCRIPTS_TO_TEST}

installhook:
		@cp -v shellcheck-hook .git/hooks/pre-commit
		@chmod +x .git/hooks/pre-commit

install:
		@./setup.sh

.PHONY: test