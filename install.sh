set -euo pipefail

install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "Oh My Zsh is already installed."
        return
    fi
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_mac() {
    install_ohmyzsh

    brew install zsh-autosuggestions zsh-syntax-highlighting
    brew install fzf fd bat

    git submodule update --init --recursive

    brew install zoxide
    brew install micro
    brew install --cask font-iosevka-nerd-font
    brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font
    brew install stow

    stow -t ~/.config .config
}


install_linux() {
    echo "Installing on Linux..."
    local USE_SUDO="$1"
    if [[ "$USE_SUDO" == "auto" ]]; then
        echo "Please specify --sudo or --no-sudo"
        exit 1
    fi

    if [[ "$USE_SUDO" == "no" ]]; then
        install_ohmyzsh
    fi
}

# get input args for --sudo or --no-sudo
USE_SUDO="auto"  # auto | yes | no

for arg in "$@"; do
  case "$arg" in
    --sudo) USE_SUDO="yes" ;;
    --no-sudo) USE_SUDO="no" ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_linux "$USE_SUDO"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_mac
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi
