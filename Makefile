SCRIPTS_TO_TEST := aliases apps build-caesium build-kernel common devtools files functions gitshit hastebin kronic-build
SCRIPTS_TO_TEST += setup.sh server system ssh-copy-id-github.sh telegram setup/diff-so-fancy.sh setup/gdrive.sh setup/hugo.sh
SCRIPTS_TO_TEST += setup/hub.sh setup/llvm.sh setup/nano.sh setup/ripgrep.sh setup/sharkdp.sh setup/shellcheck.sh setup/xclip.sh
SCRIPTS_TO_TEST += setup/zulu-jdk.sh

test:
		@shellcheck --exclude=SC1090,SC1091 ${SCRIPTS_TO_TEST}

installhook:
		@cp -v shellcheck-hook .git/hooks/pre-commit
		@chmod +x .git/hooks/pre-commit

install:
		@./setup.sh

.PHONY: test