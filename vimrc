set nocompatible               " be iMproved

" filetype off                   " required!
" File Type detection
filetype on
filetype plugin on


"<Leader> key is ,
let mapleader=","

if has("win32")
	let g:os = "win"
else
	let g:os = "unix"
endif

if g:os == "win"
	set shell=C:/cygwin/bin/bash
	set shellcmdflag=--login\ -c
	set shellxquote=\"
	set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
	let $TMP=expand("$HOME/vim-tmp")
	let $TEMP=expand("$HOME/vim-tmp")
endif

" GNOME Terminal supports 256 colors, but doesn't advertise its support. You can override vim's autodetection by putting
" http://askubuntu.com/questions/67/how-do-i-enable-full-color-support-in-terminal
set t_Co=256

" Vundle init
set rtp+=~/.vim/bundle/vundle/

" Require Vundle
try
	call vundle#rc()
catch
	echohl Error | echo "Vundle is not installed. Run 'cd ~/.vim/ && git submodule init && git submodule update'" | echohl None
	"exit
endtry


"{{{ Vundle Bundles!
Bundle 'gmarik/vundle'

" My Bundles here:
"
" repos on github
Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'scrooloose/nerdtree.git'
Bundle 'wincent/Command-T.git'
Bundle 'joonty/vim-phpqa.git'
Bundle 'joonty/vim-sauce.git'
Bundle 'joonty/vdebug.git'
Bundle 'joonty/vim-phpunitqf.git'
Bundle 'joonty/vim-taggatron.git'
"Bundle 'tpope/vim-fugitive.git'
Bundle 'sebastiankessler/phpcomplete.vim.git'
"Bundle 'tpope/vim-rails.git'
Bundle 'greyblake/vim-preview.git'
Bundle 'sjl/gundo.vim.git'
Bundle 'fholgado/minibufexpl.vim.git'
Bundle 'ervandew/supertab.git'
"Bundle 'vim-ruby/vim-ruby.git'
Bundle 'msanders/snipmate.vim.git'
Bundle 'scrooloose/syntastic.git'
" Javascript
Bundle 'leshill/vim-json'
Bundle 'groenewege/vim-less'
Bundle 'pangloss/vim-javascript'
Bundle 'taxilian/vim-web-indent'
Bundle 'itspriddle/vim-jquery'
" HTML
Bundle 'amirh/HTML-AutoCloseTag'
Bundle 'ChrisYip/Better-CSS-Syntax-for-Vim'
" Twig
Bundle 'beyondwords/vim-twig'
Bundle 'altercation/vim-colors-solarized'
"
" PHP namespace
"
Bundle 'arnaud-lb/vim-php-namespace'
"
" Behat
"
Bundle 'veloce/vim-behat'
"
" Refactoring
"
Bundle 'taq/vim-refact'
" vim-scripts repos
Bundle 'taglist.vim'
Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'AutoClose'
"}}}

filetype plugin indent on     " required! 
syntax enable
" colorscheme jc
colorscheme molokai
" colorscheme satori
runtime macros/matchit.vim
let g:EasyMotion_leader_key = '<Space>'

"{{{ Functions

"{{{ Restart rails
command! RestartRails call RestartRails(getcwd())
function! RestartRails(dir)
    let l:ret=system("touch ".a:dir."/tmp/restart.txt")
    if l:ret == ""
        echo "Restarting Rails, like a boss"
    else
        echohl Error | echo "Failed to restart rails - is your working directory a rails app?" | echohl None
    endif
endfunction
"}}}
"{{{ Source vimrc files in a directory
function! SourceAllFiles(dir)
	let l:findop=system("find ".a:dir." -name \"*.vimrc\"")
	let l:sourcenames=split(l:findop,"\n")
	for fname in l:sourcenames
		exec "source ".fname
	endfor
endfunction

call SourceAllFiles($HOME."/.vim/vimrcs")
"}}}
"{{{ Open URL in browser

function! Browser ()
    let line = getline (".")
    let line = matchstr (line, "http[^   ]*")
    exec "!google-chrome ".line
endfunction

"}}}
"{{{ Close quickfix with main window close 
au BufEnter * call MyLastWindow()
function! MyLastWindow()
    " if the window is quickfix go on
    if &buftype=="quickfix"
        " if this window is last on screen quit without warning
        if winbufnr(2) == -1
            quit!
        endif
    endif
endfunction
"}}}
"{{{ Diff current unsaved file
function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
"}}}
"{{{ Clean close
command! Bw call CleanClose(1,0)
command! Bq call CleanClose(0,0)
command! -bang Bw call CleanClose(1,1)
command! -bang Bq call CleanClose(0,1)

