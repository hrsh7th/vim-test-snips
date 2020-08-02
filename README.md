# vim-vsnip

VSCode(LSP)'s snippet feature in vim.


# DEMO

![nested-snippet-expansion](https://user-images.githubusercontent.com/629908/76817423-1e165180-6846-11ea-95a1-d827afa744d8.gif)


# Concept

- Standard features written in Pure Vim script.
- Implement LSP snippet format
- Support LSP-client and completion-engine by [vim-vsnip-integ](https://github.com/hrsh7th/vim-vsnip-integ)
  - LSP-client
    - [vim-lsp](https://github.com/prabirshrestha/vim-lsp)
    - [vim-lsc](https://github.com/natebosch/vim-lsc)
    - [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim)
    - [neovim built-in lsp](https://github.com/neovim/neovim)
    - [vim-lamp](https://github.com/hrsh7th/vim-lamp)
  - completion-engine
    - [deoplete.nvim](https://github.com/Shougo/deoplete.nvim)
    - [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)
    - [vim-mucomplete](https://github.com/lifepillar/vim-mucomplete)
    - [completion-nvim](https://github.com/haorenW1025/completion-nvim)


# Features

- Nested placeholders
  - You can define snippet like `console.log($1${2:, $1})$0`
- Nested snippet expansion
    - You can expand snippet even if you already activated other snippet (it will be merged as one snippet)
- Load snippet from VSCode extension
    - If you install VSCode extension via `Plug 'microsoft/vscode-python'`, vsnip will load those snippets.
- Support many LSP-client & completion-engine
    - You can get how to integrate those plugins in [here](https://github.com/hrsh7th/vim-vsnip-integ).


# Usage

### 1. Install

You can use your favorite plugin managers to install this plugin.

```viml
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

call dein#add('hrsh7th/vim-vsnip')
call dein#add('hrsh7th/vim-vsnip-integ')

NeoBundle 'hrsh7th/vim-vsnip'
NeoBundle 'hrsh7th/vim-vsnip-integ'
```


### 2. Setting

```viml
" NOTE: You can use other key to expand snippet.

" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
nmap        <C-l>   <Plug>(vsnip-select-text)
xmap        <C-l>   <Plug>(vsnip-select-text)
smap        <C-l>   <Plug>(vsnip-select-text)
nmap        <C-j>   <Plug>(vsnip-cut-text)
xmap        <C-j>   <Plug>(vsnip-cut-text)
smap        <C-j>   <Plug>(vsnip-cut-text)
```


### 3. Create your own snippet

Snippet file will store to `g:vsnip_snippet_dir` per filetype.

1. Open some file (example: `Sample.js`)
2. Invoke `:VsnipOpen` command.
3. Edit snippet.

```json
{
  "Class": {
    "prefix": ["class"],
    "body": [
      "class $1 ${2:extends ${3:Parent} }{",
      "\tconstructor() {",
      "\t\t$0",
      "\t}",
      "}"
    ],
    "description": "Class definition template."
  }
}
```

The snippet format was described in [here](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_snippet-syntax) or [here](https://github.com/Microsoft/language-server-protocol/blob/master/snippetSyntax.md).


# Development

### How to run test it?

You can run `npm run test` after install [vim-themis](https://github.com/thinca/vim-themis).


### How sync same tabstop placeholders?

1. compute the `user-diff` ... `s:Session.flush_changes`
2. reflect the `user-diff` to snippet ast ... `s:Snippet.follow`
3. reflect the `sync-diff` to buffer content ... `s:Snippet.sync & s:Session.flush_changes`


