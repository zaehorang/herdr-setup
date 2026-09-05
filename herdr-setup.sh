#!/usr/bin/env bash
#
# herdr + Ghostty 개발 환경 셋업.
#
# 네 단계로 나뉘어 있고 각각 독립적으로 끌 수 있다. 바로 아래 토글에서
# 필요 없는 단계를 0으로 바꾸거나 그 줄을 통째로 주석 처리하면 건너뛴다.
#
#   [1] 설치           herdr(formula), Ghostty(cask)
#   [2] 키 바인딩      ~/.config/herdr/config.toml
#   [3] Ghostty 설정   ~/.config/ghostty/config.ghostty
#   [4] 셸             ~/.zshrc 의 alias hd="herdr"
#
# 여러 번 실행해도 안전하다. 기존 파일은 내용이 다를 때만 백업 후 교체한다.
#
# 예) 이미 설치된 머신에서 키 바인딩만 다시 적용:
#       STEP_INSTALL=0 STEP_GHOSTTY=0 STEP_SHELL=0 ./herdr-setup.sh

set -euo pipefail

# ============================================================== 단계 토글
# 끄려면 0으로 바꾸거나 해당 줄을 주석 처리할 것 (주석 처리해도 꺼진다).

STEP_INSTALL=${STEP_INSTALL:-1}   # [1] Homebrew로 herdr, Ghostty 설치
STEP_KEYS=${STEP_KEYS:-1}         # [2] herdr 키 바인딩
STEP_GHOSTTY=${STEP_GHOSTTY:-1}   # [3] Ghostty 설정
STEP_SHELL=${STEP_SHELL:-1}       # [4] zsh alias

# ============================================================== 공용 함수

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
skip() { printf '    %s\n' "$1"; }
off()  { printf '\033[2m--- %s (건너뜀)\033[0m\n' "$1"; }

# 위 토글은 주석 처리될 수 있으므로 항상 기본값 0으로 읽는다.
enabled() { [[ ${!1:-0} == 1 ]]; }

# 대상 경로에 원하는 내용을 배치한다. 이미 같은 내용이면 아무것도 하지 않고,
# 다른 내용이면 <파일>.bak.<타임스탬프> 로 백업한 뒤 교체한다.
install_file() {
  local dest=$1 content=$2

  mkdir -p "$(dirname "$dest")"

  if [[ -f $dest ]] && [[ $(cat "$dest") == "$content" ]]; then
    skip "이미 최신: $dest"
    return
  fi

  if [[ -f $dest ]]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    cp "$dest" "$backup"
    skip "백업: $backup"
  fi

  printf '%s\n' "$content" > "$dest"
  skip "작성: $dest"
}

# ============================================================== [1] 설치

if enabled STEP_INSTALL; then
  info "[1] 설치"

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew가 필요하다. 먼저 설치할 것:" >&2
    echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' >&2
    exit 1
  fi

  if brew list --formula herdr >/dev/null 2>&1; then
    skip "herdr: 이미 설치됨 ($(herdr --version))"
  else
    brew install herdr
  fi

  if brew list --cask ghostty >/dev/null 2>&1; then
    skip "Ghostty: 이미 설치됨"
  else
    brew install --cask ghostty
  fi
else
  off "[1] 설치"
fi

# ============================================================== [2] 키 바인딩
#
# prefix = cmd+p
#
#            생성            제거
#   pane     prefix+p        prefix+shift+p
#   tab      prefix+t        prefix+shift+t
#   space    prefix+s        prefix+shift+s
#   worktree prefix+w        prefix+shift+w
#
# 위 8개에 자리를 뺏긴 기본 바인딩은 빈 문자열로 비워야 한다. 비우지 않으면
# 충돌로 config 파싱이 실패하고 herdr가 조용히 기본값(ctrl+b)으로 돌아간다.

if enabled STEP_KEYS; then
  info "[2] herdr 키 바인딩"
  install_file "$HOME/.config/herdr/config.toml" 'onboarding = false

