Keep changes scoped to the user's request. For configuration tasks, edit the
declarative files in this checkout and validate them without applying them.

## Validate configuration changes

- Run `nix flake check . --no-build` from the repository root. This is the
  evaluation check that CI runs on push.
- Build the affected outputs with `nix build --no-link '.#checks.x86_64-linux.<check-name>'`.
  The flake exposes `home-<user>@<host>` checks for Home Manager and
  `nixos-<host>` checks for NixOS. Building these outputs produces artifacts in
  the Nix store without activating them.

## Leave activation to the user

Do not apply, activate, or install configurations on the host, in the agent's
own environment or sandbox, or on a remote machine. Do not use
`home-manager switch`, `nixos-rebuild switch`, `nixos-rebuild test`,
`nixos-rebuild boot`, `nix run .#bootstrap`, or any equivalent script or
activation command. Do not elevate privileges or change sandbox settings to
bypass this boundary.

Show the resulting Git diff and the validation results to the user. The user
reviews the diff and decides whether to apply it manually with
`home-manager switch` or `nixos-rebuild switch`, as appropriate.
