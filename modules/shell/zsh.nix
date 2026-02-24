{ config, pkgs, lib, ... }:

{
  imports = [ ./themes/nix-shell.nix ];

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

    alias nrs="sh ~/nix-config/scripts/rebuild.sh -a switch"
    alias nrt="sh ~/nix-config/scripts/rebuild.sh -a test"
    alias ncg="sudo nix-collect-garbage -d"

    alias wifi="bash ~/nix-config/scripts/credentials/wifi.sh";
    alias mema="bash ~/nix-config/scripts/credentials/mema.sh";
    alias edge="bash ~/nix-config/scripts/credentials/edge.sh";
    alias minecraft="bash ~/nix-config/scripts/credentials/minecraft.sh";

    alias i="nix-shell -p"

    eval "$(zoxide init zsh)"

    if [[ -n "$IN_NIX_SHELL" ]]; then
      source ~/.oh-my-zsh/custom/themes/nix-shell.zsh-theme
    else
      source ~/.oh-my-zsh/custom/themes/custom.zsh-theme
      cd ~
    fi
  '';
}
