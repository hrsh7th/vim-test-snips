" MIT License
"
" Copyright 2009-2010 Michael Sanders. All rights reserved.

" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:

" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.

" The software is provided "as is", without warranty of any kind, express or
" implied, including but not limited to the warranties of merchantability,
" fitness for a particular purpose and noninfringement. In no event shall the
" authors or copyright holders be liable for any claim, damages or other
" liability, whether in an action of contract, tort or otherwise, arising from,
" out of or in connection with the software or the use or other dealings in the
" software." From https://github.com/garbas/vim-snipmate


" Simple indent support for SnipMate snippets files

if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal nosmartindent
setlocal indentkeys=!^F,o,O,=snippet,=extends
setlocal indentexpr=GetSnippetIndent()

if exists("*GetSnippetIndent")
  finish
endif

function! GetSnippetIndent()
  let line = getline(v:lnum)
  let prev_lnum = v:lnum - 1
  let prev_line = prev_lnum != 0 ? getline(prev_lnum) : ""

  if line =~# '\v^(snippet|extends) '
    return 0
  elseif indent(v:lnum) > 0
    return indent(v:lnum)
  elseif prev_line =~# '^snippet '
    return &sw
  elseif indent(prev_lnum) > 0
    return indent(prev_lnum)
  endif

  return 0
endfunction
