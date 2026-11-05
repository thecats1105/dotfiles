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
# 1. Install chezmoi and age
brew install chezmoi age
# or via package manager / official script:
# sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Restore your age private key (e.g., from Proton Pass or secure backup)
mkdir -p ~/.config/chezmoi
cat <<'EOF' > ~/.config/chezmoi/key.txt
<YOUR_AGE_PRIVATE_KEY>
EOF
chmod 600 ~/.config/chezmoi/key.txt

# 3. Initialize and apply dotfiles
chezmoi init --apply https://github.com/thecats1105/dotfiles.git
```

### 2. Windows Setup

PowerShell을 **관리자 권한** 또는 개발자 모드가 활성화된 상태에서 실행합니다.

```powershell
# 1. Install chezmoi and age (via winget or scoop)
winget install twpayne.chezmoi
winget install FiloSottile.age
# or via scoop:
# scoop install chezmoi age

# 2. Restore your age private key
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\chezmoi" | Out-Null
Set-Content -Path "$env:USERPROFILE\.config\chezmoi\key.txt" -Value "<YOUR_AGE_PRIVATE_KEY>"

# 3. Initialize and apply dotfiles
chezmoi init --apply https://github.com/thecats1105/dotfiles.git
```

> **Note (Neovim on Windows):**
> chezmoi apply 시 `run_onchange_after_windows_link_nvim.ps1.tmpl` 스크립트가 실행되어, `%USERPROFILE%\.config\nvim` 경로를 `%LOCALAPPDATA%\nvim`으로 정션(Junction) 링크합니다.

---

## Daily Workflow

### Q. 설정 파일을 수정할 때 어디를 건드려야 하나요?

기본적으로 **둘 다 가능**하지만, 파일 종류에 따라 권장 방식이 다릅니다.

#### 1. 일반 설정 파일 (예: Neovim, Tmux 설정)

평소처럼 `~/.config/...`의 실제 파일을 바로 수정하고 테스트해도 됩니다. 수정 후 chezmoi 저장소에 동기화해 주면 됩니다.

```bash
# 1. 평소대로 홈 디렉토리 파일 수정
nvim ~/.config/tmux/tmux.conf

# 2. chezmoi에 변경사항 동기화
chezmoi re-add ~/.config/tmux/tmux.conf

# 3. 변경 확인 및 커밋
chezmoi cd
git status
git commit -am "feat: update tmux config"
git push
exit
```

또는 한 번에 편집하고 자동 적용하는 정석 방식:

```bash
chezmoi edit ~/.config/tmux/tmux.conf
# 편집기 저장 후 종료 시 자동으로 chezmoi 저장소에 반영됩니다.
# 바로 홈 디렉토리에 적용하려면 --apply 플래그 추가:
chezmoi edit --apply ~/.config/tmux/tmux.conf
```

#### 2. 템플릿 파일 (중요! 파일명 뒤에 `.tmpl`이 붙은 경우)

- 대상: `git/config.tmpl`, `starship.toml.tmpl`, `run_onchange_...tmpl` 등
- **주의:** `~/.config/git/config`처럼 이미 렌더링된 파일을 직접 수정하고 `chezmoi add/re-add`를 해버리면 **`{{ if eq .chezmoi.os "windows" }}` 같은 조건문 템플릿이 덮어씌워져 날아갈 수 있습니다.**
- 템플릿 파일은 반드시 아래 둘 중 하나의 방식으로 수정하세요:
  ```bash
  # 방법 A: chezmoi edit 사용
  chezmoi edit ~/.config/git/config

  # 방법 B: chezmoi 저장소 소스 파일 직접 수정
  chezmoi cd
  nvim dot_config/git/config.tmpl
  chezmoi apply  # 홈 디렉토리에 렌더링 적용
  ```

#### 3. 암호화된 시크릿 파일 (age)

- 대상: `encrypted_config-local.fish.age` 등
- 평문 파일(`~/.config/fish/config-local.fish`)을 수정했다면 `chezmoi re-add`로 다시 암호화하거나, `chezmoi edit`를 사용합니다.
  ```bash
  chezmoi edit ~/.config/fish/config-local.fish
  ```

---

## Useful Commands

| 명령어           | 설명                                                       |
| ---------------- | ---------------------------------------------------------- |
| `chezmoi diff`   | 현재 홈 디렉토리와 chezmoi 소스 간 차이점 확인             |
| `chezmoi status` | 변경된 파일 상태 목록 확인                                 |
| `chezmoi apply`  | chezmoi 소스의 변경사항을 홈 디렉토리에 반영               |
| `chezmoi update` | git pull + chezmoi apply를 한 번에 실행 (최신 상태 동기화) |
| `chezmoi cd`     | chezmoi 소스 디렉토리(`~/.local/share/chezmoi`)로 셸 진입  |
| `chezmoi verify` | 홈 디렉토리가 chezmoi 타겟과 일치하는지 검증               |
