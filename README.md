# Simple Antivirus Daemon

## 1. Overview

This project is a small antivirus written as shell scripts. The daemon watches a folder, and whenever something in it changes, it checks every file. A file is flagged if it has a dangerous extension or contains a dangerous word. Flagged files are copied into a quarantine folder and deleted from the watched folder. A second tool lets you review quarantined files and restore or delete them.

### Folder hierarchy

```text
9311-lab2/
├── antivirusd.sh   # the daemon: watches a folder and quarantines bad files
├── restore.sh      # reviews quarantined files: restore or delete them
├── Makefile        # shortcuts to run the daemon and the restore tool
├── .gitignore      # ignores the two temporary files described below
└── README.md       # this file
```

While the daemon runs, it also creates `directory-info.last` and `directory-info.new` (snapshots of the watched folder). Git ignores them.

The watched folder (`~/test`) and the quarantine folder (`~/quarantine`) are in your home folder, not inside this repo.

## 2. Prerequisites

- Ubuntu Linux
- `make` and `git`. The other tools the scripts use (bash, grep, cp, rm, ls, cmp, head, tail, basename, expr) come with Ubuntu.

Install what is missing:

```bash
sudo apt update
sudo apt install make git
```

The watched folder must exist before you start (the Makefile only creates the quarantine folder):

```bash
mkdir ~/test
```

## 3. How to run

1. Download the project and go into it:

```bash
   git clone https://github.com/saramohamed43/9311-lab2.git
   cd 9311-lab2
```

   If you get "Permission denied" when running the scripts, run `chmod +x antivirusd.sh restore.sh`.

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

   It scans right away and prints:

```text
   infected.txt is malicious and it is DELETED
   malware.exe is malicious and it is DELETED
```

   `safe_file.txt` stays in `~/test`. The two other files are now in `~/quarantine`.

4. The daemon keeps running. Open a second terminal and add another bad file, for example `touch ~/test/another.bat`. Within 5 seconds the first terminal reports it.

5. Stop the daemon with `Ctrl + C`. The `make: *** [Makefile:8: antivirus] Interrupt` message that follows is normal.

6. Review the quarantined files (never run this at the same time as the daemon):

```bash
   make restore
```

   You will see a numbered list of the quarantined files. Type a number to pick a file, then choose:

   - **1**: restore the file back into `~/test` (it was a false positive)
   - **2**: delete the file permanently (it was really malicious)
   - **3**: leave the file in quarantine and go back to the list

   The list repeats until the quarantine is empty, then the tool prints `No malicious files to review.` and stops.

   Note: a restored file will be flagged again the next time the daemon scans, because it still has the same extension or content.

### Settings

The watched folder, the quarantine folder and the scan interval (5 seconds) are variables at the top of the `Makefile`. You can also run the scripts directly:

```bash
./antivirusd.sh <watched_dir> <quarantine_dir> <interval_secs>
./restore.sh <watched_dir> <quarantine_dir>
```

## 4. Where the flagged lists are defined

Both lists are written directly inside the `check_files` function in `antivirusd.sh`:

- **Flagged extensions** (`.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`): in the first `grep` command, around line 17.
- **Flagged keywords** (`virus`, `trojan`, `malware`, `worm`, `ransomware`, case-insensitive): in the second `grep` command, around line 22.