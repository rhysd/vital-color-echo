scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! s:_is_available() abort
    if has('gui_running')
        return 1
    endif

    if has('win32') || has('win64')
        return 0
    endif

    return exists('&t_Co') && (&t_Co == 8 || &t_Co == 256)
endfunction

function! s:is_available() abort
    if exists('s:is_available_cache')
        return s:is_available_cache
    endif
    let s:is_available_cache = s:_is_available()
    return s:is_available_cache
endfunction

function! s:_define_ansi_highlights() abort
    hi ansiNone cterm=NONE gui=NONE

    hi ansiBlackBg ctermbg=black guibg=black cterm=none gui=none
    hi ansiRedBg ctermbg=red guibg=red cterm=none gui=none
    hi ansiGreenBg ctermbg=green guibg=green cterm=none gui=none
    hi ansiYellowBg ctermbg=yellow guibg=yellow cterm=none gui=none
    hi ansiBlueBg ctermbg=blue guibg=blue cterm=none gui=none
    hi ansiMagentaBg ctermbg=magenta guibg=magenta cterm=none gui=none
    hi ansiCyanBg ctermbg=cyan guibg=cyan cterm=none gui=none
    hi ansiWhiteBg ctermbg=white guibg=white cterm=none gui=none
    hi ansiGrayBg ctermbg=gray guibg=gray cterm=none gui=none

    hi ansiBlackFg ctermfg=black guifg=black cterm=none gui=none
    hi ansiRedFg ctermfg=red guifg=red cterm=none gui=none
    hi ansiGreenFg ctermfg=green guifg=green cterm=none gui=none
    hi ansiYellowFg ctermfg=yellow guifg=yellow cterm=none gui=none
    hi ansiBlueFg ctermfg=blue guifg=blue cterm=none gui=none
    hi ansiMagentaFg ctermfg=magenta guifg=magenta cterm=none gui=none
    hi ansiCyanFg ctermfg=cyan guifg=cyan cterm=none gui=none
    hi ansiWhiteFg ctermfg=white guifg=white cterm=none gui=none
    hi ansiGrayFg ctermfg=gray guifg=gray cterm=none gui=none

    hi ansiBoldBlackFg ctermfg=black guifg=black cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldRedFg ctermfg=red guifg=red cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldGreenFg ctermfg=green guifg=green cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldYellowFg ctermfg=yellow guifg=yellow cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldBlueFg ctermfg=blue guifg=blue cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldMagentaFg ctermfg=magenta guifg=magenta cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldCyanFg ctermfg=cyan guifg=cyan cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldWhiteFg ctermfg=white guifg=white cterm=none gui=none cterm=bold gui=bold
    hi ansiBoldGrayFg ctermfg=gray guifg=gray cterm=none gui=none cterm=bold gui=bold

    hi ansiUnderlineBlackFg ctermfg=black guifg=black cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineRedFg ctermfg=red guifg=red cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineGreenFg ctermfg=green guifg=green cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineYellowFg ctermfg=yellow guifg=yellow cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineBlueFg ctermfg=blue guifg=blue cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineMagentaFg ctermfg=magenta guifg=magenta cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineCyanFg ctermfg=cyan guifg=cyan cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineWhiteFg ctermfg=white guifg=white cterm=none gui=none cterm=underline gui=underline
    hi ansiUnderlineGrayFg ctermfg=gray guifg=gray cterm=none gui=none cterm=underline gui=underline

endfunction

let s:echorizer = {
        \   'value': '',
        \   'attr': '',
        \ }

function s:echorizer.eat() abort
    let matched = match(self.value, '\e\[\d*m')
    if matched == -1
        return {}
    endif

    let matched_end = matchend(self.value, '\e\[\d*m')

    let token = {
        \   'body': matched == 0 ? '' : self.value[ : matched-1],
        \   'code': matchstr(self.value[matched : matched_end-1], '\d\+')
        \ }

    let self.value = self.value[matched_end : ]

    return token
endfunction

let s:COLORS = {
    \   0: "None",
    \   30: "BlackFg",
    \   31: "RedFg",
    \   32: "GreenFg",
    \   33: "YellowFg",
    \   34: "BlueFg",
    \   35: "MagentaFg",
    \   36: "CyanFg",
    \   37: "WhiteFg",
    \   40: "BlackBg",
    \   41: "RedBg",
    \   42: "GreenBg",
    \   43: "YellowBg",
    \   44: "BlueBg",
    \   45: "MagentaBg",
    \   46: "CyanBg",
    \   47: "WhiteBg",
    \   90: "GrayFg",
    \ }

function s:echorizer.echo_ansi(code) abort
    if !has_key(s:COLORS, a:code)
        return
    endif

    execute 'echohl' 'ansi' . self.attr . s:COLORS[a:code]

    if a:code == 0
        let self.attr = ''
    endif
endfunction

function s:echorizer.echo() abort
    echo

    while 1
        let token = self.eat()
        if token == {}
            break
        endif

        if token.body !=# ''
            echon token.body
        endif

        " TODO: Now only one attribute can be specified
        if token.code == 1
            let self.attr = 'Bold'
        elseif token.code == 4
            let self.attr = 'Underline'
        elseif token.code ==# ''
            call self.echo_ansi(0)
        else
            call self.echo_ansi(token.code)
        endif
    endwhile

    echon self.value
    echohl None
    let self.value = ''
endfunction

function! s:get_echorizer(str) abort
    let e = deepcopy(s:echorizer)
    let e.value = a:str
    return e
endfunction

function! s:echo(str) abort
    if !s:is_available()
        echo substitute(a:str, '\e[.*m', '', 'g')
        return
    endif

    if !exists('g:__vital_color_echo_already_highlighted')
        call s:_define_ansi_highlights()
        let g:__vital_color_echo_already_highlighted = 1
    endif

    let echorizer = s:get_echorizer(a:str)
    call echorizer.echo()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
