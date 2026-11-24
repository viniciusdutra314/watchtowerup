{ pkgs, lib, ... }:

let
  icon = glyph: "<span font_family='Font Awesome 7 Free Solid'>${glyph}</span>";

  watchtowerStatus = pkgs.writeShellScript "watchtower-status" ''
    if ! status="$(${pkgs.coreutils}/bin/timeout 2s ${pkgs.tailscale}/bin/tailscale status --json 2>/dev/null)" ||
      ! echo "$status" | ${pkgs.jq}/bin/jq -e '.BackendState == "Running"' >/dev/null 2>&1; then
      echo '{"text":"WT ?","class":"unknown","tooltip":"Tailscale indisponível"}'
    elif ! echo "$status" | ${pkgs.jq}/bin/jq -e \
      'any(.Peer[]?; .HostName == "watchtower")' >/dev/null 2>&1; then
      echo '{"text":"WT ?","class":"unknown","tooltip":"Watchtower ausente da lista de peers do Tailscale"}'
    # A resposta via DERP também confirma conectividade; Online só reflete o control plane.
    elif ${pkgs.coreutils}/bin/timeout 3s ${pkgs.tailscale}/bin/tailscale ping \
      --c 2 --timeout 1s --until-direct=false watchtower \
      >/dev/null 2>&1; then
      echo '{"text":"WT ●","class":"online","tooltip":"Watchtower respondeu ao ping do Tailscale"}'
    else
      echo '{"text":"WT ●","class":"offline","tooltip":"Watchtower não respondeu ao ping do Tailscale"}'
    fi
  '';
in
{
  home.packages = [ pkgs.dejavu_fonts pkgs.font-awesome ];
  fonts.fontconfig.enable = true;

  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 34;
      spacing = 6;

      modules-left = [ "sway/workspaces" ];
      modules-center = [ "mpris" ];
     mpris = {
  format = "{status_icon} {title} — {artist}";
  "format-paused" = "{status_icon} {title} — {artist}";

  "status-icons" = {
    playing = "♫";
    paused = "⏸";
    stopped = "⏹";
  };

  "max-length" = 45;
  "hide-on-paused" = false;

  "ignored-players" = [ "firefox" ];
};

      modules-right = [
        "custom/watchtower"
        "cpu"
        "memory"
        "pulseaudio"
        "power-profiles-daemon"
        "battery"
        "tray"
        "clock#date"
        "clock#time"
      ];

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
      };

      "sway/window".max-length = 40;

      "custom/watchtower" = {
        exec = watchtowerStatus;
        return-type = "json";
        interval = 5;
      };

      cpu = {
        format = "${icon ""} {usage}%";
        interval = 5;
      };

      memory = {
        format = "${icon ""} {percentage}%";
        interval = 10;
      };

      pulseaudio = {
        format = "${icon "{icon}"} {volume}%";
        format-muted = "${icon ""} Mute";
        format-icons.default = [
          ""
          ""
          ""
        ];
        scroll-step = 5;
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };

      "power-profiles-daemon" = {
        format = icon "{icon}";
        tooltip-format = "Perfil de energia: {profile}";
        format-icons = {
          "power-saver" = "";
          balanced = "";
          performance = "";
        };
      };

      battery = {
        format = "${icon "{icon}"} {capacity}%";
        format-charging = "${icon " {icon}"} {capacity}%";
        format-plugged = "${icon " {icon}"} {capacity}%";
        format-full = "";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
        interval = 5;
        tooltip-format = "{timeTo}";
      };

      tray.spacing = 8;

      "clock#date" = {
        format = "${icon ""} {0:%d/%m/%Y}";
        tooltip-format = "{:%A, %d de %B de %Y}";
        on-click = "flatpak run org.mozilla.thunderbird -calendar";
      };

      "clock#time" = {
        format = "${icon ""} {0:%H:%M}";
        tooltip = false;
        on-click = "flatpak run org.mozilla.thunderbird -calendar";
      };
    };

    style = ''
      /* Catppuccin Frappé */
      @define-color base #303446;
      @define-color text #c6d0f5;
      @define-color subtext0 #a5adce;
      @define-color surface1 #51576d;
      @define-color blue #8caaee;
      @define-color mauve #ca9ee6;
      @define-color peach #ef9f76;
      @define-color green #a6d189;
      @define-color red #e78284;
      @define-color yellow #e5c890;

      * {
        font-family: "DejaVu Sans", sans-serif;
        font-size: 12px;
        border: none;
      }

      window#waybar {
        background-color: @base;
        color: @text;
        border-bottom: 1px solid @surface1;
      }

      #workspaces button {
        padding: 0 8px;
        background-color: transparent;
        color: @subtext0;
      }

      #workspaces button.active,
      #workspaces button.focused {
        background-color: @blue;
        color: @base;
      }

      #window { color: @subtext0; }

      #window, #cpu, #memory, #pulseaudio,
      #power-profiles-daemon, #battery, #tray,
      #clock, #custom-watchtower {
        padding: 0 7px;
      }

      #cpu { color: @blue; }
      #memory { color: @mauve; }
      #pulseaudio { color: @peach; }

      #battery { color: @green; }
      #battery.charging { color: @yellow; }
      #battery.plugged { color: @blue; }
      #battery.full {
       padding: 0;
       margin: 0;
      }

      #power-profiles-daemon.power-saver { color: @green; }
      #power-profiles-daemon.balanced { color: @blue; }
      #power-profiles-daemon.performance { color: @peach; }

      #clock { color: @text; }
      #clock.time {
        border-left: 1px solid @surface1;
        margin-left: 5px;
        padding-left: 12px;
      }

      #custom-watchtower.online { color: @green; }
      #custom-watchtower.offline { color: @red; }
      #custom-watchtower.unknown { color: @yellow; }
    '';
  };

  wayland.windowManager.sway.config = {
    bars = lib.mkForce [ ];
    startup = [
      { command = "${pkgs.waybar}/bin/waybar"; }
    ];
  };
}
