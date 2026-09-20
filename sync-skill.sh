#!/usr/bin/env bash
#
# herdr 에이전트 스킬을 설치된 바이너리와 맞춘다.
#
# 정본은 바이너리다. `herdr --skill` 이 자기 버전에 맞는 SKILL.md 를 뱉으므로
# GitHub 에서 따로 받아올 필요가 없다. 받아오면 brew 로 깐 바이너리와 버전이
# 어긋난다 (실제로 어긋나 있었다).
#
# 세션 시작 훅에서 매번 돌기 때문에 두 가지를 지킨다:
#   - 바뀐 게 없으면 아무것도 출력하지 않는다
#   - 무슨 일이 있어도 0 으로 끝난다 (세션 시작을 막지 않는다)
#
# 단독 실행도 되고 herdr-setup.sh [5] 단계도 이 파일을 부른다.

set -uo pipefail

DEST="$HOME/.agents/skills/herdr/SKILL.md"
LINK="$HOME/.claude/skills/herdr"

# herdr 가 없으면 할 일이 없다. 설치 전 머신에서 훅이 도는 경우.
command -v herdr >/dev/null 2>&1 || exit 0

latest=$(herdr --skill 2>/dev/null) || exit 0

# 모양이 스킬 파일일 때만 받아들인다. 비어있지 않은지만 보면, herdr 가 언젠가
# 경고 문구나 잘린 출력을 뱉을 때 그걸 그대로 SKILL.md 에 덮어쓰게 된다.
[[ $latest == "---"* && $latest == *"name: herdr"* ]] || exit 0

if [[ ! -f $DEST ]] || [[ $(cat "$DEST") != "$latest" ]]; then
  mkdir -p "$(dirname "$DEST")"
  if [[ -f $DEST ]]; then
    cp "$DEST" "$DEST.bak.$(date +%Y%m%d%H%M%S)"
  fi
  printf '%s\n' "$latest" > "$DEST"
  echo "herdr 스킬 갱신됨 ($(herdr --version 2>/dev/null))"
fi

# npx 가 해주던 심링크. 없을 때만 만든다.
if [[ ! -e $LINK ]]; then
  mkdir -p "$(dirname "$LINK")"
  ln -s ../../.agents/skills/herdr "$LINK" 2>/dev/null || true
fi

exit 0
