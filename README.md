# 😸 kitty-projects.nvim

Code project management tool for Neovim.

## Philosophy

Frequently, I find myself working across multiple code repositories, switching back and forth between them. Vim sessions can work well for this, but major drawback is they only persist buffers and window layout, sacraficing key elements like embedded terminals and plugin state.

While Tmux is a common progression, it adds the overhead of learning a new tool: understanding how to manipulate windows, panes, tabs, and figuring out keybindings within terminals, all of which are possible within Neovim alone.

Many modern terminals, including Kitty, come with most of the functionality Tmux provides. Therefore, to avoid introducing an unnecessary layer and to maximize the use of Neovim's functionality, I developed this plugin. Its purpose is to leverage the multiplexing capabilities provided by Kitty, enabling comprehensive project management from within Neovim.

## Features

- Seamlessly manage multiple persistant Neovim instances
- Automatic loading of, and continouously updated, sessions
- Telescope integration

## How it works

kitty-projects.nvim uses the [remote control](https://sw.kovidgoyal.net/kitty/overview/#remote-control) capabilities of Kitty to manage multiple instances of Neovim, exposing a simplified API for managing these instances. Each [kitty window](https://sw.kovidgoyal.net/kitty/glossary/#term-window) maps to a single Neovim instance. This plugin works best with the [stack layout](https://sw.kovidgoyal.net/kitty/overview/#layouts), so only one Neovim instance as shown at any time.

## Installation

### Using lazy.nvim

```lua
return {
  'morgsmccauley/kitty-projects.nvim',
  config = function()
    require('kitty').setup()
  end
}
```

## Configuration

```lua
{
  command = 'zsh --login -c nvim', -- command used to start the Neovim instance
  project_paths = { -- list of project paths
    { vim.env.HOME .. '/Developer', exclude_hidden = true }, -- all subdirectories will be included from nested tables
    { vim.env.HOME .. '/.local/share/nvim/lazy', exclude_hidden = false },
    vim.env.HOME .. '/.dotfiles' -- list a single directory to be included
  }
}
```

By default, Kitty uses a non-login shell to run the command provided. If your setup relies on login initialization files being sourced, you can use `zsh --login -c nvim` to start Neovim within a login shell.

## Usage

Management is centred around [Telescope](https://github.com/nvim-telescope/telescope.nvim). To list all projects, bind, or execute the following:
```
Telescope kitty projects
```
Active projects will be listed first, these are annotated similar to buffer (`:h ls`) indicators:
- `%a` - current project
- `#a` - previous project
- `a` - active project

The previous project is always listed first to allow quick switching to it.

Within the Telescope picker, Projects can be managed via the following keybindings:
- `<Cr>` - Switch to project, launching it if required
- `<C-x>` - Close project
- `<C-r>` - Restart project, closing and relaunching
