SCRIPTS_TO_TEST := aliases apps build-caesium build-kernel common devtools files functions gitshit kronic-build paste setup.sh server system ssh-copy-id-github.sh telegram setup/common.sh setup/diff-so-fancy.sh setup/gdrive.sh setup/gnome.sh setup/hugo.sh setup/hub.sh setup/llvm.sh setup/nano.sh setup/ripgrep.sh setup/sharkdp.sh setup/shellcheck.sh setup/shfmt.sh setup/xclip.sh bash_completions.bash

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
	@./setup.sh

.PHONY: test
