# added this back, managed to work out the issues with wezterm and zsh. 
# could be left in the final config if we want a custom shell setup
# going to keep it in the testing branch for the time being

{ config, pkgs, ... }:

{   
  home.packages = with pkgs; [
    zsh
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];


  home.file.".zshrc".text = ''
    export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
    ZSH_THEME="custom"

    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


    plugins=(git)
    source $ZSH/oh-my-zsh.sh

    alias nrt="sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild test && hyprshade on extravibrance";
    alias nrs="sudo rsync -av --exclude='.git' --exclude='README.md' --exclude='install.sh' ~/nix-config/ /etc/nixos/ && sudo nixos-rebuild switch && hyprshade on extravibrance";
    alias updatenix="sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)";
  '';

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