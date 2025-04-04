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
nnoremap <Leader>qs :call CleanUpRunner()<CR>

function! CleanUpRunner()
  VtrAttachToPane
  VtrKillRunner
endfunction

" Highlight extraneous whitespace
autocmd BufWinEnter * match Error /\s\+$/
autocmd InsertEnter * match Error /\s\+\%#\@<!$/
autocmd InsertLeave * match Error /\s\+$/
autocmd BufWinLeave * call clearmatches()

let g:VtrPercentage = 40

" vim-test
"  let test#project_root = "~/code/todo/todo"
let test#strategy = "vimux"
let g:VimuxHeight = "40%"

call plug#begin()
Plug 'christoomey/vim-tmux-navigator'
Plug 'itchyny/lightline.vim'
Plug 'jgdavey/vim-blockle'
Plug 'junegunn/goyo.vim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nanotech/jellybeans.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'NLKNguyen/papercolor-theme'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'nvim-telescope/telescope-fzf-native.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'preservim/nerdtree'
Plug 'preservim/vimux'
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

let g:fzf_preview_window = ['down:40%', 'ctrl-/']
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

colorscheme jellybeans
let g:rainbow_active = 1
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
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
  colorscheme jellybeans
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

""""""""""" here be dragons
" In the quickfix window, <CR> is used to jump to the error under the
" cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

" https://blog.backtick.consulting/neovims-built-in-lsp-with-ruby-and-rails/

lua << EOF
  -- alternatively, try virtual_lines
  vim.diagnostic.config({virtual_text=true})

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
    buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    --buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    -- buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

  -- run `gem install sorbet` for first-time setup
  nvim_lsp['sorbet'].setup {
    on_attach = on_attach,
    cmd = { "bundle", "exec", "srb", "tc", "--lsp" },
    flags = { debounce_text_changes = 150 }
  }

  nvim_lsp['rubocop'].setup {
    cmd = { "bundle", "exec", "rubocop", "--lsp" },
  }

  require("telescope").setup({
    defaults = {
      layout_strategy = 'flex',
      layout_config = {
        horizontal = { preview_cutoff = 1 },
        vertical = { preview_cutoff = 1 },
      },
    },
  })
EOF
