# Moving the Prism Launcher instance between Linux and Windows

Restic stores backups; it does not automatically synchronize the two computers.
After using the instance on one computer, back it up there and restore that
snapshot on the other computer before playing or letting its backup run. Close
Minecraft and Prism Launcher before every backup and restore.

These instructions cover `Fabulously.Optimized.26.3`. The Linux backup also
contains `Fabulously.Optimized.1.21.11`; the restore commands below select only
the 26.3 instance.

## One-time setup

1. Apply the NixOS configuration containing `minecraft.nix`. The
   `restic-backups-minecraft` service backs up instance names relative to the
   Linux `instances` directory and tags new snapshots `prism-instances`.
2. Install Restic on Windows. The Windows machine must be able to reach the
   same REST repository as Linux and have the same repository password.
   In PowerShell, configure these for each session (or set them securely in the
   environment used by your scheduled task):

   ```powershell
   $env:RESTIC_REPOSITORY = 'rest:https://restic-wailord.<your-tailnet-domain>/'
   $env:RESTIC_PASSWORD_FILE = 'C:\path\to\restic-password.txt'
   $instances = 'C:\path\to\PrismLauncher\instances'
   $instance = 'Fabulously.Optimized.26.3'
   ```

   Replace the placeholders with the actual repository URL, a password file
   readable by the task's user, and the Windows Prism Launcher instances
   directory. Do not put the password itself in this document or a command
   history.
3. Configure the Windows scheduled backup to run the Windows backup commands
   below. Its working directory must be `$instances`, even if the task starts
   in a different directory. It must not run before an incoming restore.

### First restore from an existing Linux snapshot

Older snapshots made before this configuration change have absolute paths and
will not have the new tag. On Windows, list snapshots and inspect the Linux
snapshot you want:

```powershell
restic snapshots
restic ls <snapshot-id>
```

Replace `<snapshot-id>` with the actual ID in these and subsequent commands.
Assuming the listed path matches the original Linux path, restore its contents
directly into the Windows instance directory:

```powershell
restic restore '<snapshot-id>:/home/msfjarvis/Games/PrismLauncher/instances/Fabulously.Optimized.26.3' `
  --target (Join-Path $instances $instance)
```

For newer, relative-path snapshots, use the regular restore instructions below.
Confirm the restored instance is in the correct location before opening it.

## Before leaving Linux

Close Minecraft and Prism Launcher, then run the configured backup and check
that the service succeeded:

```sh
sudo systemctl start restic-backups-minecraft.service
sudo systemctl status restic-backups-minecraft.service
sudo restic-minecraft snapshots --tag prism-instances
```

Record the ID of the snapshot just created on Linux. Confirm its contents if
needed with `sudo restic-minecraft ls <snapshot-id>`. The service also runs
retention cleanup, so check its status even if a snapshot appears in the list.

## Restore on Windows

Before the Windows scheduled backup runs, close Minecraft and Prism Launcher.
Use the recorded Linux snapshot ID, not `latest`: the Windows machine may have
created a newer snapshot of its stale files.

```powershell
restic restore '<snapshot-id>:/Fabulously.Optimized.26.3' `
  --target (Join-Path $instances $instance)
```

Check that the restore completed successfully before opening the instance or
enabling the Windows scheduled backup.

## Before leaving Windows

Close Minecraft and Prism Launcher, then run the same commands as the scheduled
backup:

```powershell
Set-Location $instances
restic backup --tag prism-instances $instance
restic snapshots --tag prism-instances
```

Check that the backup succeeded and record the ID of the Windows snapshot just
created. Confirm its contents with `restic ls <snapshot-id>` if needed.

## Restore on Linux

Prevent the Linux timer and any running backup from racing the restore. After
starting Linux, stop the timer and wait for any running backup to finish before
restoring. A persistent timer may already have run at boot, so use the recorded
Windows snapshot ID rather than `latest`.

```sh
sudo systemctl stop restic-backups-minecraft.timer
sudo systemctl status restic-backups-minecraft.service
# If the service is still running, wait for it to finish.
sudo restic-minecraft restore '<snapshot-id>:/Fabulously.Optimized.26.3' \
  --target /home/msfjarvis/Games/PrismLauncher/instances/Fabulously.Optimized.26.3
sudo systemctl start restic-backups-minecraft.timer
```

Only restart the timer after a successful restore. If the restore fails or is
interrupted, leave the timer stopped and retry; an in-place restore may leave a
partially restored instance. Close Minecraft and Prism Launcher during the
restore and check the result before playing.

## Important limitations

- A restore overwrites matching files but **does not remove files deleted on the
  other computer**. Such files can reappear in later backups. Restic's
  `--delete` can remove extra files, but is destructive; read the
  [restore documentation](https://restic.readthedocs.io/en/stable/050_restore.html#deleting-files-not-in-snapshot)
  and test with `--dry-run -vv` and appropriate filters before using it.
- Backups are not conflict resolution. Do not independently play on both
  machines between handoffs. Keep snapshots until you have verified the restore;
  selecting an older snapshot overwrites newer local files.
- Linux filenames, permissions, and symbolic links are not always compatible
  with Windows. Test a full round trip before relying on this for your only copy.
- The first backup after changing the Linux path layout may require a full file
  scan. Existing snapshots remain usable with the old full path.
