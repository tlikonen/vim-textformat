" Text formatter plugin for Vim text editor
"
" Version:    2.0
" Maintainer: Teemu Likonen <tlikonen@iki.fi>
" GetLatestVimScripts: 2324 1 :AutoInstall: textformat.vim
"
" {{{ Copyright and license
"
" Copyright (C) 2008 Teemu Likonen <tlikonen@iki.fi>
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software
" Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
"
" The license text:
" 	http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
"
" }}}

"{{{1 The beginning stuff
if &compatible || exists('g:loaded_textformat')
	finish
endif
let s:save_cpo = &cpo
set cpo&vim
"}}}1

if v:version < 700
	echohl ErrorMsg
	echomsg 'TextFormat plugin needs Vim version 7.0 or later. Sorry.'
	echohl None
	finish
endif

if !exists(':AlignLeft')
	command -nargs=? -range AlignLeft <line1>,<line2>call textformat#Align_Command('left',<args>)
endif
if !exists(':AlignRight')
	command -nargs=? -range AlignRight <line1>,<line2>call textformat#Align_Command('right',<args>)
endif
if !exists(':AlignJustify')
	command -nargs=? -range AlignJustify <line1>,<line2>call textformat#Align_Command('justify',<args>)
endif
if !exists(':AlignCenter')
	command -nargs=? -range AlignCenter <line1>,<line2>call textformat#Align_Command('center',<args>)
endif

nnoremap <silent> <Plug>Quick_Align_Paragraph_Left :call textformat#Quick_Align_Left()<CR>
nnoremap <silent> <Plug>Quick_Align_Paragraph_Right :call textformat#Quick_Align_Right()<CR>
nnoremap <silent> <Plug>Quick_Align_Paragraph_Justify :call textformat#Quick_Align_Justify()<CR>
nnoremap <silent> <Plug>Quick_Align_Paragraph_Center :call textformat#Quick_Align_Center()<CR>

vnoremap <silent> <Plug>Align_Range_Left :call textformat#Visual_Align_Left()<CR>
vnoremap <silent> <Plug>Align_Range_Right :call textformat#Visual_Align_Right()<CR>
vnoremap <silent> <Plug>Align_Range_Justify :call textformat#Visual_Align_Justify()<CR>
vnoremap <silent> <Plug>Align_Range_Center :call textformat#Visual_Align_Center()<CR>

function! s:Add_Mapping(mode, lhs, rhs)
	if maparg(a:lhs, a:mode) == '' && !hasmapto(a:rhs, a:mode)
		execute a:mode.'map '.a:lhs.' '.a:rhs
	endif
endfunction

call s:Add_Mapping('n', '<Leader>al', '<Plug>Quick_Align_Paragraph_Left')
call s:Add_Mapping('n', '<Leader>ar', '<Plug>Quick_Align_Paragraph_Right')
call s:Add_Mapping('n', '<Leader>aj', '<Plug>Quick_Align_Paragraph_Justify')
call s:Add_Mapping('n', '<Leader>ac', '<Plug>Quick_Align_Paragraph_Center')

call s:Add_Mapping('v', '<Leader>al', '<Plug>Align_Range_Left')
call s:Add_Mapping('v', '<Leader>ar', '<Plug>Align_Range_Right')
call s:Add_Mapping('v', '<Leader>aj', '<Plug>Align_Range_Justify')
call s:Add_Mapping('v', '<Leader>ac', '<Plug>Align_Range_Center')

delfunction s:Add_Mapping
let g:loaded_textformat = 1
let &cpo = s:save_cpo
" vim600: fdm=marker
