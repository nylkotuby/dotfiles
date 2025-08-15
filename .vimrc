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
set lazyredraw
set nofoldenable

let mapleader = ","

" Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-Space> <cmd>Telescope live_grep<cr>
nnoremap <C-m> <cmd>Telescope buffers<cr>
nnoremap <leader><space> <cmd>Telescope grep_string<cr>
nnoremap <leader>z <cmd>Telescope grep_string search=<cr>

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

call plug#begin()
Plug 'adisen99/codeschool.nvim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'itchyny/lightline.vim'
Plug 'jgdavey/vim-blockle'
Plug 'junegunn/goyo.vim'
Plug 'MunifTanjim/nui.nvim'
Plug 'rktjmp/lush.nvim'
"Plug 'nanotech/jellybeans.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'NLKNguyen/papercolor-theme'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'preservim/nerdtree'
Plug 'preservim/vimux'
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
  colorscheme codeschool
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

  local nvim_lsp = require('lspconfig')

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    --Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { noremap=true, silent=true }

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-i>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    -- buf_set_keymap('n', '<leader>a', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    --buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '<leader>a', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    -- buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  -- run `gem install sorbet` for first-time setup
  nvim_lsp['sorbet'].setup {
    on_attach = on_attach,
    cmd = { "bundle", "exec", "srb", "tc", "--lsp"},
    flags = { debounce_text_changes = 150 }
  }

  nvim_lsp['rubocop'].setup {
    cmd = { "bundle", "exec", "rubocop", "--lsp" },
  }

  -- run `brew install terraform`
  nvim_lsp['terraformls'].setup {}

  -- run `npm install -g @ember-tooling/ember-language-server` for first-time setup
  nvim_lsp['ember'].setup {
    on_attach = on_attach,
    cmd = { "ember-language-server", "--stdio" },
    filetypes = { "handlebars", "typescript", "javascript", "typescript.glimmer", "javascript.glimmer" },
    root_dir = require('lspconfig.util').root_pattern("ember-cli-build.js", ".git")
  }

  -- run `go install golang.org/x/tools/gopls@latest` for first-time setup
  -- https://github.com/golang/tools/blob/master/gopls/doc/index.md
  nvim_lsp['gopls'].setup {
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
  }

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
      ["buffers"] = { sort_mru = true, ignore_current_buffer = true },
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

  require('telescope').load_extension('fzf')

  require('nvim-treesitter.configs').setup {
    auto_install = true,
    highlight = {
      enable = true,
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      -- additional_vim_regex_highlighting = false,
      additional_vim_regex_highlighting = { "ruby", "golang" },
    },
    indent = {
      enable = true,
      disable = { "ruby" },
    },
    endwise = {
      enable = true,
    }
  }

  vim.opt.cindent = true
  vim.cmd('autocmd FileType ruby setlocal indentkeys-=.')

  -- codeschool colorscheme config
  vim.o.background = "dark"
  vim.g.codeschool_contrast_dark = "hard"

  -- Load and setup function to choose plugin and language highlights
  require('lush')(require('codeschool').setup({
    plugins = {
      "buftabline",
      "fzf",
      "lsp",
      "lspsaga",
      "nerdtree",
      "telescope",
      "treesitter"
    },
    langs = {
      "css",
      "golang",
      "html",
      "js",
      "json",
      "lua",
      "python",
      "ruby",
      "typescript",
      "viml",
    }
  }))

EOF

lua << EOF
  local format_on_save_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_on_save_group,
    pattern = "*.go",
    callback = function()
    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
    local params = vim.lsp.util.make_range_params(0, enc)
    params.context = {only = {"source.organizeImports"}}
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
    end,
  })
EOF

autocmd BufWritePre *.tfvars lua vim.lsp.buf.format()
autocmd BufWritePre *.tf lua vim.lsp.buf.format()
"autocmd ColorScheme * runtime plugin/diagnostic.vim

