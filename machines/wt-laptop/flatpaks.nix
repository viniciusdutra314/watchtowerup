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
      "com.bitwarden.desktop"
      "com.rafaelmardojai.Blanket"
      "org.gnome.clocks"
      "org.gnome.NetworkDisplays"
      "org.kde.okular"
      "com.obsproject.Studio"
      "org.nickvision.tubeconverter"
      "org.onlyoffice.desktopeditors"
      "com.adilhanney.saber"
      "org.telegram.desktop"
      "org.videolan.VLC"
      "com.rtosta.zapzap"
      "org.zotero.Zotero"
    ];

    uninstallUnmanaged = false;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
