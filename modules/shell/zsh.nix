{ config, pkgs, lib, ... }:

{
  imports = [ ./themes/nix-shell.nix ];

  # Installs zsh and some plugins.
  home.packages = [
    pkgs.zsh
    pkgs.oh-my-zsh
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
    pkgs.zsh-you-should-use
    pkgs.zsh-nix-shell

    pkgs.lsd
    pkgs.bat
    pkgs.zoxide
  ];

  # Sets up the .zshrc file, with some custom aliases and configuration.
  home.file.".zshrc".text = ''
    export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"

    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
    source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh

    plugins=(git)
    source $ZSH/oh-my-zsh.sh

    alias ls="lsd --group-directories-first -A"
    alias cat="bat -p"
    alias cd="z"

    alias nrs="rebuild -a switch"
    alias nrt="rebuild -a test"
    alias ncg="nix-collect-garbage -d 2>/dev/null | tail -n 1"

    alias credentials-setup="bash ~/nix-config/scripts/credentials/auto-setup.sh";

    alias wifi="bash ~/nix-config/scripts/credentials/wifi.sh";
    alias mema="bash ~/nix-config/scripts/credentials/mema.sh";
    alias edge="bash ~/nix-config/scripts/credentials/edge.sh";
    alias minecraft="bash ~/nix-config/scripts/credentials/minecraft-account.sh";
    alias orcaslicer="bash ~/nix-config/scripts/credentials/orcaslicer.sh";

    alias i="nix-shell -p"
    i () {
      if [[ $# -eq 0 ]]; then
        nix-shell
      else
        nix-shell -p "$@"
      fi
    }

    f () {
      if [[ $# -eq 0 ]]; then
        if [[ -f flake.nix ]]; then
          nix develop
        else
          nix shell
        fi
      else
        nix shell "''${@/#/nixpkgs#}"
      fi
    }

    eval "$(zoxide init zsh)"

    if [[ -n "$IN_NIX_SHELL" ]]; then
      source ~/.oh-my-zsh/custom/themes/nix-shell.zsh-theme
    else
      source ~/.oh-my-zsh/custom/themes/custom.zsh-theme
      cd ~
    fi
  '';
}
