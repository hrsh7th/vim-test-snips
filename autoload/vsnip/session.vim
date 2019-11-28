let s:Snippet = vsnip#session#snippet#import()

"
" import.
"
function! vsnip#session#import() abort
  return s:Session
endfunction

let s:Session = {}

"
" new.
"
function! s:Session.new(bufnr, position, text) abort
  return extend(deepcopy(s:Session), {
        \   'bufnr': a:bufnr,
        \   'buffer': getbufline(a:bufnr, '^', '$'),
        \   'tabstop': -1,
        \   'snippet': s:Snippet.new(a:position, a:text),
        \   'changenr': changenr(),
        \   'changenrs': []
        \ })
endfunction

"
" insert.
"
function! s:Session.insert() abort
  " insert snippet.
  call lamp#view#notice#add({ 'lines': ['`Snippet`: session activated.'] })
  call lamp#view#edit#apply(self.bufnr, [{
        \   'range': {
        \     'start': self.snippet.position,
        \     'end': self.snippet.position
        \   },
        \   'newText': self.snippet.text()
        \ }])

  " save first state.
  let self.changenr = changenr()
  call add(self.changenrs, self.changenr)
  call self.snippet.store(self.changenr)

  " move to end of snippet after snippet insertion.
  let l:range = self.snippet.range()
  call cursor(l:range.end.line - 1, l:range.end.character - 1)
endfunction

"
" jump.
"
function! s:Session.jump() abort
  let l:jump_point = self.snippet.get_next_jump_point(self.tabstop)

  let self.tabstop = l:jump_point.placeholder.id

  " move to end position.
  call cursor(l:jump_point.range.end.line + 1, l:jump_point.range.end.character + 1)

  " if jump_point has range, select range.
  if l:jump_point.range.start.character != l:jump_point.range.end.character
    let l:cmd = ''
    if mode()[0] ==# 'i'
      let l:cmd .= "\<Esc>"
    else
      let l:cmd .= 'h'
    endif
    let l:cmd .= printf('v%sh', strlen(l:jump_point.placeholder.text()) - 1)
    let l:cmd .= "\<C-g>"
    execute printf('normal! %s', l:cmd)
  endif
endfunction

"
" on_text_changed.
"
function! s:Session.on_text_changed() abort

  " compute diff.
  let l:buffer = getbufline(self.bufnr, '^', '$')
  let l:diff = lamp#server#document#diff#compute(self.buffer, l:buffer)
  let self.buffer = l:buffer
  if l:diff.rangeLength == 0 && l:diff.text ==# ''
    return
  endif

  let l:changenr = changenr()

  " redo/undo.
  if index(self.changenrs, l:changenr) >= 0 && self.changenr != l:changenr
    call self.snippet.restore(l:changenr)
    let self.changenr = l:changenr
    return
  endif

  " snippet text is not changed.
  if !self.is_dirty(l:buffer)
    return
  endif

  " if follow succeeded, sync placeholders and write back to the buffer.
  if self.snippet.follow(l:diff)
    undojoin | call lamp#view#edit#apply(self.bufnr, self.snippet.sync())
    let self.buffer = getbufline(self.bufnr, '^', '$')
    let self.changenr = changenr()
    call add(self.changenrs, self.changenr)
    call self.snippet.store(self.changenr)
  else
    call vsnip#deactivate()
  endif
endfunction

"
" is_dirty.
"
function! s:Session.is_dirty(buffer)
  return self.snippet.text() !=# self.text_from_buffer(a:buffer)
endfunction


"
" text_from_buffer.
"
function! s:Session.text_from_buffer(buffer)
  let l:range = self.snippet.range()

  let l:text = ''
  for l:i in range(l:range.start.line, l:range.end.line)
    if len(a:buffer) <= l:i
      return v:true
    endif

    " same line.
    if l:i == l:range.start.line && l:i == l:range.end.line
      let l:text = a:buffer[l:i][l:range.start.character : l:range.end.character - 1]
      break

    " multi start.
    elseif l:i == l:range.start.line
      let l:text .= a:buffer[l:i][l:range.start.character : -1] . "\n"

    " multi middle.
    elseif l:i != l:range.end.line
      let l:text .= a:buffer[l:i] . "\n"

    " multi end.
    elseif l:i == l:range.end.line
      let l:text .= a:buffer[l:i][0 : l:range.end.character - 1]
    endif
  endfor

  return l:text
endfunction

