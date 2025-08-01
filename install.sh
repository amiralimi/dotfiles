sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

brew install zsh-autosuggestions zsh-syntax-highlighting
brew install fzf fd bat

git submodule update --init --recursive

brew install zoxide
brew install micro
brew install --cask font-iosevka-nerd-font
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
brew install stow

stow -t ~/.config .config
