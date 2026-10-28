# Vrealmatic public tools

Scripts that set things up the right way. Every script belongs to a guide on [vrealmatic.com](https://vrealmatic.com):
the guide explains **what** happens and **why**, the script does exactly the same steps for you.

Written for people and for AI agents. Agents: read [AGENTS.md](AGENTS.md) first.

## Layout

One top-level folder per platform or product. Each tool has its own folder with the script and a README.

```
ubuntu/                     Ubuntu (server and WSL)        → https://vrealmatic.com/ubuntu
  README.md                 index: tool ↔ guide URL
  manifest.json             machine-readable list of tools
  docker/                   (example)
    install.sh
    README.md
_template/                  starting point for a new tool
docs/CONVENTIONS.md         rules every script must follow
```

New platforms (e.g. `cloudflare/`, `mikrotik/`, `home-assistant/`) follow the same shape.

## How to run a script safely

Never pipe a script from the internet straight into a shell. Download a **tagged release**, check the hash, read it, then run it:

```bash
curl -fsSLO "https://raw.githubusercontent.com/Vrealmatic/tools/v0.1.0/ubuntu/docker/install.sh"
echo "<sha256 from the guide or SHA256SUMS>  install.sh" | sha256sum -c -   # must print: install.sh: OK
less install.sh                   # read it
sudo bash install.sh --check      # what is the current state? (changes nothing)
sudo bash install.sh --dry-run    # what would change? (changes nothing)
sudo bash install.sh --apply      # make the changes
```

The guide on vrealmatic.com always shows the exact tag and hash it was tested with.

## Versions

- Tags `vMAJOR.MINOR.PATCH` cover the whole repository. Every release has `SHA256SUMS` of all scripts.
- `main` is work in progress. Guides and agents always link a tag, never `main`.

## Feedback

Found a better or safer way to do something? Open an issue with the source (official docs, CVE, changelog).
