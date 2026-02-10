{ config, ... }:

{
  home.file.".oh-my-zsh/custom/themes/custom.zsh-theme".text = ''
    PROMPT="%F{#116735}%n@%f"
    PROMPT+="%F{#991A36}%M%f "
    PROMPT+="%F{#116735}%~%f  "
    PROMPT+="%(?:%F{#116735}%1{➜%} :%F{#991A36}%1{➜%} )%f"

    RPROMPT='$(git_prompt_info)'

    ZSH_THEME_GIT_PROMPT_PREFIX="%F{135}git:(%F{133}"
    ZSH_THEME_GIT_PROMPT_SUFFIX="%f "
    ZSH_THEME_GIT_PROMPT_DIRTY="%F{135}) %F{221}%1{✗%}%f"
    ZSH_THEME_GIT_PROMPT_CLEAN="%F{135})%f"
  '';
}