function! CleanClose(tosave,bang)
    if a:bang == 1
        let bng = "!"
    else
        let bng = ""
    endif
    if (a:tosave == 1)
        w!
    endif
    let todelbufNr = bufnr("%")
    let newbufNr = bufnr("#")
    if ((newbufNr != -1) && (newbufNr != todelbufNr) && buflisted(newbufNr))
        exe "b".newbufNr
    else
        exe "bnext".bng
    endif

    if (bufnr("%") == todelbufNr)
        new
    endif
    exe "bd".bng.todelbufNr
endfunction
"}}}
"{{{ Run command and put output in scratch
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
    let isfirst = 1
    let words = []
    for word in split(a:cmdline)
        if isfirst
            let isfirst = 0  " don't change first word (shell command)
        else
            if word[0] =~ '\v[%#<]'
                let word = expand(word)
            endif
            let word = shellescape(word, 1)
        endif
        call add(words, word)
    endfor
    let expanded_cmdline = join(words)
    botright new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    call setline(1, 'You entered:  ' . a:cmdline)
    call setline(2, 'Expanded to:  ' . expanded_cmdline)
    call append(line('$'), substitute(getline(2), '.', '=', 'g'))
    silent execute '$read !'. expanded_cmdline
    1
endfunction
"}}}
" {{{ Sass compile
let g:sass_output_file = ""
let g:sass_enabled = 1
let g:sass_path_maps = {}
command! Sass call SassCompile()
autocmd BufWritePost *.scss call SassCompile()
function! SassCompile()
    if g:sass_enabled == 0
      return
    endif
    let curfile = expand('%:p')
    let inlist = 0
    for fpath in keys(g:sass_path_maps)
        if fpath == curfile
            let g:sass_output_file = g:sass_path_maps[fpath]
            let inlist = 1
            break
        endif
    endfor
    if g:sass_output_file == ""
        let g:sass_output_file = input("Please specify an output CSS file: ",g:sass_output_file,"file")
    endif
    let l:op = system("sass --no-cache --style compressed ".@%." ".g:sass_output_file)
    if l:op != ""
        echohl Error | echo "Error compiling sass file" | echohl None
        let &efm="Syntax error: %m %#on line %l of %f%.%#"
        cgete [l:op]
        cope
    endif
    if inlist == 0
        let choice = confirm("Would you like to keep using this output path for this sass file?","&Yes\n&No")
        if choice == 1
            let g:sass_path_maps[curfile] = g:sass_output_file
        endif
    endif
    let g:sass_output_file = ""
endfunction
"}}}
"{{{ Function to use spaces instead of tabs
command! -nargs=+ Spaces call s:use_spaces(<q-args>)
function! s:use_spaces(swidth)
    let l:cwidth = a:swidth
    let &tabstop=l:cwidth
    let &shiftwidth=l:cwidth
    let &softtabstop=l:cwidth
    set expandtab
endfunction
"}}}
"{{{ Function to use tabs instead of spaces
command! Tabs call s:use_tabs()
function! s:use_tabs()
    let &tabstop=4
    let &shiftwidth=4
    let &softtabstop=0
    set noexpandtab
endfunction
"}}}
"{{{ Get a dictionary of expected windows and their numbers
function! GetKnownWindows()
    let l:wins=[] 
    let l:ret = {}
    windo call add(l:wins, [winnr(), bufname('%')]) 
    for list in l:wins
       if list[1] =~ "^.*__Tag_List__$"
           let l:ret['taglist'] = list[0]
       elseif list[1] == "-MiniBufExplorer-"
           let l:ret['minibuf'] = list[0]
       elseif list[1] =~ "NERD_tree_.*"
           let l:ret['nerdtree'] = list[0]
       else
           if !has_key(l:ret,'other')
               let l:ret['other'] = list[0]
           endif
       endif
    endfor
    return l:ret
endfunction
" }}}
" {{{ Reset window arrangement (to the way I like it) if things mess up
function! SetWindows()
	" Always run this, as it refreshes with current dir
	exec 'NERDTree'
    exec 'silent res 500'
    let l:windows = GetKnownWindows()
    if !has_key(l:windows,'other')
        new
    endif
    if !has_key(l:windows,'nerdtree')
        exec 'silent 1wincmd H'
        let l:windows = GetKnownWindows()
    endif
    "if !has_key(l:windows,'taglist')
    "    exec 'TlistToggle'
    "    exec 'silent 1wincmd L'
    "    let l:windows = GetKnownWindows()
    "endif

    if has_key(l:windows,'minibuf')
        exec 'silent '.l:windows['minibuf'].'wincmd W'
        exec 'silent '.l:windows['minibuf'].'wincmd K'
        exec 'silent res 2'
        let l:windows = GetKnownWindows()
    endif

    exec 'silent '.l:windows['nerdtree'].'wincmd W'
    exec 'silent '.l:windows['nerdtree'].'wincmd H'
    exec 'silent 500winc < | 30winc >'
    exec 'normal gg'
    let l:windows = GetKnownWindows()

    "exec 'silent '.l:windows['taglist'].'wincmd W'
    "exec 'silent '.l:windows['taglist'].'wincmd L'
    "exec 'silent 500winc < | 30winc >'

    "let l:windows = GetKnownWindows()

    exec 'silent '.l:windows['other'].'wincmd W'
    exec 'silent res 500'

