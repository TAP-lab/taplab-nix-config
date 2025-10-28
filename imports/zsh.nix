{ config, pkgs, ... }:

{   
  # Installs zsh and some useful plugins
  home.packages = [
    pkgs.zsh
    pkgs.oh-my-zsh
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
  ];

  # Defines the zsh configuration file
  home.file.".zshrc".text = ''

    # Enable oh-my-zsh for themes and plugins
    export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"

    # Enables some zsh plugins
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # More oh-my-zsh settings
    plugins=(git)
    source $ZSH/oh-my-zsh.sh

    # Aliases to update the nix config (testing purposes)
    alias nrt="sudo rsync -av --exclude='.git' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild test";
    alias nrs="sudo rsync -av --exclude='.git' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild switch";

    # Alias to pull the lastest configuration from github and update
    alias updatenix="sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)";

    # Custom aliases to pull credentials over LAN
    alias wifi="bash /etc/nixos/scripts/wifi.sh";
    alias mema="bash /etc/nixos/scripts/mema.sh";
    alias edge="bash /etc/nixos/scripts/edge.sh";

    # Use a custom oh-my-zsh theme
    source ~/.oh-my-zsh/custom/themes/custom.zsh-theme
  '';

  # Defines a custom oh-my-zsh theme
  home.file.".oh-my-zsh/custom/themes/custom.zsh-theme".text = ''
    PROMPT="%F{cyan}%n@%f"
    PROMPT+="%{$fg[blue]%}%M "
    PROMPT+="%{$fg[cyan]%}%~%  "
    PROMPT+="%(?:%{$fg[green]%}%1{➜%} :%{$fg[red]%}%1{➜%} )%{$reset_color%}"

    RPROMPT='$(git_prompt_info)'

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}git:(%{$fg[blue]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[cyan]%}) %{$fg[yellow]%}%1{✗%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[cyan]%})"
  '';
}