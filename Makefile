SCRIPTS_TO_TEST := build-caesium build-kernel build-twrp aliases apps aliases common functions gitshit hastebin kronic-build

test:
		shellcheck ${SCRIPTS_TO_TEST}

.PHONY: test