SCRIPTS_TO_TEST := aliases apps bash_completions.bash brew build-caesium build-kernel common devtools files gitshit hosts install.sh kronic-build paste server shell-init system ssh-copy-id-github.sh telegram wireguard setup/android-sdk.sh setup/adb-multi.sh setup/android-sdk.sh setup/android-udev.sh setup/common.sh setup/gdrive.sh setup/gnome.sh setup/llvm.sh setup/xclip.sh setup/zulu-jdk.sh

test: format
	@for script in ${SCRIPTS_TO_TEST} ; do \
		echo "Checking $$script..."; \
		shellcheck -x $$script || exit 1; \
	done

autofix:
	@shellcheck -f diff ${SCRIPTS_TO_TEST} | git apply

format:
	@shfmt -w -s -i 2 -ci ${SCRIPTS_TO_TEST}

githook:
	@ln -sf $$(pwd)/pre-push-hook .git/hooks/pre-push

install:
	@./install.sh

.PHONY: test
