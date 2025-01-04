" Make wiki: Makes a new file (or opens existing) for the current [[vimwiki
" link]] and put = vimwiki link text = at the top.
" nmap <space>mw :w<cr>yy:VimwikiFollowLink<cr>Pk^xx$xx=
nmap <space>mw :w<cr>"xyy:VimwikiFollowLink<cr>"xPk^v/\[\[/e<cr>d/\]\]<cr>xx=
" Still has bug. Fails if / in it.
nnoremap <space>mv :w<cr>:VimwikiFollowLink<cr>inoncs: v3<cr><cr>{{{cs<cr><cr>}}}<esc>k

" Vimwiki make link to [[file.wiki#section]]
" nnoremap <space>ml ^wv$bbeyO#<esc>pO<c-r>%<bs><bs><bs><bs><bs><esc>^v$?/<cr>dJxI[[<esc>A]]<esc>yy
" nnoremap <space>ml $?^=<cr>^wv$bbeyO#<esc>pO<c-r>%<bs><bs><bs><bs><bs><esc>^v$?/<cr>dJxI[[<esc>A]]<esc>yy
nnoremap <space>ml :call VW_makelink()<cr>

fun! Get_sec_back()
	" Return first section (=vimwiki header= or *multi-word bold*) backwards from end of current line
	" (If =, the first = must be in first column.)
	" Note: it's up to the calling function to restore cursor position

	" Get position of first =section= or *bold*
	let [lnum, col] = searchpos('\(\*\|=\+\).\{-}\1', 'Wb')  " don't wrap, backwards (backwards seems to mean both in the file and in the line), removed the 'c' flag (so won't find * if very last char on line; consider moving one line down instead of normal $, but problem will still exist if last line in file)
	" Keep getting *bold*'s until finds one with a space in it
	while lnum != 0 && col !=0
		let secline = getline(lnum)
		" First see if match was a =section= and if so, return it
		let match = matchlist(secline, '^\(=\+\) \(.\{-}\) \1')  " assumes single space before and after section header text
		if match != []
			let match = match[2]
			return match
		endif
		" Next, see if it's a *multi-word bold* and if so, return it
		let match = matchlist(secline, '^\*\([^*]\{-}\ [^*]\{-}\)\*', col-1)  " Needs -1. Problem, like if at first char of line? I think no because col is 1-based, and matchlist's {start} is 0-based, and < 0 -> 0. The ^ at the beginning forces the match to start at col-1. Without this, "*did* make me *not*" would match on "* make me *"
		"echo lnum col match len(match) secline
		if match != []
			let match = match[1]
			return match
		endif
		" Get the next one
		let [lnum, col] = searchpos('\(\*\|=\+\).\{-}\1', 'Wb')
	endwhile
	return ''
endfunction

fun! VW_makelink()
	" Get initial cursor position (Maybe also need to save current line's
	" vertical position? If so, see: https://vi.stackexchange.com/questions/7761/how-to-restore-the-position-of-the-cursor-after-executing-a-normal-command)
	let curPos = getcurpos()
	" Move cursor to end of line
	normal $
	" Get most recent section if any (what goes after the # in the [[link]])
	let secname = Get_sec_back()
	let curwiki = expand('%:t:r')
	if secname == curwiki
		let secname = ''
	elseif secname != ''
		let secname = '#'.secname
	endif
	let full_link = '[['.curwiki.secname.']]'
	echo full_link
	
	" Restore cursor position
	call setpos('.', curPos)
	" Put it (No, put it in unnamed register for later putting)
	" put=full_link
	let @" = full_link
endfunction

" Add ability to use K to fold lists. Regular folding commands continue to
" work to fold by header.
nnoremap K :call FoldList()<cr>

" Note: I modified bundle/vimwiki/plugin/vimwiki.vim . Was: if !&diff Added: && !exists('w:oldfm') This is obviously bad as it'll be overwritten upon vimwiki update. Find better way, but currently, w:oldfm in FoldList() now used as a flag to indicate vimwiki shouldn't change the foldmethod
fun! FoldList()
	let w:oldfm = &foldmethod  " unused cuz can't figure out how (Added later: added w: to it, so maybe will work now? Just now, after calling this, echo oldfm came up empty.), but seems unnecessary. With g:vimwiki_folding set to expr, regular folding commands like zc still work too
	set foldmethod=manual
	call feedkeys('zfal')
	" exe ':set foldmethod='.oldfm
endfunction
