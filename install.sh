sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

brew install zsh-autosuggestions zsh-syntax-highlighting
brew install fzf fd bat

git submodule update --init --recursive

brew install zoxide
