map ; :
nnoremap <C-a> <C-w>

syntax on
set number
set autoindent
set tabstop=2 shiftwidth=2 expandtab
set scrolloff=10
set noshowmode " removes -- INSERT -- etc. modes under statusline

set clipboard=unnamedplus
set backspace=indent,eol,start
set splitbelow
set splitright
set ignorecase
set nofoldenable

let mapleader = ","

nnoremap qq :noh<CR>

" Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-m> <cmd>Telescope buffers<cr>

" nerdtree
map <C-n> :NERDTreeToggle<CR>
nnoremap <leader>ntf :NERDTreeFind<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" vim-test mappings
nnoremap <Leader>fs :TestFile<CR>
nnoremap <Leader>ns :TestNearest<CR>
nnoremap <Leader>ls :TestLast<CR>
nnoremap <Leader>as :TestSuite<CR>
nnoremap <Leader>rr :TestVisit<CR>

" Highlight extraneous whitespace
autocmd BufWinEnter * match Error /\s\+$/
autocmd InsertEnter * match Error /\s\+\%#\@<!$/
autocmd InsertLeave * match Error /\s\+$/
autocmd BufWinLeave * call clearmatches()

" vim-test
"  let test#project_root = "~/code/todo/todo"
let test#strategy = "vimux"
let g:VimuxHeight = "40%"

" vim-rails: direct :A / alt file to spec instead of test
let g:rails_projections = {
      \  'app/*.rb': {
      \     'alternate': 'spec/{}_spec.rb',
      \     'type': 'source'
      \   },
      \  'spec/*_spec.rb': {
      \     'alternate': 'app/{}.rb',
      \     'type': 'test'
      \   },
      \}

" install vim-plug if it doesn't already exist
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'christoomey/vim-tmux-navigator'
Plug 'itchyny/lightline.vim'
Plug 'jgdavey/vim-blockle'
Plug 'junegunn/goyo.vim'
Plug 'MunifTanjim/nui.nvim'
Plug 'rktjmp/lush.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'NLKNguyen/papercolor-theme'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '*' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'main', 'do': ':TSUpdate'}
Plug 'preservim/nerdtree'
Plug 'preservim/vimux'
Plug 'rebelot/kanagawa.nvim'
Plug 'RRethy/nvim-treesitter-endwise'
Plug 'tpope/vim-bundler'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'luochen1990/rainbow'
Plug 'vim-ruby/vim-ruby'
Plug 'vim-test/vim-test'
call plug#end()

let g:rainbow_active = 1
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ] ]
      \ },
      \ }

" https://github.com/junegunn/goyo.vim
let g:goyo_width = 100
function! s:goyo_enter()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif
  set noshowcmd
  set scrolloff=999
  colorscheme papercolor
endfunction

function! s:goyo_leave()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif
  set showcmd
  set scrolloff=5
  colorscheme kanagawa
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

""""""""""" here be dragons
" In the quickfix window, <CR> is used to jump to the error under the
" cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

" https://blog.backtick.consulting/neovims-built-in-lsp-with-ruby-and-rails/

lua << EOF
  -- alternatively, try virtual_text
  vim.diagnostic.config({virtual_lines=true})

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    --Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Mappings.
    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-i>', vim.lsp.buf.signature_help, opts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
    -- vim.keymap.set('n', '<leader>a', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    --vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>a', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)
    -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
    -- vim.keymap.set("n", "<space>f", vim.lsp.buf.format, opts)
  end

  -- run `gem install sorbet` for first-time setup
  vim.lsp.config('sorbet', {
    on_attach = on_attach,
    cmd = { "bundle", "exec", "srb", "tc", "--lsp"},
    flags = { debounce_text_changes = 150 }
  })

  vim.lsp.config('rubocop', {
    cmd = { "bundle", "exec", "rubocop", "--lsp" },
  })

  -- run `npm install -g @ember-tooling/ember-language-server` for first-time setup
  vim.lsp.config('ember', {
    on_attach = on_attach,
    cmd = { "ember-language-server", "--stdio" },
    filetypes = { "handlebars", "typescript", "javascript", "typescript.glimmer", "javascript.glimmer" },
    root_markers = { "ember-cli-build.js", ".git" },
  })

  -- run `go install golang.org/x/tools/gopls@latest` for first-time setup
  -- https://github.com/golang/tools/blob/master/gopls/doc/index.md

  vim.lsp.config('gopls', {
    on_attach = on_attach,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
    cmd = {'gopls', '--remote=auto'},
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
  })

  -- run `brew install terraform`
  vim.lsp.enable({'sorbet', 'rubocop', 'terraformls', 'ember', 'gopls'})

  require("telescope").setup({
    defaults = {
      layout_strategy = 'vertical',
      layout_config = {
        horizontal = { preview_cutoff = 1 },
        vertical = { preview_cutoff = 1 },
      },
      file_ignore_patterns = { "%.rbi" }, -- compiled sorbet interfaces
      mappings = {
        i = {
          ["<esc>"] = require("telescope.actions").close,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
          ["<C-j>"] = require("telescope.actions").move_selection_next,
        },
      },
    },
    pickers = {
      ["buffers"] = {
        sort_mru = true,
        ignore_current_buffer = true
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      }
    }
  })

  vim.keymap.set("n", "<C-Space>", function()
    require("telescope.builtin").live_grep({
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "-g", "!*_spec.rb",
        "-g", "!*-test.js",
      }
    })
  end)

  vim.keymap.set("n", "<leader>z", function()
    require("telescope.builtin").grep_string({
      default_text = vim.fn.expand("<cword>")
    })
  end)

  local treesitter_languages = {
    "css",
    "glimmer",
    "glimmer_javascript",
    "glimmer_typescript",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "python",
    "ruby",
    "terraform",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
  }

  require("nvim-treesitter").install(treesitter_languages)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "css", "glimmer", "glimmer_javascript", "glimmer_typescript",
      "go", "handlebars", "html", "html.handlebars",
      "javascript", "javascript.glimmer", "javascriptreact",
      "json", "lua", "python", "ruby", "terraform", "terraform-vars",
      "tsx", "typescript", "typescript.glimmer", "typescriptreact",
      "vim", "vimdoc",
    },
    callback = function(event)
      local language = vim.treesitter.language.get_lang(event.match)
      if not language then
        return
      end

      if #vim.api.nvim_get_runtime_file("parser/" .. language .. ".*", false) == 0 then
        vim.notify(
          ("Tree-sitter parser '%s' is not installed yet; run :TSInstall %s."):format(language, language),
          vim.log.levels.WARN
        )
        return
      end

      vim.treesitter.start(event.buf, language)
    end,
  })

  require('telescope').load_extension('fzf')
  vim.opt.cindent = true
  vim.cmd('autocmd FileType ruby setlocal indentkeys-=.')
  vim.cmd("colorscheme kanagawa-wave")

EOF

lua << EOF
  local format_on_save_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_on_save_group,
    pattern = "*.go",
    callback = function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } },
        apply = true,
      })
      vim.lsp.buf.format({ async = false })
    end,
  })
EOF

autocmd BufWritePre *.tfvars lua vim.lsp.buf.format()
autocmd BufWritePre *.tf lua vim.lsp.buf.format()
