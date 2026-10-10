# Simple Antivirus Daemon

## 1. Overview

This project is a small antivirus written as shell scripts.

- **`antivirusd.sh`** watches a folder. Whenever something in it changes, it scans every file. A file is flagged if it has a dangerous extension or contains a dangerous word. Flagged files are copied into a quarantine folder and deleted from the watched folder.
- **`restore.sh`** lets you review the quarantined files and restore or delete them.
- **`antivirus-cron.sh`** (Bonus 1) does one scan and exits, so cron can run it on a schedule instead of the daemon looping forever.
- **Whitelist** (Bonus 2): a file you restore is remembered as safe and is skipped by future scans.

### What counts as malicious

- **Extension:** the file's final extension is `.exe`, `.bat`, `.vbs`, `.scr` or `.ps1` (lower case, exactly as written). For example, `file.txt.scr` is flagged, but `file.scr.txt` and `file.exec` are not.
- **Keyword:** the file's contents contain `virus`, `trojan`, `malware`, `worm` or `ransomware` anywhere, in any capitalization. For example, `wormhole` is flagged.

### Folder hierarchy

```text
9311-lab2/
├── antivirusd.sh        # the daemon: watches a folder and quarantines bad files
├── restore.sh           # review quarantined files: restore or delete them
├── antivirus-cron.sh    # Bonus 1: one scan per run, meant to be run by 
├── Makefile             # shortcuts: make, make restore
├── .gitignore           # ignores the files created while running
└── README.md            # this file
```

These files are created automatically while the programs run, and git ignores them:

- `directory-info.last` and `directory-info.new`: snapshots of the watched folder.
- `whitelist.txt`: the names of restored files (Bonus 2).
- `cron-job`: the log of the cron job (Bonus 1).

The watched folder (`~/test`) and the quarantine folder (`~/quarantine`) are in the home folder, not inside this repo.

## 2. Prerequisites

- Ubuntu Linux.
- `make` and `git`. Everything else the scripts use (bash, grep, cp, rm, ls, cmp, head, tail, basename, expr) comes with Ubuntu.
- `cron`, only for Bonus 1. It is normally installed already.

Install what is missing:

```bash
sudo apt update
sudo apt install make git cron
```

The watched folder must exist before you start (the Makefile only creates the quarantine folder):

```bash
mkdir ~/test
```

## 3. How to run the daemon and the restore tool

Always start both tools from the project folder (the folder that contains the `Makefile`), because the snapshot files and `whitelist.txt` are created there.

1. Download the project and go into it:

```bash
   git clone https://github.com/saramohamed43/9311-lab2.git
   cd 9311-lab2
```

   If you get "Permission denied" when running a script, run `chmod +x antivirusd.sh restore.sh antivirus-cron.sh`.

2. Create some test files:

```bash
   touch ~/test/malware.exe
   echo "virus" > ~/test/infected.txt
   touch ~/test/safe_file.txt
```

3. Start the daemon:

```bash
   make
```

   It scans right away and prints one line per flagged file:

```text
   infected.txt is malicious and it is DELETED
   malware.exe is malicious and it is DELETED
```

   `safe_file.txt` stays in `~/test`. The other two files are now in `~/quarantine`.

4. The daemon keeps running. Open a second terminal and add another bad file, for example `touch ~/test/another.bat`. Within 5 seconds the first terminal reports it.

5. Stop the daemon with `Ctrl + C`. The `make: *** Interrupt` message that follows is normal.

6. Review the quarantined files with the restore tool. **Never run it at the same time as the daemon.**

```bash
   make restore
```

   Type the number of the file you want, then choose what to do with it:

```text
   Choose a file:
   1: file1.exe
   2: file2.exe
   > 2
   For file2.exe:
   1: Restore this file back into dir (it was a false positive)
   2: Permanently delete this file from malicious_dir (it was genuinely malicious)
   3: Go back
   > 1
   Restored file2.exe to /home/you/test.
```

   - **1** puts the file back into the watched folder and adds its name to the whitelist.
   - **2** deletes the file for good and prints `<file> permanently deleted.`
   - **3** goes back to the list.

   Anything that is not a valid number prints `Invalid choice.` and shows the list again. The list repeats until the quarantine is empty. Then the tool prints `No malicious files to review.` and stops.

### Settings

The watched folder, the quarantine folder and the scan interval (5 seconds) are variables at the top of the `Makefile`. You can also run the scripts directly:

```bash
./antivirusd.sh <watched_dir> <quarantine_dir> <interval_secs>
./restore.sh <watched_dir> <quarantine_dir>
```

## 4. Where the flagged lists are defined

Both lists are written directly inside the `check_files` function in `antivirusd.sh`:

