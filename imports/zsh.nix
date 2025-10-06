# personal shell config - not necessary for final build but nice to have
# includes update function, would need to be implemented elsewhere if this is not used

{ config, pkgs, lib, ... }:

{
  # Enables zsh for Home Manager
  programs.zsh = {
    enable = true;


    # Enables oh-my-zsh with some plugins and my custom theme
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "colorize" ];
      theme = "custom";
    };

    # Defines the update alias to easily run the update script
    shellAliases = {
      updatenix = "sh <(curl https://raw.githubusercontent.com/clamlum2/taplab-nix-config/main/update.sh)";
    };

    # Sets the history size to a large value
    history.size = 10000;

    # Enables the zplug plugin manager with some useful plugins
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
      ];
    };


    # Enables the custom theme
    initContent = lib.mkOrder 550 ''
      export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom" 
    '';
  };


  # Defines the custom theme, I think I broke the git part
  home.file.".oh-my-zsh/custom/themes/custom.zsh-theme".text = ''
    PROMPT="%F{cyan}%n@%f"
    PROMPT+="%{$fg[blue]%}%M "
    PROMPT+="%{$fg[cyan]%}%~%  "
    PROMPT+="%(?:%{$fg[green]%}%1{➜%} :%{$fg[red]%}%1{➜%} )%{$reset_color%}"

    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}git:(%{$fg[red]%}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
    ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
    ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
  '';
}