{
  config,
  pkgs,
  lib,
  ...
}:

let
  mod = "Mod4";
  watchtowerTitle = "(^| [-—] |/)(?i:watchtowerup)($|[[:space:]])";
  watchtowerWindow = {
    app_id = "^codium$";
    title = watchtowerTitle;
  };
  watchtowerCriteria = ''[app_id="${watchtowerWindow.app_id}" title="${watchtowerWindow.title}"]'';
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  moveWatchtowerWindow = "move container to workspace number 5";
  openWatchtower = "${pkgs.vscodium}/bin/codium --ozone-platform=wayland --folder-uri vscode-remote://ssh-remote+wt-devbox/mnt/wt-core/watchtowerup";
  watchtowerLauncher = pkgs.writeShellScript "open-watchtowerup" ''
    if [ -z "$SWAYSOCK" ]; then
      exec ${openWatchtower}
    fi

    if ${swaymsg} --quiet '${watchtowerCriteria} ${moveWatchtowerWindow}, focus'; then
      exit 0
    fi

    exec ${swaymsg} --quiet 'workspace --no-auto-back-and-forth number 5; exec ${openWatchtower} --new-window'
  '';
in
{
  home.packages = [ pkgs.nwg-displays ];

  xdg.desktopEntries.watchtowerup.exec = "${watchtowerLauncher}";

  xdg.configFile."xdg-desktop-portal/sway-portals.conf".text = ''
    [preferred]
    default=gtk
    org.freedesktop.impl.portal.Screenshot=wlr
    org.freedesktop.impl.portal.ScreenCast=wlr
  '';
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        "icons-enabled" = true;
        width = 45;
        lines = 10;
        "horizontal-pad" = 16;
        "vertical-pad" = 12;
        "inner-pad" = 10;
        "line-height" = 22;
        border-radius = 12;
      };

      colors = {
        background = "1e1e2ee6";
        text = "cdd6f4ff";
        prompt = "89b4faff";
        placeholder = "6c7086ff";
        input = "cdd6f4ff";
        match = "f9e2afff";
        selection = "313244ff";
        "selection-text" = "cdd6f4ff";
        "selection-match" = "f38ba8ff";
        border = "89b4faff";
      };

      border = {
        width = 2;
      };
    };
  };
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    systemd.enable = true;

    config = {
      modifier = mod;
      terminal = "ghostty";
      menu = "${pkgs.fuzzel}/bin/fuzzel";
      workspaceLayout = "tabbed";
      bars = [ ];
      window = {
        titlebar = false;
        border = 3;
        hideEdgeBorders = "--i3 both";
        commands = [
          {
            # O título pode chegar depois que a janela remota for criada.
            criteria = watchtowerWindow;
            command = moveWatchtowerWindow;
          }
        ];
      };
      gaps = {
        smartBorders = "on";
        smartGaps = "on";
      };
      input."type:keyboard".xkb_layout = "br";

      output = {
        "*".bg = "${../assets/wallpapers/forest.jpg} fill";
        "eDP-1" = {
          mode = "1920x1080@60Hz";
          position = "0 0";
        };
        "HDMI-A-2" = {
          mode = "1920x1080@144Hz";
          position = "1920 0";
        };
      };

      bindswitches = {
        "lid:on" = {
          locked = true;
          reload = true;
          action = "output eDP-1 disable; output HDMI-A-2 position 0 0";
        };

        "lid:off" = {
          locked = true;
          reload = true;
          action = "output eDP-1 enable; output HDMI-A-2 position 1920 0";
        };
      };

      assigns = {
        "1" = [
          { app_id = "org.mozilla.firefox"; }
          { app_id = "ai-voice-usage"; }
        ];
        "2" = [ { app_id = "codium"; } ];
        "9" = [ { app_id = "org.mozilla.thunderbird"; } ];
        "10" = [
          { app_id = "org.telegram.desktop"; }
          { app_id = "com.rtosta.zapzap"; }
          { app_id = "spotify"; }
        ];
      };

      startup = map (command: { inherit command; }) [
        "firefox"
        "flatpak run org.mozilla.thunderbird"
        "Telegram"
        "zapzap"
        "ai-voice-usage"
        openWatchtower
      ];

      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec env GTK_IM_MODULE=simple ghostty --gtk-single-instance=false";
        "${mod}+q" = "kill";
        "${mod}+Shift+q" = null;
        "Print" = "exec flameshot gui";
        "${mod}+z" = "exec woomer";
        "${mod}+Shift+p" = "exec swaymsg -t command";
      };
    };

    extraConfig = ''
      set $mod ${mod}
      exec ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      exec swayidle -w \
        timeout 1800 'swaylock -f' \
        timeout 1800 'systemd-ac-power || systemctl suspend' \
        before-sleep 'swaylock -f'
    '';
  };
}
