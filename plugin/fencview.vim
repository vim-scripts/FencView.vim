"==================================================
" File:         fenview.vim
" Brief:        View a file in different encodings
" Author:       Mingbai <mbbill AT gmail DOT com>
" Last Change:  2006-11-15 01:18:47
" Version:      0.1
"
" Usage:
"               :FenView
"                   Open the encoding list window,
"               <up> and <down> to select an encoding, 
"               enter to reload the file.
" Note:         Make sure there is no modeline at
"               the end of your file.
"
"==================================================
let s:fencs=
            \"utf-8        32 bit UTF-8 encoded Unicode (ISO/IEC 10646-1)\n".
            \"ucs-2        16 bit UCS-2 encoded Unicode (ISO/IEC 10646-1)\n".
            \"gb18030      simplified Chinese (Windows only)\n".
            \"cp936        simplified Chinese (Windows only)\n".
            \"euc-cn       simplified Chinese (Unix only)\n".
            \"cp950        traditional Chinese (on Unix alias for big5)\n".
            \"big5         traditional Chinese (on Windows alias for cp950)\n".
            \"euc-tw       traditional Chinese (Unix only)\n".
            \"cp932        Japanese (Windows only)\n".
            \"euc-jp       Japanese (Unix only)\n".
            \"sjis         Japanese (Unix only)\n".
            \"cp949        Korean (Unix and Windows)\n".
            \"euc-kr       Korean (Unix only)\n".
            \"ucs-2le      like ucs-2, little endian\n".
            \"utf-16       ucs-2 extended with double-words for more characters\n".
            \"utf-16le     like utf-16, little endian\n".
            \"ucs-4        32 bit UCS-4 encoded Unicode (ISO/IEC 10646-1)\n".
            \"ucs-4le      like ucs-4, little endian\n".
            \"latin1       8-bit characters (ISO 8859-1)\n".
            \"iso-8859-n   ISO_8859 variant (n = 2 to 15)\n".
            \"koi8-r       Russian\n".
            \"koi8-u       Ukrainian\n".
            \"macroman     MacRoman (Macintosh encoding)\n".
            \"cp437        similar to iso-8859-1\n".
            \"cp737        similar to iso-8859-7\n".
            \"cp775        Baltic\n".
            \"cp850        similar to iso-8859-4\n".
            \"cp852        similar to iso-8859-1\n".
            \"cp855        similar to iso-8859-2\n".
            \"cp857        similar to iso-8859-5\n".
            \"cp860        similar to iso-8859-9\n".
            \"cp861        similar to iso-8859-1\n".
            \"cp862        similar to iso-8859-1\n".
            \"cp863        similar to iso-8859-8\n".
            \"cp865        similar to iso-8859-1\n".
            \"cp866        similar to iso-8859-5\n".
            \"cp869        similar to iso-8859-7\n".
            \"cp874        Thai\n".
            \"cp1250       Czech, Polish, etc.\n".
            \"cp1251       Cyrillic\n".
            \"cp1253       Greek\n".
            \"cp1254       Turkish\n".
            \"cp1255       Hebrew\n".
            \"cp1256       Arabic\n".
            \"cp1257       Baltic\n".
            \"cp1258       Vietnamese\n".
            \" * Change the {name} below * \n".
            \"8bit-{name}  any 8-bit encoding (Vim specific name)\n".
            \"2byte-{name} Unix: any double-byte encoding (Vim specific name)\n".
            \"cp{number}   MS-Windows: any installed double-byte codepage\n".
            \"cp{number}   MS-Windows: any installed single-byte codepage"

let s:WinName="FenView"

function! FencView()
    let _tmpfenc=&fenc
    let bmod=&modified
    if  bmod==1
        echoerr "File is modified!"
        return
    endif
    let s:MainWinBufName=bufname("%")
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
    let old_h=@h
    let @h=s:fencs
    silent! put h
    let @h=old_h
    normal ggdd
    syn match Type "^.\{-}\s"
    syn match Comment "\s.*$"
    let s=search(_tmpfenc)
    if s!=0
        let _line=getline(line("."))
        let _fenc=substitute(_line,'\s.*$','',"g")
        syn clear Search
        exec "syn match Search \""._line."\""
    endif
    nnoremap <buffer>  <CR> :call FencSelect()<CR>
endfunction

function! FencSelect()
    let _line=getline(line("."))
    let _fenc=substitute(_line,'\s.*$','',"g")
    syn clear Search
    exec "syn match Search \""._line."\""
    let MainWinNr=bufwinnr(s:MainWinBufName)
    if MainWinNr==-1
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
    let FencycWinNr=bufwinnr(s:WinName)
    if MainWinNr==-1
        echoerr "Encoding list window not found!"
        return
    endif
    exec FencycWinNr." wincmd w"
endfunction

command!    -nargs=0 FencView      call FencView()


" vim: set ft=vim ff=unix fdm=marker :
