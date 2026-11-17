{
  config,
  pkgs,
  lib,
  ...
}:

let
  mod = "Mod4";
in
{
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
      };
      gaps = {
        smartBorders = "on";
        smartGaps = "on";
      };
      input."type:keyboard".xkb_layout = "br";

      output = {
        "*".bg = "${config.watchtower.homeManager.repositoryDirectory}/assets/wallpapers/forest.jpg fill";
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
        "2" = [
          { app_id = "codium"; } 
        ];
        "5" = [ { app_id = "dev.zed.Zed";} ];
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
        "${pkgs.zed-editor}/bin/zeditor --new ssh://chloe@wt-devbox/mnt/wt-core/watchtowerup"
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
