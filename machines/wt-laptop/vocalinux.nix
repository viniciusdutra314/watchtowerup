{ config, pkgs, lib, vocalinux, ... }:

let
  upstream = vocalinux.packages.${pkgs.stdenv.hostPlatform.system}.vocalinux;
  # Let the upstream GApps hook add the GtkLayerShell typelib to the wrapper.
  package = upstream.overridePythonAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.gtk-layer-shell ];

    # Sway supports the Wayland virtual keyboard used by wtype.
    preFixup = old.preFixup + ''
      gappsWrapperArgs+=(--set-default VOCALINUX_FORCE_BACKEND wtype)
    '';
  });
  executable = lib.getExe package;
in
{
  programs.vocalinux = {
    enable = true;
    inherit package;
  };

  # The Vocalinux wrapper already includes these. Expose them for session use.
  home.packages = [ pkgs.wtype pkgs.wl-clipboard ];

  wayland.windowManager.sway.config = {
    startup = [ { command = "${executable} --start-minimized"; } ];

    keybindings = lib.mkOptionDefault {
      "--no-repeat ${config.wayland.windowManager.sway.config.modifier}+Shift+v" =
        "exec --no-startup-id ${executable} --toggle";
    };
  };
}
