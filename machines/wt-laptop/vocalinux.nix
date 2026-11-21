{ config, pkgs, lib, vocalinux, ... }:

let
  upstream = vocalinux.packages.${pkgs.stdenv.hostPlatform.system}.vocalinux;
  vulkanIcdDir = "${config.targets.genericLinux.gpu.drivers}/share/vulkan/icd.d";
  vulkanDrivers = lib.concatMapStringsSep ":" (name: "${vulkanIcdDir}/${name}") [
    "intel_icd.x86_64.json"
    "nvidia_icd.json"
  ];
  # Let the upstream GApps hook add the GtkLayerShell typelib to the wrapper.
  package = upstream.overridePythonAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.gtk-layer-shell ];

    # Sway supports the Wayland virtual keyboard used by wtype.
    preFixup = old.preFixup + ''
      gappsWrapperArgs+=(--set-default VOCALINUX_FORCE_BACKEND wtype)
      # Use the Home Manager ICDs to avoid loading the Fedora NVIDIA ICD as well.
      gappsWrapperArgs+=(--set-default VK_DRIVER_FILES ${lib.escapeShellArg vulkanDrivers})
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
