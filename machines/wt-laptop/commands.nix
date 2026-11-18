
{ config, pkgs, ... }:

let
  iconsDirectory = ../assets/icons;
  calculatorIcon = pkgs.runCommand "over-engineering-calculator.png" {
    nativeBuildInputs = [ pkgs.librsvg ];
  } ''
    rsvg-convert --output "$out" ${iconsDirectory}/over-engineering-calculator.svg
  '';

  terminalLauncher = title: command:
    let
      script = pkgs.writeShellScript "${title}-launcher" ''
        ${command}
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
  programs.vscodium.profiles.default.extensions = [
    (pkgs.vscode-utils.buildVscodeMarketplaceExtension rec {
      mktplcRef = {
        publisher = "jeanp413";
        name = "open-remote-ssh";
        version = "0.6.2";
      };
      vsix = pkgs.fetchurl {
        url = "https://open-vsx.org/api/jeanp413/open-remote-ssh/${mktplcRef.version}/file/jeanp413.open-remote-ssh-${mktplcRef.version}.vsix";
        hash = "sha256-DvlV63bVU2Y74W4noYFPpOyl+XYMvHyVh05IXH8zYkg=";
      };
    })
  ];

  xdg.desktopEntries = {
    over-engineering-calculator = {
      name = "over-engineering-calculator";
      comment = "Calcular em quanto tempo uma automação se paga";
      icon = "${calculatorIcon}";
      exec = terminalLauncher "over-engineering-calculator"
        "${pkgs.python3}/bin/python3 ${../scripts/overenginerring-calculator.py}";
      categories = [ "Utility" "Calculator" ];
      settings.Keywords = "calculadora;calculator;engenharia;automação;overengineering;";
    };

    watchtowerup = {
      name = "watchtowerup";
      comment = "Editar configurações no VSCodium · chloe@wt-devbox · workspace 5";
      icon = "${iconsDirectory}/watchtowerup.svg";
      categories = [ "Development" ];
      settings.Keywords = "watchtower;watchtowerup;vscodium;nix;configuração;";
    };

    wt-home-manager-switch = {
      name = "home-manager";
      comment = "Aplicar a configuração do usuário neste computador";
      icon = "${iconsDirectory}/home-manager.svg";
      exec = terminalLauncher "home-manager" "${config.home.profileDirectory}/bin/home-manager switch";
      categories = [ "System" ];
      settings.Keywords = "home-manager;switch;nix;aplicar;configuração;";
    };

    wt-system-manager-switch = {
      name = "system-manager";
      comment = "Aplicar a configuração do sistema neste computador (solicita senha)";
      icon = "${iconsDirectory}/system-manager.svg";
      exec = terminalLauncher "system-manager" "${config.home.profileDirectory}/bin/system-manager switch --sudo";
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
