export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
plugins=(git rails gnu-utils)

source "/Users/lynkotuby/.gvm/scripts/gvm"
#[[ -s "~/.gvm/scripts/gvm" ]] && source "~/.gvm/scripts/gvm"

# optional multi-lang util

function detect-lang-env {
  if [[ -e go.mod ]]
  then
    gvm use 1.20.2 --default 1> /dev/null
  elif [[ -e .ruby-version ]]
  then
    eval "$(rbenv init - zsh)"
  elif [[ -e build.sbt ]]
  then
    eval "$(jenv init -)"
  fi
}

# https://joshtronic.com/2022/02/27/how-to-run-a-command-after-changing-directories-in-zsh/
autoload -U add-zsh-hook
add-zsh-hook chpwd detect-lang-env

autoload -U colors && colors
autoload -U detect-lang-env && detect-lang-env

# User configuration
export TERM=xterm-256color
bindkey -e

alias v="nvim"
alias g="git"
alias new-uuid="uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n'"
alias update-chromedriver="cd /opt/homebrew/Caskroom/chromedriver/*/chromedriver-mac-arm64/ && xattr -d com.apple.quarantine chromedriver && cd -"

function parse_git_branch {
  name=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ -n $name ]] ; then
    echo "$name "
  fi
}

autoload -U colors && colors

setopt promptsubst
PROMPT='%{$fg[green]%}$(parse_git_branch)%{$reset_color%}%1~ %{$fg[yellow]%}♮%{$reset_color%} '

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# TODO - source company-specific vars in ~/.companyrc here

# suppress direnv output
export DIRENV_LOG_FORMAT=
eval "$(direnv hook zsh)"
