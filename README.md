# Dotfiles

Cross-platform dotfiles for **WSL (Ubuntu / Linux)** and **Windows**, managed by [chezmoi](https://www.chezmoi.io/) and secured with [age](https://github.com/FiloSottile/age) encryption.

## Managed Tools

- **Git**: Platform-aware configuration (GPG signing, delta pager, credential managers)
- **Starship**: Cross-platform prompt styling (inline on Windows, dual-line with clock on WSL)
- **Neovim**: Shared LazyVim configuration across both platforms (symlinked/junctioned to AppData on Windows)
- **Fish Shell**: WSL / Linux shell setup, functions, completions, and age-encrypted secrets
- **Tmux**: Linux terminal multiplexer with custom statusline and keybindings
- **PowerShell**: Windows PowerShell profile, scripts, and modules

---

## Setup Guide

### 1. WSL / Linux Setup

```bash
# Install chezmoi and age
brew install chezmoi age
# or via apt / curl:
# sh -c "$(curl -fsLS get.chezmoi.io)"

# Restore your age private key (from Proton Pass or secure backup)
mkdir -p ~/.config/chezmoi
cat <<'EOF' > ~/.config/chezmoi/key.txt
<YOUR_AGE_PRIVATE_KEY>
