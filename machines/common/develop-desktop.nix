{ pkgs, ... }:
{
  xdg.desktopEntries.ai-voice-usage = {
    name = "AI-VoiceUsage";
    comment = "Track ChatGPT Voice usage over the last 24 hours";
    exec = "ai-voice-usage";
    icon = "appointment-soon";
    categories = [ "Utility" ];
    terminal = false;
  };

  programs.vscodium = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = true;
  };
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    settings = {
      background-opacity = 0.95;
      window-inherit-working-directory = false;
      font-size = 18;
      term = "xterm-256color";
    };
  };
}
