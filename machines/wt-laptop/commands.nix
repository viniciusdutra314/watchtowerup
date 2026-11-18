
{ config, pkgs, ... }:

let
  iconsDirectory = ../assets/icons;

  switchLauncher = title: command:
    let
      script = pkgs.writeShellScript "${title}-switch" ''
        ${config.home.profileDirectory}/bin/${command}
        result=$?
        printf '\nComando finalizado (código %s).\n' "$result"
        read -r -p 'Pressione Enter para fechar… ' || true
        exit "$result"
      '';
    in
    "${pkgs.ghostty}/bin/ghostty --gtk-single-instance=false --title=${title} -e ${script}";

  confirm = label: command:
    pkgs.writeShellScript "wt-confirm-action" ''
      choice="$(
        printf '%s\n' "Cancelar" "Confirmar" |
          ${pkgs.fuzzel}/bin/fuzzel \
            --dmenu \
            --prompt "${label}? " \
            --lines 2
      )" || exit 0

      [ "$choice" = "Confirmar" ] || exit 0
      exec ${command}
    '';
in
{
  xdg.desktopEntries = {
    watchtowerup = {
      name = "watchtowerup";
      comment = "Editar configurações no Zed · chloe@wt-devbox · workspace 5";
      icon = "${iconsDirectory}/watchtowerup.svg";
      exec = "${pkgs.zed-editor}/bin/zeditor ssh://chloe@wt-devbox/mnt/wt-core/watchtowerup";
      categories = [ "Development" ];
      settings.Keywords = "watchtower;watchtowerup;zed;nix;configuração;";
    };

    wt-home-manager-switch = {
      name = "home-manager";
      comment = "Aplicar a configuração do usuário neste computador";
      icon = "${iconsDirectory}/home-manager.svg";
      exec = switchLauncher "home-manager" "home-manager switch";
      categories = [ "System" ];
      settings.Keywords = "home-manager;switch;nix;aplicar;configuração;";
    };

    wt-system-manager-switch = {
      name = "system-manager";
      comment = "Aplicar a configuração do sistema neste computador (solicita senha)";
      icon = "${iconsDirectory}/system-manager.svg";
      exec = switchLauncher "system-manager" "system-manager switch --sudo";
      categories = [ "System" ];
      settings.Keywords = "system-manager;switch;nix;sudo;aplicar;configuração;";
    };

    wt-shutdown = {
      name = "shutdown";
      icon = "system-shutdown";
      exec = "${confirm "Desligar" "${pkgs.systemd}/bin/systemctl poweroff"}";
      categories = [ "System" ];
      settings.Keywords = "poweroff;shutdown;energia;";
    };

    wt-reboot = {
      name = "reboot";
      icon = "system-reboot";
      exec = "${confirm "Reiniciar" "${pkgs.systemd}/bin/systemctl reboot"}";
      categories = [ "System" ];
      settings.Keywords = "restart;reboot;energia;";
    };

    wt-suspend = {
      name = "suspend";
      icon = "system-suspend";
      exec = "${pkgs.systemd}/bin/systemctl suspend";
      categories = [ "System" ];
      settings.Keywords = "sleep;suspend;energia;";
    };

    wt-logout = {
      name = "logout";
      icon = "system-log-out";
      exec = "${confirm "Sair do Sway" "${pkgs.sway}/bin/swaymsg exit"}";
      categories = [ "System" ];
      settings.Keywords = "logout;sair;energia;";
    };
  };

  programs.fuzzel.settings.main.fields =
    "filename,name,generic,keywords";
}
