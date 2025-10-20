{ config, pkgs, ... }:

let
  cacheServer = "192.168.1.220";
  cachePublicKey = "local-cache:WrEu920wGa4xt2v2DjM0x9wf+/KLHb4+qV7tQqQJxw0="; 
in

{   
  # Installs zsh and some useful plugins
  home.packages = with pkgs; [
    zsh
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  # Defines the zsh configuration file
  home.file.".zshrc".text = ''
    export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
    export CACHE_SERVER="${cacheServer}"

    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    plugins=(git)
    source $ZSH/oh-my-zsh.sh

    alias nrt="sudo rsync -av --exclude='.git' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild test";
    alias nrs="sudo rsync -av --exclude='.git' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild switch";
    alias updatenix="sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)";

    function syncstore() {
      sudo nix-collect-garbage -d
      read -s -p "SSH password: " SSHPASS
      echo
      sshpass -p "$SSHPASS" ssh root@$CACHE_SERVER 'nix-collect-garbage -d'
      sshpass -p "$SSHPASS" nix-copy-closure --to root@$CACHE_SERVER $(nix-store -qR /nix/store/*)
      sshpass -p "$SSHPASS" ssh root@$CACHE_SERVER 'nix store sign --all --key-file /root/nix-serve-private --extra-experimental-features nix-command'
    }

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