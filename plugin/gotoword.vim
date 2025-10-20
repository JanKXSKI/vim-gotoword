" plugin/gw.vim
" Helix Goto-Word in Vim: A Vim plugin to jump to labelled position on the
" screen just like in Helix editor.
" Maintainer: Wang "cirnovsky" Guanyu
" Version: 0.1

if exists('g:loaded_vimhelixgw')
	finish
endif
let g:loaded_vimhelixgw = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

command! GotoWord call gotoword#GotoWord()

let &cpoptions = s:save_cpo
unlet s:save_cpo
