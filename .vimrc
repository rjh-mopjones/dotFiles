"MOP JONES VIMRC VANILLA AS FUCK NO PLUGINS NEEDED JUST VIM 8 "---------------UI--------------------------------------------------
set nocompatible
set nolist
set noswapfile
set autochdir
set autoindent
set bs=2
set noerrorbells
set novisualbell
syntax on
set number relativenumber
set nu rnu
set list listchars=tab:\|\  
set showbreak=--
colorscheme elflord
set tabstop=4
set background=dark
set shiftwidth=4
set hlsearch
set wildmenu


" -----------------MODE KEYS REMAP-----------------------------------
let mapleader=","
imap ii <Esc>
imap jk <Esc>
imap kj <Esc>
vmap <F12> <Esc>
imap <F12> <Esc>
nmap <F12> i
nnoremap <leader>cc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>
nmap <leader>wq :wqa! <CR>
nmap <leader>qa :qa! <CR>

"-----------------SPLITS AND BUFFERS --------------------------------
" make a command that clears all buffers
nmap <Tab> <C-w><C-w>
noremap <leader>vs :vsplit<CR>
noremap <leader>hs :split<CR>
noremap <leader>cs <C-W>q
noremap Z :bn<CR>
noremap X :bp<CR>
noremap <leader>ls :ls<CR>
noremap <C-m> :2winc ><CR>
noremap <C-b> :2winc <<CR>
noremap <C-n> :winc = <CR>
noremap <leader>0 :on<CR>
noremap <C-p> :bd<CR>
noremap <leader>ccb :bp\|bd #<CR>
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"----------------- QUICK VIMRC EDITS -------------------------------
noremap <leader>ev :e $MYVIMRC<CR>
noremap <leader>sv :source $MYVIMRC<cr>


"----------------- NETRW SETTINGS------------------------------------
" need to sort out sizing of window so its always the same size
" stop netrw message buffers opening
" new file needs to open in previous split, not current
" open in current filesystem/ be able to change root directory, basically make the tree
" more intuitive to use


noremap <leader>¬ :Vex <CR>

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15

function! QuitNetrw()
    let flag=1
    for i in range(1, bufnr('$'))
        if getbufvar(i, '&filetype') == "netrw"
            silent exe 'bdelete! ' . i
            let flag=0
        endif
    endfor
    if flag
        normal ,¬
    endif
endfunction

noremap tt :call QuitNetrw()<CR>

augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END
function! NetrwMapping()
    noremap <buffer> tt :call QuitNetrw()<CR>
endfunction

" -----------------TERMINAL TABS----------------------------------
" need to add the option of opening a terminal in a split, and the current buffer, and to
" open a blank tab and the ability to do these commands in the terminal tab


tnoremap <leader>n <C-W>:tabn<CR>
tnoremap <leader>b <C-W>:tabp<CR>
tnoremap <leader>ct <C-W>:bw!<CR>
tnoremap <leader>tr <C-W>:tab terminal<CR> <C-W>:set nobuflisted<CR>
tnoremap <leader>ts <C-W>terminal<CR> <C-W>:set nobuflisted<CR>
tnoremap <leader>tn <C-W>:tabnew<CR>
tnoremap <leader>z <C-W>:bn!<CR>
tnoremap <leader>x <C-W>:bp!<CR>
tnoremap <leader><Tab> <C-W><C-W>
tnoremap <leader>cs <C-W>:close!<CR>
tnoremap <leader>vs <C-W>:vsplit!<CR><leader><z>
tnoremap <leader>hs <C-W>:split!<CR><leader><z>
tnoremap jk <C-W>N
tnoremap kj <C-W>N
noremap <leader>n :tabn<CR>
noremap <leader>b :tabp<CR>
noremap <leader>tc :tabclose!<CR>
noremap <leader>ttr :tab terminal<CR> <C-W>:set nobuflisted<CR>
noremap <leader>tr :terminal<CR> <C-W>:set nobuflisted<CR>
noremap <leader>tn :tabnew<CR>

