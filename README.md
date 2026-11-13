# goda-cmp-ext-copilot.vim

GitHub Copilot completion for [goda-cmp.vim](https://github.com/Shougo/goda-cmp.vim).

This source asks [copilot.lua](https://github.com/zbirenbaum/copilot.lua) for completions. It is a port of [ddc-source-copilot](https://github.com/Shougo/ddc-source-copilot) without its copilot.vim integration.

## Dependencies

- [goda-cmp.vim](https://github.com/Shougo/goda-cmp.vim)
- [goda.vim](https://github.com/Shougo/goda.vim)
- [copilot.lua](https://github.com/zbirenbaum/copilot.lua)
- Neovim

## Install

The source is a Go package that your goda-cmp configuration imports. Its Neovim side is embedded in the binary, so no plugin other than copilot.lua needs to be installed.

```sh
cd ~/.config/nvim/goda-cmp
go get github.com/airRnot1106/goda-cmp-ext-copilot.vim
```

## Configuration

```go
import "github.com/airRnot1106/goda-cmp-ext-copilot.vim/ext/source/copilot"

b.AddSource(copilot.New(copilot.Params{Copilot: "lua"}))
```

Add `"copilot"` to `Sources`, then rebuild with `:call goda_cmp#build()`.

A suggestion does not start with the typed text, so give the source no matchers and let it complete without typing:

```go
"copilot": {
	Mark:                  "[Copilot]",
	Matchers:              []string{},
	MinAutoCompleteLength: new(0),
	IsVolatile:            new(true),
	Timeout:               new(5000),
},
```

See `:help goda-cmp-ext-copilot`.