[ui]
agent_panel_sort = "spaces"

[keys]
# Ghostty가 cmd+a(select_all), cmd+d(new_split)를 이미 잡고 있어서 그쪽으로는
# 키가 내려오지 않는다. cmd+p는 Ghostty에 바인딩이 없어 그대로 통과한다.
prefix = "cmd+p"

# 생성/제거를 같은 글자로 묶는다: 생성은 prefix+<키>, 제거는 prefix+shift+<키>.
#   p = pane, t = tab, s = space(workspace), w = worktree
split_vertical  = "prefix+p"
close_pane      = "prefix+shift+p"
new_tab         = "prefix+t"
close_tab       = "prefix+shift+t"
new_workspace   = "prefix+s"
close_workspace = "prefix+shift+s"
new_worktree    = "prefix+w"
remove_worktree = "prefix+shift+w"

# prefix+s를 new_workspace에 내주고 macOS 앱 설정 관례인 쉼표로 옮긴다.
settings = "prefix+comma"

# 위 바인딩에 키를 뺏긴 나머지. 비워두지 않으면 충돌한다.
previous_tab     = ""  # 원래 prefix+p
workspace_picker = ""  # 원래 prefix+w
rename_pane      = ""  # 원래 prefix+shift+p
rename_tab       = ""  # 원래 prefix+shift+t
rename_workspace = ""  # 원래 prefix+shift+w

# goto는 prefix+g 기본값 그대로 살아있다 (worktree가 w로 옮겨가면서 g가 비었다).'
  herdr config check
else
  off "[2] herdr 키 바인딩"
fi

# ============================================================== [3] Ghostty 설정
#
# 파일명이 config가 아니라 config.ghostty인 점에 주의. Ghostty 1.3.1에서는
# 이 이름도 로드되는 것을 ghostty +show-config 로 확인했다. 업그레이드 후
# 설정이 안 먹으면 파일명을 config로 바꿔볼 것.

if enabled STEP_GHOSTTY; then
  info "[3] Ghostty 설정"
  install_file "$HOME/.config/ghostty/config.ghostty" '# Opaque background
background-opacity = 1
font-size = 18
theme = IR Black
split-divider-color = #3A3F4B

# Cursor: keep a static block cursor even with shell integration enabled
cursor-style = block
cursor-style-blink = false
shell-integration-features = no-cursor

# Notify only for long commands that finish while Ghostty is unfocused
notify-on-command-finish = unfocused
notify-on-command-finish-action = no-bell,notify
notify-on-command-finish-after = 30s

# Keep stable updates visible without silently changing the brew-installed app
auto-update = check
auto-update-channel = stable

# Splits
keybind = super+d=new_split:right
keybind = super+alt+arrow_left=goto_split:left
keybind = super+alt+arrow_right=goto_split:right
keybind = super+alt+arrow_up=goto_split:up
keybind = super+alt+arrow_down=goto_split:down
keybind = super+shift+==equalize_splits

# Tabs
keybind = super+arrow_left=previous_tab
keybind = super+arrow_right=next_tab'
else
  off "[3] Ghostty 설정"
fi

# ============================================================== [4] 셸

if enabled STEP_SHELL; then
  info "[4] zsh alias"
  if grep -q '^alias hd=' "$HOME/.zshrc" 2>/dev/null; then
    skip "이미 있음: alias hd"
  else
    printf '\n# Launch herdr with hd\nalias hd="herdr"\n' >> "$HOME/.zshrc"
    skip ' 추가: alias hd="herdr" -> ~/.zshrc'
  fi
else
  off "[4] zsh alias"
fi

# ============================================================== 마무리

info "완료"
cat <<'EOF'

    적용하려면:
      source ~/.zshrc                 # [4] hd alias
      herdr server reload-config      # [2] herdr 서버가 이미 실행 중일 때만
      Ghostty 재시작 또는 cmd+shift+, # [3] Ghostty 설정 reload

    herdr prefix 는 cmd+p. 도움말은 cmd+p 다음 ? 를 누를 것.
EOF
