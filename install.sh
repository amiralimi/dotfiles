set -euo pipefail

install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "Oh My Zsh is already installed."
        return
    fi
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_ohmyzsh_plugins() {
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    if [[ ! -d "${plugins_dir}/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "${plugins_dir}/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions is already installed."
    fi

    if [[ ! -d "${plugins_dir}/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "${plugins_dir}/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting is already installed."
    fi
}

linux_arch_tag() {
    case "$(uname -m)" in
    x86_64 | amd64) echo "amd64" ;;
    aarch64 | arm64) echo "arm64" ;;
    *)
        echo "Unsupported arch: $(uname -m)" >&2
        return 1
        ;;
    esac
}

gnu_arch_tag() {
    case "$(uname -m)" in
    x86_64 | amd64) echo "x86_64" ;;
    aarch64 | arm64) echo "aarch64" ;;
    *)
        echo "Unsupported arch: $(uname -m)" >&2
        return 1
        ;;
    esac
}

linux_release_flavor() {
    case "$(uname -m)" in
        x86_64|amd64)  echo "linux64-static" ;;
        aarch64|arm64) echo "linux-arm64" ;;
        *) 
            echo "Unsupported arch: $(uname -m)" >&2
            return 1
            ;;
    esac
}

github_latest_tag() {
    local repo="$1" tmp
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' RETURN
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" -o "$tmp"
    sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$tmp" | head -n1
}

install_release_binary() {
    local repo="$1"
    local asset_tpl="$2"
    local bin_in_tar="$3"
    local dest_name="$4"

    local tag raw_tag_no_v os arch gnu_arch asset url tmp
    tag="$(github_latest_tag "$repo")"
    raw_tag_no_v="${tag#v}" # strip leading v if present
    os="linux"
    arch="$(linux_arch_tag)"
    gnu_arch="$(gnu_arch_tag)"
    release_flavor="$(linux_release_flavor)"

    # Render template
    asset="${asset_tpl}"
    asset="${asset//\{tag\}/$tag}"
    asset="${asset//\{tag_no_v\}/$raw_tag_no_v}"
    asset="${asset//\{os\}/$os}"
    asset="${asset//\{arch\}/$arch}"
    asset="${asset//\{gnu_arch\}/$gnu_arch}"
    asset="${asset//\{release_flavor\}/$release_flavor}"

    url="https://github.com/${repo}/releases/download/${tag}/${asset}"

    echo "Downloading ${url}"
    curl -fsSL "$url" -o "${TMP_DIR}/${asset}"

    echo "Extracting ${asset} to ${TMP_DIR}"
    case "$asset" in
    *.tar.gz | *.tgz) tar -xzf "${TMP_DIR}/${asset}" -C "${TMP_DIR}" ;;
    *.tar.xz) tar -xJf "${TMP_DIR}/${asset}" -C "${TMP_DIR}" ;;
    *.zip) unzip -q "${TMP_DIR}/${asset}" -d "${TMP_DIR}" ;;
    *)
        echo "Unknown archive format: $asset" >&2
        return 1
        ;;
    esac

    # If a specific path is provided, use it; otherwise try to find an executable matching dest_name
    local src="${TMP_DIR}/$bin_in_tar"
    if [[ -z "$bin_in_tar" || ! -f "$src" ]]; then
        # Try to discover the binary automatically
        src="$(find "${TMP_DIR}" -type f -name "$dest_name" -perm -u+x | head -n1 || true)"
    fi

    if [[ -z "${src:-}" || ! -f "$src" ]]; then
        echo "Failed to locate binary '$bin_in_tar' (or '$dest_name') in the archive." >&2
        return 1
    fi

    echo "Installing to ${PREFIX}/${dest_name}"
    install -m 0755 "$src" "${PREFIX}/${dest_name}"
    echo "Installed: ${PREFIX}/${dest_name}"
}

cp_config() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
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
        install_ohmyzsh_plugins

        TMP_DIR="$(mktemp -d)"
        trap 'rm -rf "$TMP_DIR"' EXIT

        PREFIX="$HOME/.local/bin"
        mkdir -p "$PREFIX"

        if [[ ! -f "$PREFIX/fzf" ]]; then
            install_release_binary \
                "junegunn/fzf" \
                "fzf-{tag_no_v}-linux_{arch}.tar.gz" \
                "fzf" \
                "fzf"
        else
            echo "fzf is already installed at $PREFIX/fzf"
        fi

        if [[ ! -f "$PREFIX/fd" ]]; then
            install_release_binary \
                "sharkdp/fd" \
                "fd-v{tag_no_v}-{gnu_arch}-unknown-linux-gnu.tar.gz" \
                "fd" \
                "fd"
        else
            echo "fd is already installed at $PREFIX/fd"
        fi
        if [[ ! -f "$PREFIX/bat" ]]; then
            install_release_binary \
                "sharkdp/bat" \
                "bat-v{tag_no_v}-{gnu_arch}-unknown-linux-gnu.tar.gz" \
                "bat" \
                "bat"
        else
            echo "bat is already installed at $PREFIX/bat"
        fi

        git submodule update --init --recursive

        if [[ ! -f "$PREFIX/zoxide" ]]; then
            install_release_binary \
                "ajeetdsouza/zoxide" \
                "zoxide-{tag_no_v}-{gnu_arch}-unknown-linux-musl.tar.gz" \
                "zoxide" \
                "zoxide"
        else
            echo "zoxide is already installed at $PREFIX/zoxide"
        fi

        if [[ ! -f "$PREFIX/micro" ]]; then
            install_release_binary \
                "zyedidia/micro" \
                "micro-{tag_no_v}-{release_flavor}.tar.gz" \
                "micro" \
                "micro"
        else
            echo "micro is already installed at $PREFIX/micro"
        fi

        if [[ ! -f "$PREFIX/yazi" ]]; then
            install_release_binary \
                "sxyazi/yazi" \
                "yazi-{gnu_arch}-unknown-linux-musl.zip" \
                "yazi" \
                "yazi"
        else
            echo "yazi is already installed at $PREFIX/yazi"
        fi
   fi

    echo "Linux installation complete."

    mkdir -p "$HOME/.config"

    cp_config "$DOTFILES_HOME/.config/yazi" "$HOME/.config/yazi"

}

# get input args for --sudo or --no-sudo
USE_SUDO="auto" # auto | yes | no
DOTFILES_HOME="$HOME/.dotfiles"

for arg in "$@"; do
    case "$arg" in
    --sudo) USE_SUDO="yes" ;;
    --no-sudo) USE_SUDO="no" ;;
    *)
        echo "Unknown option: $arg" >&2
        exit 1
        ;;
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
