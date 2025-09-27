# personal shell config - not necessary for final build

{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;


    # Enable oh-my-zsh with some plugins and a custom theme
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "colorize" ];
      theme = "custom";
    };


    # Define useful shell aliases
    shellAliases = {
      nrt = "sudo nixos-rebuild test";
      nrs = "sudo nixos-rebuild switch";
      cdnix = "cd /etc/nixos/";
    };

    history.size = 10000;


    # Enable zsh plugins manager zplug with some useful plugins
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
      ];
    };


    # Enable custom theme
    initContent = lib.mkOrder 550 ''
      export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom" 
    '';
  };


  # Custom theme
  home.file.".oh-my-zsh/custom/themes/custom.zsh-theme".text = ''
    PROMPT="%F{cyan}%n@%f"
    PROMPT+="%{$fg[blue]%}%M "
    PROMPT+="%{$fg[cyan]%}%~%  "
    PROMPT+="%(?:%{$fg[green]%}%1{➜%} :%{$fg[red]%}%1{➜%} ) %{$reset_color%}"

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}git:(%{$fg[red]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
  '';
}
