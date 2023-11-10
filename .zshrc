export ZSH="/Users/lynkotuby/.oh-my-zsh"

ZSH_DISABLE_COMPFIX="true"
#ZSH_THEME="robbyrussell"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh
source "/Users/lynkotuby/.gvm/scripts/gvm"
#[[ -s "~/.gvm/scripts/gvm" ]] && source "~/.gvm/scripts/gvm"

# User configuration
export TERM=xterm-256color

alias v="nvim"
alias new-uuid="uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '\n'"

alias r="rake"
alias be="bundle exec"
alias ber="bundle exec rake"

function parse_git_branch {
  name=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ -n $name ]] ; then
    echo "$name "
  fi
}

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

setopt promptsubst
PROMPT='%{$fg[green]%}$(parse_git_branch)%{$reset_color%}%1~ %{$fg[yellow]%}♮%{$reset_color%} '

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# TODO - source company-specific vars in ~/.companyrc here

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

