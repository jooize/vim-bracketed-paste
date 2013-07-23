" Support:
" * Tmux 1.7+
" * Tmux 1.5+ when escaped with Device Control String (DCS)
" * GNU Screen with DCS (unknown version support)
"
" References:
" http://stackoverflow.com/a/7053522/2330448
" http://ttssh2.sourceforge.jp/manual/en/usage/tips/vim.html#Bracketed
" http://vimdoc.sourceforge.net/htmldoc/term.html#t_te
" http://www.xfree86.org/current/ctlseqs.html
" https://www.gnu.org/software/screen/manual/html_node/Control-Sequences.html

if &term =~ "xterm.*" || &term =~ "screen.*"
    set nocompatible

    let s:ansi_dcs = "\<Esc>P"
    let s:ansi_st = "\<Esc>\\"
    let s:tmux_version = substitute(system('tmux -V'), '\v^tmux ([0-9.]+).*', '\1', '')

    if exists('$STY')
        " GNU Screen
        let &t_ti = s:ansi_dcs . "\<Esc>[?2004h" . &t_ti . s:ansi_st
        let &t_te = s:ansi_dcs . &t_te . "\<Esc>[?2004l" . s:ansi_st
    elseif exists('$TMUX') && (s:tmux_version == "1.5" || s:tmux_version == "1.6")
        " Tmux 1.5 or 1.6
        let &t_ti = s:ansi_dcs . "tmux;" . "\<Esc>" . "\<Esc>[?2004h" . s:ansi_st . &t_ti
        let &t_te = &t_te . s:ansi_dcs . "tmux;" . "\<Esc>" . "\<Esc>[?2004l" . s:ansi_st
    else
        " No/other multiplexer or Tmux 1.7+
        let &t_ti = "\<Esc>[?2004h" . &t_ti
        let &t_te = &t_te . "\<Esc>[?2004l"
    endif

    function! XTermPasteBegin(action)
        set pastetoggle=<F27>
        set paste
        return a:action
    endfunction

    execute "set <F26>=\<Esc>[200~"
    execute "set <F27>=\<Esc>[201~"
    cnoremap <special> <F26> <nop>
    cnoremap <special> <F27> <nop>
    inoremap <special> <expr> <F26> XTermPasteBegin("")
    nnoremap <special> <expr> <F26> XTermPasteBegin("i")
    vnoremap <special> <expr> <F26> XTermPasteBegin("c")
endif

