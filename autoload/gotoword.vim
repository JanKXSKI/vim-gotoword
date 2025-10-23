
function! s:num2tag(num) abort
	let chars = 'abcdefghijklmnopqrstuvwxyz'
	let fst = a:num / 26
	let sec = a:num % 26
	return chars[fst] . chars[sec]
endfunction

augroup NMSLHL
    autocmd!
    autocmd ColorScheme * call s:NMMSL()
augroup END

function! s:NMMSL() abort
    if &background ==# 'dark'
        highlight NMSL ctermfg=DarkGrey guifg=Black guibg=Yellow cterm=bold gui=bold
    else
        highlight NMSL ctermfg=DarkGrey guifg=White guibg=Red cterm=bold gui=bold
    endif
endfunction

function! gotoword#GotoWord() abort
	let tagged = []
	let positions = {}
	let cnt = 0
	let start = line('w0')
	let end = line('w$')
	let nlines = end-start

	let folds = map(range(start, end), 'foldclosed(v:val)')

	for cnm in range(start, end)
		if foldclosed(cnm) != -1 && foldclosed(cnm) != cnm
			call add(tagged, 'cnm')
			continue
		endif
		let line = getline(cnm)
		let new = ''
		let chars = split(line, '\zs')
		let i = 0
		while i < len(chars)
			let char = chars[i]

			if char =~ '\w' && (i == 0 || chars[i-1] !~ '\w')
				let n = 0
				while i+n < len(chars) && chars[i+n] =~ '\w'
					let n += 1
				endwhile
				if n > 1
					let tg = printf('%s', s:num2tag(cnt))
					let cnt += 1
					let positions[tg] = [len(tagged), i+1]
					let new .= tg
					let i += 2
					continue
				endif
			endif
			let new .= char
			let i += 1
		endwhile
		call add(tagged, new)
	endfor

    " setline() calls will later be undone.
    " Use a new undo block for this to enable GoToWord to be used in another command.
    " See :h undo-close-block
    let &g:undolevels = &g:undolevels

	for i in range(start, end)
		if foldclosed(i) == -1 || foldclosed(i) == i
			call setline(i, tagged[i-start])
		endif
	endfor

	let hl_pos = []
	for pos in values(positions)
		let [l, c] = pos
		let l += line('w0')
		call add(hl_pos, [l, c, 2])
	endfor

	call s:NMMSL()
	let mid = matchaddpos('NMSL', hl_pos)

	redraw
	let input = nr2char(getchar()) . nr2char(getchar())

	for i in range(0, nlines)
		if folds[i] == i
			execute folds[i] . 'foldclose'
		endif
	endfor

	call matchdelete(mid)
	
	u
	if has_key(positions, input)
		let [line, col] = positions[input]
		let line += line('w0')
		call cursor(line, col)
	endif

endfunction