endfunction
"}}}
"{{{ Wipeout buffers not used
function! Wipeout()
  " list of *all* buffer numbers
  let l:buffers = range(1, bufnr('$'))

  " what tab page are we in?
  let l:currentTab = tabpagenr()
  try
    " go through all tab pages
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1

      " go through all windows
      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        " whatever buffer is in this window in this tab, remove it from
        " l:buffers list
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile

    " if there are any buffers left, delete them
    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    " go back to our original tab page
    execute 'tabnext' l:currentTab
  endtry
endfunction
"}}}
"{{{ Find and replace in multiple files
command! -nargs=* -complete=file Fart call FindAndReplace(<f-args>)
function! FindAndReplace(...)
    if a:0 < 3
        echohl Error | echo "Three arguments required: 1. file pattern, 2. search expression and 3. replacement" | echohl None
        return
    endif
    if a:0 > 3
        echohl Error | echo "Too many arguments, three required: 1. file pattern, 2. search expression and 3. replacement" | echohl None
        return
    endif
    let l:pattern = a:1
    let l:search = a:2
    let l:replace = a:3
    echo "Replacing occurences of '".l:search."' with '".l:replace."' in files matching '".l:pattern."'"

    execute '!find . -name "'.l:pattern.'" -print | xargs -t sed -i "s/'.l:search.'/'.l:replace.'/g"'
endfunction

"}}}
"{{{ Link 'Call' to 'call', for mistyping
command! -nargs=* -complete=function Call exec 'call '.<f-args>
"}}}
"}}}

"Fugitive (Git) in status line

set statusline=%{exists(\"*fugitive#statusline\")?\"branch:\ \".fugitive#statusline():\"\"}\ %F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]

let g:NERDTreeMapHelp = "h"
" NERD Tree
nmap <silent> <C-e> :NERDTreeToggle<RETURN>

" Set font for GUI (e.g. GVim)
if has("gui_running")
    set guifont=DejaVu\ Sans\ Mono\ 13
    autocmd VimEnter * NERDTree     "run nerdtree
endif

"{{{ Mini Buffer settings
let g:miniBufExplMapWindowNavVim = 1 
let g:miniBufExplMapWindowNavArrows = 1 
let g:miniBufExplMapCTabSwitchBufs = 1 
let g:miniBufExplModSelTarget = 1 
"}}}

 "{{{ Key Maps

"Escape insert with 'jj', as you probably won't type that
inoremap jj <Esc>
inoremap <C-z> <C-x><C-u>
nnoremap JJJJ <Nop>

" Open Url on this line with the browser \w
map <Leader>b :call Browser ()<CR>

" Instead of 1 line, move 3 at a time
"nnoremap <C-e> 3<C-e>
"nnoremap <C-y> 3<C-y>

" My handy window reset function
nnoremap <C-a> :call SetWindows()<CR>

" Show hidden characters (spaces, tabs, etc) 
nmap <silent> <leader>s :set nolist!<CR>
" PHPDoc commands
inoremap <C-d> <ESC>:call PhpDocSingle()<CR>i 
nnoremap <C-d> :call PhpDocSingle()<CR> 
vnoremap <C-d> :call PhpDocRange()<CR> 
" Ultra-amazing history viewer
nnoremap <C-G> :GundoToggle<CR>
"}}}
" Show lines that exceed 80 characters
match ErrorMsg '\%80v.\+'
" Turn on Line numbers
set number



" Remove trailing whitespaces and ^M chars
autocmd FileType c,cpp,java,php,javascript,python,twig,xml,yml autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))
autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" jQuery
au BufRead,BufNewFile jquery.*.js set ft=javascript syntax=jquery

" PHPUnit
" let g:phpunit_cmd = "/usr/bin/phpunit" 
" let g:phpunit_args = "--configuration /path/to/config" 

" Tab completion - local
let g:SuperTabDefaultCompletionType = "<c-x><c-p>"

" Vdebug options
" let g:vdebug_options = {"on_close":"detach"}

" Vim snippets location
let g:snippets_dir = "~/.vim/snippets/"

let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=1
let g:syntastic_enable_balloons = 1
let g:syntastic_auto_loc_list=1
let g:syntastic_mode_map = { 'mode': 'active',
            \                   'active_filetypes' : [],
            \                   'passive_filetypes' : ['php'] }
