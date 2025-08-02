# My Dotfiles

Minimal dotfiles setup for a productive Zsh terminal with oh-my-zsh, FZF-powered search, and clean defaults.

## Installation

```bash
git clone --recursive https://github.com/amiralimi/.dotfiles ~/.dotfiles
cd ~/.dotfiles
bash install.sh
```

### What’s Installed

- Oh My Zsh
- zsh-autosuggestions, zsh-syntax-highlighting
- fzf, fd, bat
- yazi
- yazi extensions: ripgrep, jq, sevenzip, poppler, resvg, imagemagick
- micro (lightweight terminal editor)
- zoxide (smarter cd)
- stow (manages dotfiles)
- Nerd fonts: Iosevka & Symbols-only

## Shortcuts & Commands Added

### FZF Keybindings

| Keybinding | Action                                                          |
|------------|-----------------------------------------------------------------|
| Ctrl+T     | Fuzzy find file with preview (uses bat)                         |
| Alt+C      | Fuzzy find directory (uses tree)                                |
| Ctrl+R     | Fuzzy search command history with preview and copy (⌘Y to copy) |


### Directory Navigation

| Command | Action                                                          |
|---------|-----------------------------------------------------------------|
| `z`     | `<dir>` Jump to frequently accessed folder                        |
| `zi`    | Interactive zoxide navigation (if fzf-zoxide is installed)      |

### Oh My Zsh Plugin Shortcuts 

#### gitignore
- `gi` - Create .gitignore files quickly
- `gi list` - List all available gitignore templates
- `gi [template]` - Generate .gitignore for specific language/framework

#### extract
- `extract <archive>` - Extract various archive types (.zip, .tar.gz, .rar, etc.)
- Automatically detects archive type and uses appropriate extraction tool

#### dotenv
- Automatically loads `.env` files in your current directory
- Sets environment variables from `.env` when entering directory

#### copypath
- `copypath` - Copy current directory path to clipboard
- `copypath <file>` - Copy specific file path to clipboard

#### sudo
- `esc esc` - Repeat last command with sudo
- `sudo !!` - Alternative syntax for running previous command as sudo

#### colored-man-pages
- Automatically adds syntax highlighting to man pages
- No additional commands - works automatically when viewing man pages

### fzf-git shortcuts

| Shortcut      | Description   |
|---------------|---------------|
| Ctrl+G Ctrl+B | Show branches |
| Ctrl+G Ctrl+F | Show files    |
| Ctrl+G Ctrl+R | Show remotes  |
| Ctrl+G Ctrl+S | Show stashes  |
| Ctrl+G Ctrl+T | Show tags     |

## Theme

Zsh prompt is using the Agnoster theme.

## Config Structure

```
.dotfiles/
├── .config/
│   ├── ghostty/
│   └── yazi/
├── modules/
│   └── fzf-git.sh/
├── .zshrc
└── install.sh
```
