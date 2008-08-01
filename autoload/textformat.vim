" Text formatter plugin for Vim text editor
"
" This plugin provides commands and key mappings to quickly align and format
" text. Text can be aligned to either left or right margin or justified to
" both margins or centered. The text formatting commands in this plugin are
" a bit different from those integrated to Vim.
"
" Version:    1.0
" Maintainer: Teemu Likonen <tlikonen@iki.fi>
" GetLatestVimScripts: 0 1 :AutoInstall: textformat.vim
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
" The License text in full:
" 	http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
"
" }}}

" Constant variables(s) {{{1
let s:default_width = 80

function! s:Align_Range_Left(...) range "{{{1
	if a:0 > 0 && a:1 >= 0
		let l:start_ws = repeat(' ',a:1)
		let l:line_replace = s:Align_String_Left(getline(a:firstline))
		call setline(a:firstline,l:start_ws.l:line_replace)
	else
		let l:start_ws = substitute(getline(a:firstline),'\m\S.*','','')
		let l:line_replace = s:Align_String_Left(getline(a:firstline))
		call setline(a:firstline,l:start_ws.l:line_replace)
		if match(&formatoptions,'2') >= 0 && a:lastline > a:firstline
			let l:start_ws = substitute(getline(a:firstline+1),'\m\S.*','','')
		endif
	endif
	for l:i in range(a:lastline-a:firstline)
		let l:line = a:firstline + 1 + l:i
		let l:line_replace = s:Align_String_Left(getline(l:line))
		call setline(l:line,l:start_ws.l:line_replace)
	endfor
	execute a:firstline.','.a:lastline.'retab!'
endfunction

function! s:Align_Range_Right(width) "{{{1
	let l:line_replace = s:Align_String_Right(getline('.'),a:width)
	if l:line_replace =~ '\v^ *$'
		call setline(line('.'),'')
	else
		call setline(line('.'),l:line_replace)
	endif
endfunction

function! s:Align_Range_Justify(width, ...) range "{{{1
	let l:start_ws = substitute(getline(a:firstline),'\m\S.*','','')
	normal! ^
	let l:width = a:width-virtcol('.')+1
	let l:line_replace = substitute(l:start_ws.s:Align_String_Justify(getline(a:firstline),l:width),'\m\s*$','','')
	call setline(a:firstline,l:line_replace)
	if match(&formatoptions,'2') >= 0 && a:lastline > a:firstline
		let l:start_ws = substitute(getline(a:firstline+1),'\m\S.*','','')
		execute a:firstline+1
		normal! ^
		let l:width = a:width-virtcol('.')+1
	endif
	for l:i in range(a:lastline-a:firstline)
		let l:line = a:firstline + 1 + l:i
		if l:line == a:lastline && a:0
			call setline(l:line,l:start_ws.s:Truncate_Spaces(getline(l:line)))
		else
			let l:line_replace = substitute(l:start_ws.s:Align_String_Justify(getline(l:line),l:width),'\m\s*$','','')
			call setline(l:line,l:line_replace)
		endif
	endfor
endfunction

function! s:Align_Range_Center(width) "{{{1
	let l:line_replace = s:Truncate_Spaces(getline('.'))
	let l:line_replace = s:Add_Double_Spacing(l:line_replace)
	call setline(line('.'),l:line_replace)
	execute 'center '.a:width
endfunction

function! s:Align_String_Left(string, ...) "{{{1
	let l:string_replace = s:Truncate_Spaces(a:string)
	let l:string_replace = s:Add_Double_Spacing(l:string_replace)
	if a:0 && a:1
		let l:string_width = s:String_Width(l:string_replace)
		let l:more_spaces = a:1-l:string_width
		return l:string_replace.repeat(' ',l:more_spaces)
	else
		return l:string_replace
	endif
endfunction

function! s:Align_String_Right(string, width) "{{{1
	let l:string_replace = s:Truncate_Spaces(a:string)
	let l:string_replace = s:Add_Double_Spacing(l:string_replace)
	let l:string_width = s:String_Width(l:string_replace)
	let l:more_spaces = a:width-l:string_width
	return repeat(' ',l:more_spaces).l:string_replace
endfunction

