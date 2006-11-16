"==================================================
" File:         fencview.vim
" Brief:        View a file in different encodings
" Author:       Mingbai <mbbill AT gmail DOT com>
" Last Change:  2006-11-16 23:01:16
" Version:      1.2
"
" Usage:
"               :FencView
"                   Open the encoding list window,
"               <up> and <down> to select an encoding,
"               enter to reload the file, or you can
"               select a encoding from the menu.
" Note:         Make sure there is no modeline at
"               the end of your file.
"
"==================================================

let s:Fenc8bit=[
            \"latin1    8-bit.characters (ISO 8859-1)",
            \"koi8-r    Russian",
            \"koi8-u    Ukrainian",
            \"macroman  MacRoman (Macintosh encoding)",
            \"cp437     similar to iso-8859-1",
            \"cp737     similar to iso-8859-7",
            \"cp775     Baltic",
            \"cp850     similar to iso-8859-4",
            \"cp852     similar to iso-8859-1",
            \"cp855     similar to iso-8859-2",
            \"cp857     similar to iso-8859-5",
            \"cp860     similar to iso-8859-9",
            \"cp861     similar to iso-8859-1",
            \"cp862     similar to iso-8859-1",
            \"cp863     similar to iso-8859-8",
            \"cp865     similar to iso-8859-1",
            \"cp866     similar to iso-8859-5",
            \"cp869     similar to iso-8859-7",
            \"cp874     Thai",
            \"cp1250    Czech, Polish, etc",
            \"cp1251    Cyrillic",
            \"cp1253    Greek",
            \"cp1254    Turkish",
            \"cp1255    Hebrew",
            \"cp1256    Arabic",
            \"cp1257    Baltic",
            \"cp1258    Vietnamese"]
let s:Fenc16bit=[
            \"cp936     simplified Chinese (Windows only)",
            \"gb18030   simplified Chinese (Windows only)",
            \"euc-cn    simplified Chinese (Unix only)",
            \"cp950     traditional Chinese (on Unix alias for big5)",
            \"big5      traditional Chinese (on Windows alias for cp950)",
            \"euc-tw    traditional Chinese (Unix only)",
            \"cp932     Japanese (Windows only)",
            \"euc-jp    Japanese (Unix only)",
            \"sjis      Japanese (Unix only)",
            \"cp949     Korean (Unix and Windows)",
            \"euc-kr    Korean (Unix only)"]
let s:FencUnicode=[
            \"utf-8     32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)",
            \"ucs-2     16 bit UCS-2 encoded Unicode (ISO/IEC 10646-1)",
            \"ucs-2le   like ucs-2, little endian",
            \"utf-16    ucs-2 extended with double-words for more characters",
            \"utf-16le  like utf-16, little endian",
            \"ucs-4     32 bit UCS-4 encoded Unicode (ISO/IEC 10646-1)",
            \"ucs-4le   like ucs-4, little endian"]
let g:FencCustom=
            \"Examples:\n".
            \"------------------\n".
            \"iso-8859-n    ISO_8859 variant (n = 2 to 15)\n".
            \"8bit-{name}   any 8-bit encoding (Vim specific name)\n".
            \"cp{number}    MS-Windows: any installed single-byte codepage\n".
            \"cp{number}    MS-Windows: any installed double-byte codepage\n".
            \"2byte-{name}  Unix: any double-byte encoding (Vim specific name)"
let s:WinName="FenView"

function! ToggleFencView()
    let FencWinNr=bufwinnr(s:WinName)
    if FencWinNr!=-1
        exec FencWinNr." wincmd w"
        exec "wincmd c"
        return
    endif
    let _tmpfenc=&fenc
    let bmod=&modified
    if  bmod==1
        echoerr "File is modified!"
        return
    endif
    let splitLocation="belowright "
    let splitMode="vertical "
    let splitSize=34
    let cmd=splitLocation . splitMode . splitSize . ' new ' . s:WinName
    echo cmd
    silent! execute cmd
    setlocal winfixwidth
    setlocal noswapfile
    setlocal buftype=nowrite
    setlocal bufhidden=delete
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal nobuflisted
    setlocal nospell
    setlocal nonumber
    setlocal cursorline
    call append(0,s:Fenc8bit)
    call append(0,s:Fenc16bit)
    call append(0,s:FencUnicode)
    syn match Type "^.\{-}\s"
    syn match Comment "\s.*$"
    if _tmpfenc!=""
        let s=search(_tmpfenc)
        if s!=0
            let _line=getline(line("."))
            let _fenc=substitute(_line,'\s.*$','',"g")
            syn clear Search
            exec "syn match Search \""._line."\""
        endif
    else
        normal gg
    endif
    nnoremap <buffer> <CR> :call FencSelect()<CR>
    nnoremap <buffer> <2-leftmouse> :call FencSelect()<CR>
endfunction

function! FencSelect()
    let _line=getline(line("."))
    let _fenc=substitute(_line,'\s.*$','',"g")
    if _fenc==''
        return
    endif
    syn clear Search
    exec "syn match Search \""._line."\""
    let MainWinNr=winnr("#")
    if MainWinNr==0
        echoerr "Main window not found!"
        return
    endif
    exec MainWinNr." wincmd w"
    let _bmod=&modified
    if  _bmod==1
        echoerr "File is modified!"
        return
    endif
    exec "edit ++enc="._fenc
    let FencWinNr=bufwinnr(s:WinName)
    if FencWinNr==-1
        echoerr "Encoding list window not found!"
        return
    endif
    exec FencWinNr." wincmd w"
endfunction

function! FencCreateMenu()
    for i in s:Fenc8bit
        let fencla=substitute(i,'\s.*$','','g')
        let fenname=fencla.'<tab>('.substitute(i,'^.\{-}\s\+','','g').')'
        let fenname=substitute(fenname,' ','\\ ','g')
        let fenname=substitute(fenname,'\.','_','g')
        exec 'menu &Tools.Encoding.8bit\ encodings.'.fenname.' :call FencMenuSel("'.fencla.'")<CR>'
    endfor
    for i in s:Fenc16bit
        let fencla=substitute(i,'\s.*$','','g')
        let fenname=fencla.'<tab>('.substitute(i,'^.\{-}\s\+','','g').')'
        let fenname=substitute(fenname,' ','\\ ','g')
        let fenname=substitute(fenname,'\.','_','g')
        exec 'menu &Tools.Encoding.16bit\ encodings.'.fenname.' :call FencMenuSel("'.fencla.'")<CR>'
    endfor
    for i in s:FencUnicode
        let fencla=substitute(i,'\s.*$','','g')
        let fenname=fencla.'<tab>('.substitute(i,'^.\{-}\s\+','','g').')'
        let fenname=substitute(fenname,' ','\\ ','g')
        let fenname=substitute(fenname,'\.','_','g')
        exec 'menu &Tools.Encoding.Unicode.'.fenname.' :call FencMenuSel("'.fencla.'")<CR>'
    endfor
    menu &Tools.Encoding.-sep-   :
    menu &Tools.Encoding.Toggle\ Encoding\ list :call ToggleFencView()<CR>
    menu &Tools.Encoding.Input\.\.\. :call FencMenuSel(inputdialog(g:FencCustom))<CR>
endfunction

function! FencMenuSel(fen_name)
    if a:fen_name==''
        return
    endif
    exec "edit ++enc=".a:fen_name
endfunction

call    FencCreateMenu()
command!    -nargs=0 FencView      call ToggleFencView()


" vim: set ft=vim ff=unix fdm=marker :
