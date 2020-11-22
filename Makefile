SCRIPTS_TO_TEST := aliases apps bash_completions.bash build-kernel common devtools files gitshit hosts install.sh nix paste server shell-init system telegram wireguard setup/android_sdk.sh setup/adb_multi.sh setup/android_udev.sh setup/common.sh scripts/gnome.sh scripts/llvm.sh setup/xclip.sh scripts/zulu-jdk.sh

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

nix-laptop-install:
	@sudo cp -v nixos/laptop-configuration.nix /etc/nixos/configuration.nix
	@sudo nix-channel --update
	@sudo nixos-rebuild switch

nix-laptop-test:
	@sudo cp -v nixos/laptop-configuration.nix /etc/nixos/configuration.nix
	@sudo nix-channel --update
	@sudo nixos-rebuild test

nix-desktop-install:
	@sudo cp -v nixos/desktop-configuration.nix /etc/nixos/configuration.nix
	@sudo nix-channel --update
	@sudo nixos-rebuild switch

nix-desktop-test:
	@sudo cp -v nixos/desktop-configuration.nix /etc/nixos/configuration.nix
	@sudo nix-channel --update
	@sudo nixos-rebuild test

.PHONY: test
