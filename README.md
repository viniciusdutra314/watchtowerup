> _“Watchtower is officially online...”_

<p align="center">
  <img src="assets/watchtower-banner.jpg" alt="Watchtower" width="800">
</p>

**watchtowerup** is my personal infrastructure configuration, built around **Nix Flakes**, **NixOS**, and **Home Manager** to keep machines and development environments reproducible.

It manages configurations for my home server, virtual machines, containers and personal computers, everything is versioned in Git, while persistent data and secrets are kept separate from the repository.

### Bootstrapping

On non-NixOS Linux, start with multi-user Nix and flakes enabled. Home Manager
selects the configuration by `user@hostname`.

```sh
nix shell nixpkgs#git
git clone https://github.com/viniciusdutra314/watchtowerup 
cd watchtowerup/machines
nix develop path:.#bootstrap
home-manager switch --flake path:.
```

### Chloe — AI Agent

Chloe is the AI companion and development assistant integrated into the Watchtower ecosystem.

The chloe/ directory contains the configuration and customization of AI agents, including reusable skills, behavioral instructions, and workflows for software development, research, and infrastructure management.

> [!NOTE]
> Fun fact: Watchtower is a reference to the TV series Smallville, where Chloe Sullivan operates the Watchtower as a headquarters for coordinating the team.
