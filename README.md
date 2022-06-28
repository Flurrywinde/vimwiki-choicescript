# vimwiki-choicescript (a vim plugin)
Adds choicescript syntax highlighting to vimwiki {{{cs ... }}} sections

Currently doing this via:


* In syntax/choicescript.vim: add a non-CS section

" Custom: vimwiki non-choicescript areas
syntax region nonCS start="^}}}" end="^{{{cs" fold contains=csComment
hi def nonCS guifg=LightBlue gui=italic font='Iosevka Term SS10 Thin Oblique'

* Add <space>cs that changes the filetype to choicescript (in vimrc, I think)
* More?
  
Consider doing it new way, this `vimwiki-choicescript` plugin:
  
  Add autocmd that detects cs code in a vimwiki file. Changes syntax to grey out paragraphs in vimwiki areas. Maybe also automatically update abbrevs.
  
  What else?
