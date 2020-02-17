# vim-rctags ![](https://github.com/stackline/vim-rctags/workflows/Test/badge.svg)

Async tag generator plugin for neovim.

## Features

* Execute ctags asynchronously
* Suppress double execution of ctags for each repository
* Separates the process of creating and updating a tag file (because some information is missing in the tag file being created)
* Perform a tag jump with a relative path from the top-level directory of the working tree (because the latter path may be omitted if it is an absolute path)

## Installing

When using vim-plug

```
Plug 'prabirshrestha/async.vim'
Plug 'stackline/vim-rctags'
```