function! s:Align_String_Justify(string, width) "{{{1
	let l:string = s:Truncate_Spaces(a:string)
	" Jos merkkijono on tyhjä, palautetaan vain leveyden verran
	" välilyöntejä.
	if l:string =~ '\v^ *$'
		return repeat(' ',a:width)
	endif
	let l:string_width = s:String_Width(l:string)
	if l:string_width >= a:width
		" Merkkijono on pidempi tai yhtä suuri kuin toivottu leveys,
		" joten palautetaan merkkijono jo tässä vaiheessa. Välejä ei
		" tarvitse lisätä.
		return l:string
	endif

	" Montako lisävälilyöntiä tarvitaan?
	let l:more_spaces = a:width-l:string_width
	" Tehdään merkkijonon sanoista lista.
	let l:word_list = split(l:string)
	" Lasketaan välilyönnit. Se on sanojen määrä vähennettynä yhdellä.
	let l:string_spaces = len(l:word_list)-1
	" Jos välejä on 0, se tarkoittaa, että sanoja on vain yksi ja se taas
	" tarkoittaa, että lisätään välilyönnit vain loppuun ja poistutaan.
	if l:string_spaces == 0
		return l:string.repeat(' ',l:more_spaces)
	endif
	" Okei, sanoja on vähintään kaksi, joten päästään tositoimiin...

	" Tehdään välilyönneille lista, jossa jokaisen osan arvona on
	" valmiiksi 1. Siis näin: [1, 1, 1, 1, ...]
	let l:space_list = []
	for l:item in range(l:string_spaces)
		let l:space_list += [1]
	endfor

	while l:more_spaces > 0
		if l:more_spaces >= l:string_spaces
			" Lisätään yksi välilyönti jokaiseen kohtaan.
			for l:i in range(l:string_spaces)
				let l:space_list[l:i] += 1
			endfor
			" Vähennetään jäljellä olevien välilyöntien määrää.
			let l:more_spaces -= l:string_spaces
			" Ja sitten uusi kierros.
		else " l:more_spaces < l:string_spaces

			" Tämä lista kertoo, missä väleissä on
			" päättövälimerkki [.?!]
			let l:space_sentence_full = []
			" Tämä kertoo, missä väleissä on [,:;].
			let l:space_sentence_semi = []
			" Tämä kertoo muut kohdat:
			let l:space_other = []

			for l:i in range(l:string_spaces)
				if match(l:word_list[l:i],'\m\S[.?!]$') >= 0
					let l:space_sentence_full += [l:i]
				elseif match(l:word_list[l:i],'\m\S[,:;]$') >= 0
					let l:space_sentence_semi += [l:i]
				else
					let l:space_other += [l:i]
				endif
			endfor

			" Käydään läpi [.?!]
			if l:more_spaces >= len(l:space_sentence_full)
				for l:i in l:space_sentence_full
					let l:space_list[l:i] += 1
				endfor
				let l:more_spaces -= len(l:space_sentence_full)
				if l:more_spaces == 0 | break | endif
			else
				for l:i in s:Distribute_Spaces(l:space_sentence_full,l:more_spaces)
					let l:space_list[l:i] +=1
				endfor
				break
			endif

			" Käydään läpi [,:;]
			if l:more_spaces >= len(l:space_sentence_semi)
				for l:i in l:space_sentence_semi
					let l:space_list[l:i] += 1
				endfor
				let l:more_spaces -= len(l:space_sentence_semi)
				if l:more_spaces == 0 | break | endif
			else
				for l:i in s:Distribute_Spaces(l:space_sentence_semi,l:more_spaces)
					let l:space_list[l:i] +=1
				endfor
				break
			endif

			" Finally distribute spaces to other available
			" positions and exit the loop.
			for l:i in s:Distribute_Spaces(l:space_other,l:more_spaces)
				let l:space_list[l:i] +=1
			endfor
			break
		endif
	endwhile

	" Muodostetaan listan perusteella uusi merkkijono. Kunkin sanan perään
	" laitetaan välilyönnit taulukon mukaan.
	let l:string = ''
	for l:item in range(l:string_spaces)
		let l:string .= l:word_list[l:item].repeat(' ',l:space_list[l:item])
	endfor
	" Lopuksi lisätään vielä viimeinen sana ja palautetaan koko
	" merkkijono.
	return l:string.l:word_list[-1]
endfunction

function! s:Truncate_Spaces(string) "{{{1
	let l:string = substitute(a:string,'\v\s+',' ','g')
	let l:string = substitute(l:string,'\m^\s*','','')
	let l:string = substitute(l:string,'\m\s*$','','')
	return l:string
endfunction

function! s:String_Width(string) "{{{1
	" Tänne voisi lisätä logiikkaa siitä, onko käytetty
	" leveydettömiä tai kaksoisleveitä merkkejä.
	return strlen(substitute(a:string,'\m.','x','g'))
endfunction

function! s:Add_Double_Spacing(string) "{{{1
	if &joinspaces
		return substitute(a:string,'\m\S[.?!] ','& ','g')
	else
		return a:string
	endif
endfunction

