# prettier-indent.nvim

A small Neovim plugin that automatically adjusts indentation (`shiftwidth`, `tabstop`, `expandtab`) based on your project's Prettier configuration (`.prettierrc.js`, `prettier.config.js`, etc).

## Requirements

- Neovim 0.7+
- Node.js installed (for parsing JS configs)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "2nal2/prettier-indent.nvim",
    event = "VeryLazy",
    lazy = true,
}
