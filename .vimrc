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

let mapleader = ","
nnoremap <C-p> :FZF<CR>
nnoremap <C-m> :Buffers<CR>
nnoremap <C-Space> :Rg<CR>
map <C-n> :NERDTreeToggle<CR>
nnoremap <leader>ntf :NERDTreeFind<CR>
map Y y$
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

" Next three lines are to enable C-Space to autocomplete, omnicomplete
"inoremap <C-Space> <C-x><C-o>
"imap <buffer> <Nul> <C-Space>
"smap <buffer> <Nul> <C-Space>

" https://github.com/christoomey/vim-tmux-runner
"let g:rspec_runner = \"os_x_iterm\"
"let g:rspec_command = \"VtrSendCommandToRunner! cd $(echo {spec} | awk -F/ '{print F $1}') && rspec $(echo {spec} | cut -d'/' -f2-)\"
"let g:rspec_command = \"VtrSendCommandToRunner! cd $(echo {spec} | awk -F/ '{print F $1}') && export SPEC=$(echo {spec} | cut -d'/' -f2-) && bin/rspec $SPEC\"
"let g:rspec_command = 'VtrSendCommandToRunner! bin/rspec {spec}'
let g:VtrPercentage = 40

" vim-test
"  let test#project_root = "~/code/todo/todo"
let test#strategy = "vimux"
let g:VimuxHeight = "40%"

call plug#begin()
Plug 'christoomey/vim-tmux-navigator'
Plug 'itchyny/lightline.vim'
Plug 'jgdavey/vim-blockle'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/fzf', { 'dir': '~/opt/fzf' }
Plug 'nanotech/jellybeans.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'NLKNguyen/papercolor-theme'
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
    --buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    --buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

    -- Use a loop to conveniently call 'setup' on multiple servers and
    -- map buffer local keybindings when the language server attaches
    local servers = { "standardrb", "solargraph" }
     for _, lsp in ipairs(servers) do
       nvim_lsp[lsp].setup {
     	  on_attach = on_attach,
     	  flags = {
     	    debounce_text_changes = 150,
     	  }
       }
     end
     nvim_lsp['standardrb'].setup {
       on_attach = on_attach,
       flags = {
         debounce_text_changes = 150,
       }
     }

    -- make sure to run `gem install solargraph` and `yard gems`!!!!
    nvim_lsp['solargraph'].setup {
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      },
      settings = {
        solargraph = {
          autoformat = false,
          completion = true,
          diagnostic = false,
          folding = true,
          formatting = true,
          references = true,
          rename = true,
          symbols = true
        }
      }
    }
EOF
