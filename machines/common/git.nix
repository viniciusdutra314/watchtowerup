{ lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "viniciusdutra314";
        email = "dutravinisousa2@usp.br";
      };
      credential = lib.genAttrs [ "https://github.com" "https://gist.github.com" ] (_: {
        helper = [ "" "${pkgs.gh}/bin/gh auth git-credential" ];
      });
    };
  };
}
