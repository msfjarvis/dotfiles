# lazy-bash

Collection of little bash hacks and utilities I use frequently

 - functions.bash -- `source functions.bash` from your bashrc or bash_profiles and utilise the nifty functions in the script.

 - build-XOS.sh -- A build script geared towards unattended builds of [halogenOS](https://github.com/halogenOS) utilising the [Telegram](https://telegram.org/) bot [API](https://core.telegram.org/bots/api) for notifying the user about current build status.

 - xg.bash -- `source xg.bash` to add the xg command for handling gerrit related tasks like adding the gerrit remote to repositories and pushing to them

 - rom_flasher.bash -- Populate the `zips` array in the script with files which will be pushed to `/external_sd` and then flashed. Also supports wiping partitions if you're using twrp
