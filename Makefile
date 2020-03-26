SCRIPTS_TO_TEST := aliases apps brew build-caesium build-kernel common devtools files functions gitshit hosts install.sh kronic-build paste server system ssh-copy-id-github.sh telegram wireguard setup/android-sdk.sh setup/common.sh setup/diff-so-fancy.sh setup/gdrive.sh setup/gnome.sh setup/llvm.sh setup/shellcheck.sh setup/shfmt.sh setup/xclip.sh setup/zulu-jdk.sh bash_completions.bash

test:
	@for script in ${SCRIPTS_TO_TEST} ; do \
		echo "Checking $$script..."; \
		shellcheck -x $$script || exit 1; \
	done

autofix:
	@shellcheck -f diff ${SCRIPTS_TO_TEST} | git apply

format:
	@shfmt -w -s -i 2 -ci ${SCRIPTS_TO_TEST}

githook:
	@cp -v shellcheck-hook .git/hooks/pre-push
	@chmod +x .git/hooks/pre-push

install:
	@./install.sh

.PHONY: test