function! s:Distribute_Spaces(list, pick) "{{{1

	let l:div1 = len(a:list) / a:pick
	let l:mod1 = len(a:list) % a:pick

	let l:space_list = []
	for l:i in range(len(a:list)-l:mod1)
		if !eval(l:i%l:div1)
			let l:space_list += [1]
		else
			let l:space_list += [0]
		endif
	endfor

	if l:mod1 > 0
		let l:div2 = len(l:space_list) / l:mod1
		let l:mod2 = len(l:space_list) % l:mod1
		for l:i in range(len(l:space_list)-l:mod2)
			if !eval(l:i%l:div2)
				call insert(l:space_list,0,l:i)
			endif
		endfor
	endif

	"normal ggdG
	let l:spaces_begin = 0
	for l:i in l:space_list
		if l:i == 0
			let l:spaces_begin += 1
		else
			break
		endif
	endfor
	let l:spaces_end = 0
	for l:i in reverse(copy(l:space_list))
		if l:i == 0
			let l:spaces_end += 1
		else
			break
		endif
	endfor
	"execute '$s/$/\r'.l:spaces_begin
	"execute '$s/$/\r'.l:spaces_end
	"execute '$s/$/\r'.string(l:space_list)

	if l:spaces_end
		call remove(l:space_list,len(l:space_list)-l:spaces_end,-1)
		"execute '$s/$/\r'.string(l:space_list)
	endif
	if l:spaces_begin
		call remove(l:space_list,0,l:spaces_begin-1)
		"execute '$s/$/\r'.string(l:space_list)
	endif
	let l:spaces_both = l:spaces_begin + l:spaces_end
	"execute '$s/$/\r'.l:spaces_both

	for l:i in range(l:spaces_both/2)
		call insert(l:space_list,0,0)
	endfor
	"execute '$s/$/\r'.string(l:space_list)
	for l:i in range((l:spaces_both/2)+(l:spaces_both%2))
		call add(l:space_list,0)
	endfor
	"execute '$s/$/\r'.string(l:space_list)

	"return l:space_list

	let l:new_list = []
	for l:i in range(len(l:space_list))
		if l:space_list[l:i] == 1
			let l:new_list += [a:list[l:i]]
		endif
	endfor
	return l:new_list

endfunction

function! textformat#Quick_Align_Left() "{{{1
	let l:pos = getpos('.')
	let l:autoindent = &autoindent
	let l:formatoptions = &formatoptions
	setlocal autoindent formatoptions-=w
	silent normal! vip:call s:Align_Range_Left()
	silent normal! gwip
	call setpos('.',l:pos)
	let &l:formatoptions = l:formatoptions
	let &l:autoindent = l:autoindent
endfunction

function! textformat#Quick_Align_Right() "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width | endif
	let l:pos = getpos('.')
	silent normal! vip:call s:Align_Range_Right(l:width)
	call setpos('.',l:pos)
endfunction

function! textformat#Quick_Align_Justify() "{{{1
	let l:width = &textwidth
	if l:width == 0 | let l:width = s:default_width  | endif
	let l:pos = getpos('.')
	let l:joinspaces = &joinspaces
	setlocal nojoinspaces
	call textformat#Quick_Align_Left()
	let &l:joinspaces = l:joinspaces
	silent normal! vip:call s:Align_Range_Justify(l:width,1)
	call setpos('.',l:pos)
endfunction

function! textformat#Quick_Align_Center() "{{{1
	let l:width = &textwidth
	let l:expandtab = &expandtab
	setlocal expandtab
	if l:width == 0 | let l:width = s:default_width  | endif
	let l:pos = getpos('.')
	silent normal! vip:call s:Align_Range_Center(l:width)
	call setpos('.',l:pos)
	let &l:expandtab = l:expandtab
endfunction

function! textformat#Align_Command(align, ...) range "{{{1
	if a:align == 'left'
		if a:0 && a:1 >= 0
			execute a:firstline.','.a:lastline.'call s:Align_Range_Left('.a:1.')'
		else
			execute a:firstline.','.a:lastline.'call s:Align_Range_Left()'
		endif
	else
		if a:0 && a:1 > 0
			let l:width = a:1
		elseif &textwidth
			let l:width = &textwidth
		else
			let l:width = s:default_width
		endif

		if a:align == 'right'
			execute a:firstline.','.a:lastline.'call s:Align_Range_Right('.l:width.')'
		elseif a:align == 'justify'
			execute a:firstline.','.a:lastline.'call s:Align_Range_Justify('.l:width.')'
		elseif a:align == 'center'
			let l:expandtab = &expandtab
			setlocal expandtab
			execute a:firstline.','.a:lastline.'call s:Align_Range_Center('.l:width.')'
			let &l:expandtab = l:expandtab
		endif
	endif
endfunction

" vim600: fdm=marker