"--------------------KEYBOARD SHORTCUTS--------------------------
inoremap { {}<Esc>i
inoremap [ []<Esc>i
inoremap ( ()<Esc>i
inoremap " ""<Esc>i
inoremap ' ''<Esc>i
noremap <leader>; A;<Esc>^
nnoremap <leader>p "0p
nnoremap <leader>P "0P
noremap <C-C> :qa!<CR>
noremap <leader>w :w<CR>

nmap <F2> 7j
nmap <F3> 7k
noremap j gj
noremap k gk
nnoremap gV `[v`]
nnoremap <leader>s :mksession!<CR>
noremap <leader>et :set expandtab<CR>
noremap <leader>net :set noexpandtab<CR>
noremap <leader>rt :retab!<CR>


" -----------------LINE AND STATUS BAR COLOURS -----------------
hi StatusLine cterm=reverse ctermfg=DarkBlue ctermbg=white
hi CursorLine cterm=NONE ctermbg=black ctermfg=NONE 


au InsertEnter * set cursorline
au InsertLeave * set nocursorline
hi User1 term=reverse,bold cterm=reverse,bold
set laststatus=2

if has('autocmd')
	au InsertEnter * hi StatusLine cterm=reverse ctermfg=Red ctermbg=white
	au InsertLeave * hi StatusLine cterm=reverse ctermfg=DarkBlue ctermbg=white
else
endif

set showmode
if has ('cmdline_info')
	set showcmd
	set ruler
endif


"------------------NOTETAKING AND MARKDOWN-------------------
" need to make a function that automatically adds next slide with a hotkey
" need to make a a function that inserts a table
" maybe edit syntax highlighting if possible
" remember to link to a github that automatically updates




autocmd BufRead,BufNew *.md set filetype=markdown

"------------------VIM HARDMODE-------------------
" adding in vim hardmode function
"
" hardmode.vim - Vim: HARD MODE!!!
" Authors:      Matt Parrott <parrott.matt@gmail.com>, Xeross <contact@xeross.me>
" Version:      1.0

nnoremap <leader>hm :call HardMode() <CR>
nnoremap <leader>em :call EasyMode() <CR>

if exists('g:HardMode_loaded')
    finish
endif
let g:HardMode_loaded = 1

if !exists('g:HardMode_currentMode')
    let g:HardMode_currentMode = 'easy'
end

if !exists('g:HardMode_level')
    let g:HardMode_level = 'advanced'
end

if !exists('g:HardMode_echo')
    let g:HardMode_echo = 1
end

if !exists('g:HardMode_hardmodeMsg')
    let g:HardMode_hardmodeMsg = "VIM: Hard Mode [ ':call EasyMode()' to exit ]"
end
if !exists('g:HardMode_easymodeMsg')
    let g:HardMode_easymodeMsg = "You are weak..."
end

" Only echo if g:HardMode_echo = 1
fun! HardModeEcho(message)
    if g:HardMode_echo
        echo a:message
    end
endfun

fun! NoArrows()

    nnoremap <buffer> <Left> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> <Right> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> <Up> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> <Down> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> <PageUp> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> <PageDown> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>

    inoremap <buffer> <Left> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    inoremap <buffer> <Right> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    inoremap <buffer> <Up> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    inoremap <buffer> <Down> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    inoremap <buffer> <PageUp> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    inoremap <buffer> <PageDown> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>

    vnoremap <buffer> <Left> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> <Right> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> <Up> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> <Down> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> <PageUp> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> <PageDown> <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>

endfun

fun! NoLetters()

    vnoremap <buffer> h <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> j <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> k <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> l <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> - <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> + <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>

    " Display line motions
    vnoremap <buffer> gj <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    vnoremap <buffer> gk <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> gk <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> gj <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>

    nnoremap <buffer> h <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> j <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> k <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> l <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> - <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>
    nnoremap <buffer> + <Esc>:call HardModeEcho(g:HardMode_hardmodeMsg)<CR>

endfun

fun! NoBackspace()

    set backspace=0

endfun

fun! HardMode()

    call NoArrows()

    if g:HardMode_level != 'wannabe'
        call NoLetters()
        call NoBackspace()
    end

    let g:HardMode_currentMode = 'hard'

    call HardModeEcho(g:HardMode_hardmodeMsg)
endfun

fun! EasyMode()
    set backspace=indent,eol,start

    silent! nunmap <buffer> <Left>
    silent! nunmap <buffer> <Right>
    silent! nunmap <buffer> <Up>
    silent! nunmap <buffer> <Down>
    silent! nunmap <buffer> <PageUp>
    silent! nunmap <buffer> <PageDown>

    silent! iunmap <buffer> <Left>
    silent! iunmap <buffer> <Right>
    silent! iunmap <buffer> <Up>
    silent! iunmap <buffer> <Down>
    silent! iunmap <buffer> <PageUp>
    silent! iunmap <buffer> <PageDown>

    silent! vunmap <buffer> <Left>
    silent! vunmap <buffer> <Right>
    silent! vunmap <buffer> <Up>
    silent! vunmap <buffer> <Down>
    silent! vunmap <buffer> <PageUp>
    silent! vunmap <buffer> <PageDown>

    silent! vunmap <buffer> h
    silent! vunmap <buffer> j
    silent! vunmap <buffer> k
    silent! vunmap <buffer> l
    silent! vunmap <buffer> -
    silent! vunmap <buffer> +

    silent! nunmap <buffer> h
    silent! nunmap <buffer> j
    silent! nunmap <buffer> k
    silent! nunmap <buffer> l
    silent! nunmap <buffer> -
    silent! nunmap <buffer> +

    let g:HardMode_currentMode = 'easy'

    call HardModeEcho(g:HardMode_easymodeMsg)
endfun

fun! ToggleHardMode()
    if g:HardMode_currentMode == 'hard'
        call EasyMode()
    else
        call HardMode()
    end
endfun
