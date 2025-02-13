## install
How to get all this working.

### Install needed apps
On Ubuntu, some of these will be available via `apt`, but most will need to be installed by cloning the git repo.
OSX has some, but not all, available via `brew`. Google 'em.

```
neovim
zsh
oh-my-zsh
asdf
vim-plug
fzf
rg
```

### Ruby dependencies
For Ubuntu, you'll need to install these dependencies in order to build Ruby:
```
# gcc
build-essential
libz
# fiddle
libffi-dev
# psych
libyaml-dev
# readline
libreadline-dev
```

You might also need `libtool`, but `psych` should be covered by `libyaml`.

### Install ruby & gems
To install Ruby:
```
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby latest
asdf global ruby latest
```

To run the LSPs and `standardrb` linter, `gem install` these gems:
```
solargraph
standard
```

### Configure files
Link or copy the files like so.

* `/solargraph` -> `~/.config/solargraph`
  * We want to ignore the `rubocop` rules provided by the Solargraph LSP so we can use `standard` instead

* `.vimrc` -> `~/.config/nvim/init.vim`

* `.zshrc` -> ~/.zshrc`
  * clear out any unused language switching stuff if not using ruby/go

* `.tmux.conf` -> `~/.tmux.conf`
    * make sure to comment out `reattach-to-user-namespace` for WSL/Ubuntu

* `.gitconfig` -> `~/.gitconfig`
  * update any paths, emails etc.
