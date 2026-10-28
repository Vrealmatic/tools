# Script conventions

Every script in this repository follows these rules. Start a new tool by copying [`_template/`](../_template).

## Behaviour

1. **One file, no dependencies on this repo.** A script must work after downloading only that file
   (shared helpers are copied from the template, not sourced).
2. **Three modes**, exactly one required:
   - `--check` – reports the current state, changes nothing, exit `0` = target state, `10` = not yet.
   - `--dry-run` – prints every command and file change it would make, changes nothing.
   - `--apply` – makes the changes.
3. **Idempotent.** Running `--apply` twice gives the same result; the second run changes nothing.
4. **Safe edits.** Before a config file changes, a copy goes to `<file>.bak.<timestamp>`. Files are written only when
   their content actually differs. Prefer drop-in files (`*.d/`) over editing the main config.
5. **Verified sources.** Packages from Ubuntu or from the vendor's signed APT repository (key stored in
   `/etc/apt/keyrings/`, `signed-by=` in the source). No `curl | sh`, no unpinned downloads without a checksum.
6. **Least privilege.** Do not add users to powerful groups (`docker`, `lxd`) and do not open ports unless the guide
   says so and explains why.
7. **Explicit parameters.** Inputs come from flags or environment variables, documented in `--help` and in
   `manifest.json`. No interactive prompts in `--apply` (agents and automation must be able to run it).
8. **Fail early.** `set -Eeuo pipefail`, check OS version and architecture before any change, exit `3` if unsupported.

## Style

- Bash, LF line endings, 2-space indent, `shellcheck` clean.
- Messages in English, short. Prefix: `[check]`, `[plan]`, `[apply]`, `[ok]`, `[warn]`, `[error]`.
- Every tool folder has a README: what it does, link to the guide, parameters, what it changes on disk.

## Link to the guide

- `manifest.json` → `guide` holds the URLs of the guide in every language.
- The guide on vrealmatic.com shows the tag and SHA256 of the tested script.
- One guide ↔ one tool (`ubuntu.docker` on the web ↔ `ubuntu/docker/` here).

## Testing

- CI runs `shellcheck` on every script.
- Before a release: run `--apply` twice and `--check` on a clean VM of every supported version
  (e.g. `multipass launch 24.04`), and record it in the tool README.