- **Flagged extensions** (`.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`): in the first `grep` command of the function (line 21).
- **Flagged keywords** (`virus`, `trojan`, `malware`, `worm`, `ransomware`, case-insensitive): in the second `grep` command of the function (line 25).

`antivirus-cron.sh` has the same function with the same two lists.

## 5. Bonus 1: Cron job

`antivirus-cron.sh` does the same scan as the daemon, but only once, and then exits. Cron starts it again on a schedule. It does not have the interactive restore loop.

### Before starting

- The cron service must be running:

```bash
  sudo systemctl status cron
```

  It should say `active (running)`. If not, run `sudo systemctl enable --now cron`.
- `~/test` and `~/quarantine` must exist.
- Open `antivirus-cron.sh` and look at the three variables near the top: `whitelist`, `last_file` and `new_file`. Cron starts jobs from your home folder, so they use **full paths**. Change `/home/sara-os/9311-lab2` in each of them to the full path of your own project folder (run `pwd` inside the project to see it).
- Stop the daemon. Never run it together with the cron job.

### Step-by-step setup

1. Make the script executable:

```bash
   chmod +x /home/YOUR_USER/9311-lab2/antivirus-cron.sh
```

2. Test it by hand from your home folder. Put a bad file in `~/test` first (for example `touch ~/test/a.exe`):

```bash
   cd ~
   /home/YOUR_USER/9311-lab2/antivirus-cron.sh /home/YOUR_USER/test /home/YOUR_USER/quarantine
```

   It should report the file. Run it a second time and it should print nothing, because nothing changed.

3. Open your crontab:

```bash
   crontab -e
```

   Choose `nano` if it asks. Add this line at the bottom, replacing `YOUR_USER`:

```text
   * * * * * sleep 23; /home/YOUR_USER/9311-lab2/antivirus-cron.sh /home/YOUR_USER/test /home/YOUR_USER/quarantine >> /home/YOUR_USER/9311-lab2/cron-job 2>&1
```

   - `* * * * *` means every minute.
   - `sleep 23;` waits 23 seconds first, so the scan runs at second 23 of every minute (cron itself cannot schedule seconds).
   - `>> .../cron-job 2>&1` saves everything the script prints, errors included, into a log file.

   Save with `Ctrl + O`, Enter, then exit with `Ctrl + X`.

4. Check that the line was saved:

```bash
   crontab -l
```

5. Test it: run `touch ~/test/cron_test.exe`, wait about a minute and a half, then run:

```bash
   cat /home/YOUR_USER/9311-lab2/cron-job
   ls ~/quarantine
```

   The log should say `cron_test.exe is malicious and it is DELETED`, and the file should be in `~/quarantine`. If the log is empty, run `grep CRON /var/log/syslog` to see whether cron started the job.

6. When you are done, run `crontab -e` and delete the line (do not use `crontab -r`, it deletes every entry).

### Cron expression for the 3rd Friday of the month at 12:31 am

```text
31 0 15-21 * * [ "$(date +\%u)" = 5 ] && /home/YOUR_USER/9311-lab2/antivirus-cron.sh /home/YOUR_USER/test /home/YOUR_USER/quarantine >> /home/YOUR_USER/9311-lab2/cron-job 2>&1
```

- `31 0` is minute 31 of hour 0, which is 12:31 am (cron uses a 24-hour clock).
- `15-21` are the days of the month. The 3rd Friday always falls between the 15th and the 21st.
- Cron runs a job when the day-of-month **or** the weekday matches, not both. So the weekday field is left as `*`, and the command checks that today is a Friday: `date +%u` prints the day of the week as a number, 5 on Fridays. `&&` runs the next command only if the left side succeeded. `\%` is there because `%` has a special meaning inside a crontab, where it is treated as a newline. The backslash tells cron to pass a literal `%` to the shell. Outside crontab you’d write plain `date +%u`.

## 6. Bonus 2: Whitelist

By default, a restored file would be flagged again on the next scan, because its extension or content has not changed. The whitelist fixes this.

**How a file gets added:** when you choose option **1** (restore) in `restore.sh`, the file's name is appended as one line to `whitelist.txt` in the folder you ran the tool from (the project folder, when you use `make restore`).

**How the daemon checks it:** at the start of each file's check, the scan looks for the file's exact name in `whitelist.txt`. If it is there, the file is skipped and none of the rules are applied. Only a whole-line match counts, so whitelisting `a.exe` does not protect `ba.exe`. Both `antivirusd.sh` and `antivirus-cron.sh` do this check.

**It survives restarts:** the list is a file on disk, so it is still respected after you stop and restart the daemon.

**To remove a file from the whitelist:** open `whitelist.txt` and delete its line.