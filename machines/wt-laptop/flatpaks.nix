{ config, ... }:
{
  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
  ];
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      "org.audacityteam.Audacity"
      "org.mozilla.thunderbird"
      "com.spotify.Client"
      "org.gnome.Boxes"
      "com.github.tchx84.Flatseal"
      "io.github.flattool.Warehouse"
      "com.rustdesk.RustDesk"
    ];

    uninstallUnmanaged = false;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
