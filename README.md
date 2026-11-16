> _“Watchtower is officially online...”_

<p align="center">
  <img src="assets/watchtower-banner.jpg" alt="Watchtower" width="800">
</p>

**watchtowerup** is my personal infrastructure configuration, built around **Nix Flakes**, **NixOS**, and **Home Manager** to keep machines and development environments reproducible.

It manages configurations for my home server, virtual machines, and personal computers. The server also hosts docker containers, with declarative configurations for easy deployment and maintenance. Everything is versioned in Git, while persistent data and secrets are kept separate from the repository.

### Bootstrapping

Should work on any reasonable Linux distribution with Nix installed and flakes enabled.
Home Manager does not need to be installed beforehand (hence the bootstrapping). The configuration is
selected automatically by `user@hostname`.

We use NFS and virtiofs to share a single physical checkout across PCs and VMs,
always at `/mnt/wt-core/watchtowerup` (This is our **single source of truth**)

```sh
nix shell nixpkgs#git
git clone https://github.com/viniciusdutra314/watchtowerup /mnt/wt-core/watchtowerup
cd /mnt/wt-core/watchtowerup/machines
nix run path:.#home-manager -- switch --flake path:.
```

After bootstrap, run `home-manager switch` from any directory to apply changes.

### Chloe — AI Agent

Chloe is the AI companion and development assistant integrated into the Watchtower ecosystem.

The chloe/ directory contains the configuration and customization of AI agents, including reusable skills, behavioral instructions, and workflows for software development, research, and infrastructure management.

> [!NOTE]
> Fun fact: Watchtower is a reference to the TV series Smallville, where Chloe Sullivan operates the Watchtower as a headquarters for coordinating the team.
