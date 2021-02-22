SCRIPTS_TO_TEST := aliases apps bash_completions.bash common darwin-init devtools files gitshit hosts install.sh nix paste server shell-init system telegram wireguard setup/00-android_sdk.sh setup/01-adb_multi.sh setup/02-android_udev.sh setup/common.sh scripts/gnome.sh scripts/llvm.sh setup/03-xclip.sh scripts/zulu-jdk.sh

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

home-check:
	cp nixos/home-manager.nix ~/.config/nixpkgs/home.nix
	home-manager build

home-switch:
	cp nixos/home-manager.nix ~/.config/nixpkgs/home.nix
	home-manager switch

darwin-switch:
	cp nixos/darwin-configuration.nix ~/.config/nixpkgs/home.nix
	home-manager switch

.PHONY: test
