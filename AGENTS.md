# Instructions for AI agents

This repository is the reference implementation of the guides on vrealmatic.com. If a task matches a tool here,
use the tool instead of improvising commands or running a vendor's `install.sh`.

## Find the tool

1. Read `<platform>/manifest.json` (e.g. `ubuntu/manifest.json`). Each entry has `id`, `guide` (URLs per language),
   `script`, `supports` (OS versions) and `params`.
2. Read the guide (append `.md` to its URL for a markdown version, e.g. `https://vrealmatic.com/ubuntu/docker.md`)
   to understand what the script changes and why.

## Run it

1. Use a **tag**, never `main`. Download the script and `SHA256SUMS` from that release and verify the hash.
   Stop if it does not match.
2. Run `--check` first, then `--dry-run`. Show the user the planned changes.
3. Run `--apply` only after the user agrees, or when the user has already approved this exact change.
4. Pass parameters as flags or environment variables listed in `params`. Never edit the script.
5. After `--apply`, run `--check` again. Exit code `0` means the target state is reached.

## Exit codes (all scripts)

| Code | Meaning |
|---|---|
| 0 | OK / already in the target state |
| 1 | Error, nothing or only part was changed (see log) |
| 2 | Wrong usage or missing parameter |
| 3 | Unsupported system (OS, version, architecture) |
| 10 | `--check` only: system is not in the target state |

## Do not

- Do not run anything with `curl … | bash`.
- Do not skip `--dry-run` on a server you did not set up.
- Do not "fix" a failing script by editing it. Report the output to the user.
