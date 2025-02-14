" FUNCTIONS IN THIS FILES ARE MENT TO BE USE BY NETRW.VIM AND NETRW.VIM ONLY.
" THIS FUNCTIONS DON'T COMMIT TO ANY BACKWARDS COMPATABILITY. SO CHANGES AND
" BREAKAGES IF USED OUTSIDE OF NETRW.VIM ARE EXPECTED.

" netrw#fs#ComposePath: Appends a new part to a path taking different systems into consideration {{{

function! netrw#fs#ComposePath(base, subdir)
    if has('amiga')
        let ec = a:base[s:Strlen(a:base)-1]
        if ec != '/' && ec != ':'
            let ret = a:base . '/' . a:subdir
        else
            let ret = a:base.a:subdir
        endif

        " COMBAK: test on windows with changing to root directory: :e C:/
    elseif a:subdir =~ '^\a:[/\\]\([^/\\]\|$\)' && has('win32')
        let ret = a:subdir

    elseif a:base =~ '^\a:[/\\]\([^/\\]\|$\)' && has('win32')
        if a:base =~ '[/\\]$'
            let ret = a:base . a:subdir
        else
            let ret = a:base . '/' . a:subdir
        endif

    elseif a:base =~ '^\a\{3,}://'
        let urlbase = substitute(a:base, '^\(\a\+://.\{-}/\)\(.*\)$', '\1', '')
        let curpath = substitute(a:base, '^\(\a\+://.\{-}/\)\(.*\)$', '\2', '')
        if a:subdir == '../'
            if curpath =~ '[^/]/[^/]\+/$'
                let curpath = substitute(curpath, '[^/]\+/$', '', '')
            else
                let curpath = ''
            endif
            let ret = urlbase.curpath
        else
            let ret = urlbase.curpath.a:subdir
        endif

    else
        let ret = substitute(a:base . '/' .a:subdir, '//', '/', 'g')
        if a:base =~ '^//'
            " keeping initial '//' for the benefit of network share listing support
            let ret = '/' . ret
        endif
        let ret = simplify(ret)
    endif

    return ret
endfunction

" }}}
" netrw#fs#AbsPath: returns the full path to a directory and/or file {{{

function! netrw#fs#AbsPath(filename)
    let filename = a:filename

    if filename !~ '^/'
        let filename = resolve(getcwd() . '/' . filename)
    endif

    if filename != "/" && filename =~ '/$'
        let filename = substitute(filename, '/$', '', '')
    endif

    return filename
endfunction

" }}}
" netrw#fs#Cwd: get the current directory. {{{
"   Change backslashes to forward slashes, if any.
"   If doesc is true, escape certain troublesome characters

function! netrw#fs#Cwd(doesc)
    let curdir = substitute(getcwd(), '\\', '/', 'ge')

    if curdir !~ '[\/]$'
        let curdir .= '/'
    endif

    if a:doesc
        let curdir = fnameescape(curdir)
    endif

    return curdir
endfunction

" }}}

" vim:ts=8 sts=4 sw=4 et fdm=marker
