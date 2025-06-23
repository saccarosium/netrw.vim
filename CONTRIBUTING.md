# Contributing to Netrw.vim

## Developer guidelines

If you are using neovim, you are good to go!

If you are using vim make sure to:
- using a HUGE build of vim (check `vim --version`)
- enable the editorconfig plugin by putting the following snippet in your
  `vimrc`:
```vim
packadd editorconfig
```

## Reproducing an issue

Use the `minimalrc.vim` provided in the `contrib` directory

To test the issue with the minimalrc use:
- on nvim: `nvim --clean -u contrib/minimalrc.vim`
- on vim: `vim -u contrib/minimalrc.vim`
