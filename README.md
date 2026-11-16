> _“Watchtower is officially online...”_

<p align="center">
  <img src="assets/watchtower-banner.jpg" alt="Watchtower" width="800">
</p>

**watchtowerup** is my personal infrastructure configuration, built around **Nix Flakes**, **NixOS**, and **Home Manager** to keep machines and development environments reproducible.

It manages configurations for my home server, virtual machines, and personal computers. The server also hosts docker containers, with declarative configurations for easy deployment and maintenance. Everything is versioned in Git, while persistent data and secrets are kept separate from the repository.

### Bootstrapping

On non-NixOS Linux, start with multi-user Nix, flakes enabled,
and systemd. The shared checkout lives at `/mnt/wt-core/watchtowerup`.

```sh
nix shell nixpkgs#git
git clone https://github.com/viniciusdutra314/watchtowerup /mnt/wt-core/watchtowerup
cd /mnt/wt-core/watchtowerup/machines
nix develop path:.#bootstrap
home-manager switch --flake path:.
system-manager switch --sudo
exit
```
Both managers remain installed after bootstrap. In a new login session, apply
changes from any directory. Home Manager selects by `user@hostname`;
System Manager selects by hostname:

```sh
home-manager switch
system-manager switch --sudo
```

System Manager requests administrator privileges when applying system changes.

### Chloe — AI Agent

Chloe is the AI companion and development assistant integrated into the Watchtower ecosystem.

The chloe/ directory contains the configuration and customization of AI agents, including reusable skills, behavioral instructions, and workflows for software development, research, and infrastructure management.

> [!NOTE]
> Fun fact: Watchtower is a reference to the TV series Smallville, where Chloe Sullivan operates the Watchtower as a headquarters for coordinating the team.
