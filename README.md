> _“Watchtower is officially online...”_

<p align="center">
  <img src="assets/watchtower-banner.jpg" alt="Watchtower" width="800">
</p>

**watchtowerup** is my personal infrastructure configuration, built around **Nix Flakes**, **NixOS**, and **Home Manager** to keep machines and development environments reproducible.

It manages configurations for my home server, virtual machines, containers and personal computers, everything is versioned in Git, while persistent data and secrets are kept separate from the repository.

### Bootstrapping

On non-NixOS Linux, start with multi-user Nix and flakes enabled. Run the command
as the user whose configuration you want to apply. The bootstrap app runs Home
Manager and applies the profile for `user@hostname`.

To bootstrap Home Manager from GitHub:

```sh
nix run github:viniciusdutra314/watchtowerup#bootstrap
```

From the root of a local checkout:

```sh
nix run .#bootstrap
```

On `wt-server`, apply the NixOS configuration from the checkout root:

```sh
sudo nixos-rebuild switch --flake '.'
```

### Chloe — AI Agent

Chloe is the AI companion and development assistant integrated into the Watchtower ecosystem.

The chloe/ directory contains the configuration and customization of AI agents, including reusable skills, behavioral instructions, and workflows for software development, research, and infrastructure management.

> [!NOTE]
> Fun fact: Watchtower is a reference to the TV series Smallville, where Chloe Sullivan operates the Watchtower as a headquarters for coordinating the team.

> [!CAUTION]
> The repository includes an [`AGENTS.md`](AGENTS.md) that makes it practical to edit these configurations with an AI agent. Set up the agent's sandbox to allow edits in the checkout and block it from applying them. Applying changes is a manual step, since activation could let the agent modify its own environment or permissions.
