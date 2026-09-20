# herdr-setup

macOS에서 [herdr](https://herdr.dev) + [Ghostty](https://ghostty.org) 개발 환경을
새 머신에 그대로 재현하는 셋업 스크립트.

## 빠른 시작

```sh
git clone git@github.com:zaehorang/herdr-setup.git
cd herdr-setup
./herdr-setup.sh
```

실행 후 적용:

```sh
source ~/.zshrc                 # hd alias
herdr server reload-config      # herdr 서버가 이미 실행 중일 때만
```

Ghostty는 재시작하거나 `cmd+shift+,` 로 설정을 다시 읽는다.

## 새 머신에서

```sh
git clone https://github.com/zaehorang/herdr-setup.git
cd herdr-setup
./herdr-setup.sh          # Homebrew 가 먼저 필요하다
source ~/.zshrc
```

확인할 것 넷:

| 확인 | 명령 | 기대 |
| --- | --- | --- |
| 키 바인딩 | `herdr config check` | `config: ok` |
| Ghostty 설정 | `/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config \| grep font-size` | `font-size = 18` |
| 스킬 최신 | `diff <(herdr --skill) ~/.agents/skills/herdr/SKILL.md` | 출력 없음 |
| 스킬 동작 | herdr 페인 안에서 `echo $HERDR_ENV` | `1` |

스크립트가 실패한 단계가 있으면 마지막에 빨간 줄로 알리고 종료 코드 `1` 로 끝난다.

에이전트에게 맡겨도 된다:

> herdr-setup README 보고 이 머신 셋업해줘

## 하는 일

| 단계 | 내용 | 대상 |
| --- | --- | --- |
| `[1]` 설치 | `brew install herdr`, `brew install --cask ghostty` | — |
| `[2]` 키 바인딩 | herdr prefix 및 생성/제거 바인딩 | `~/.config/herdr/config.toml` |
| `[3]` Ghostty 설정 | 폰트·테마·스플릿/탭 키바인딩 | `~/.config/ghostty/config.ghostty` |
| `[4]` 셸 | `alias hd="herdr"` · 스킬 동기화 한 줄 | `~/.zshrc` |
| `[5]` 에이전트 스킬 | `herdr --skill` 을 파일로 (`sync-skill.sh`) | `~/.agents/skills/herdr` |

여러 번 실행해도 안전하다. 파일은 내용이 다를 때만 `<파일>.bak.<타임스탬프>` 로
백업한 뒤 교체하고, 같으면 손대지 않는다. alias 도 중복 추가하지 않는다.

## 단계 건너뛰기

스크립트 상단의 토글을 쓴다. 세 가지 방법 모두 동작한다.

```sh
# 1. 값을 0으로
STEP_INSTALL=${STEP_INSTALL:-0}

# 2. 줄을 통째로 주석 처리
#STEP_INSTALL=${STEP_INSTALL:-1}

# 3. 실행할 때 환경변수로
STEP_INSTALL=0 STEP_GHOSTTY=0 STEP_SHELL=0 ./herdr-setup.sh
```

건너뛴 단계는 `--- [1] 설치 (건너뜀)` 으로 표시된다.

이미 셋업된 머신에서 키 바인딩만 다시 밀어넣을 때:

```sh
STEP_INSTALL=0 STEP_GHOSTTY=0 STEP_SHELL=0 ./herdr-setup.sh
herdr server reload-config
```

## 키 바인딩

prefix 는 **`cmd+p`**. 도움말은 `cmd+p` 다음 `?`.

생성은 `prefix+<키>`, 제거는 `prefix+shift+<키>` 로 짝을 맞췄다.

| | 생성 | 제거 |
| --- | --- | --- |
| **p**ane (vertical split) | `prefix+p` | `prefix+shift+p` |
| **t**ab | `prefix+t` | `prefix+shift+t` |
| **s**pace (workspace) | `prefix+s` | `prefix+shift+s` |
| **w**orktree | `prefix+w` | `prefix+shift+w` |

그 밖에 기본값에서 옮긴 것:

- `settings` → `prefix+,` (`prefix+s` 를 workspace 생성에 내줬다)

위 바인딩에 자리를 뺏겨서 **비워둔** 기본 바인딩:

| 없어진 것 | 원래 키 | 대체 |
| --- | --- | --- |
| `previous_tab` | `prefix+p` | `prefix+n`(next_tab) 순회, `prefix+1..9` 직접 이동 |
| `workspace_picker` | `prefix+w` | `goto` (`prefix+g`) |
| `rename_pane` | `prefix+shift+p` | 없음 |
| `rename_tab` | `prefix+shift+t` | 없음 |
| `rename_workspace` | `prefix+shift+w` | 없음 |

## 에이전트 스킬

`[5]` 단계가 herdr 공식 스킬을 전역 설치한다. 코딩 에이전트가 herdr CLI로
페인/탭/워크스페이스를 살펴보고, 포커스를 뺏지 않고 페인을 쪼개고, 다른 페인의
출력을 읽을 수 있게 된다.

**정본은 설치된 바이너리다.** `herdr --skill` 이 자기 버전에 맞는 SKILL.md 를
그대로 뱉으므로 그걸 파일로 쓴다.

```sh
./sync-skill.sh          # [5] 단계가 부르는 것과 같은 스크립트
```

`~/.agents/skills/herdr` 에 설치되고 Claude Code 쪽(`~/.claude/skills/herdr`)으로는
심링크가 걸린다. 내용이 다를 때만 백업 후 교체하므로 여러 번 돌려도 안전하다.

**herdr 를 업그레이드하면 스킬도 다시 맞춰야 한다.** 바이너리에 없던 명령이
생겨도 스킬이 옛날 것이면 에이전트가 그 기능을 모른다.

`[4]` 단계가 이걸 자동으로 만든다 — `.zshrc` 에 한 줄을 넣어 **새 셸이 열릴
때마다**(= 새 herdr 페인마다) 맞춘다. 13ms 걸리고 바뀐 게 없으면 아무것도
출력하지 않는다.

각 에이전트의 세션 훅에 따로 넣는 방법도 있지만 셸 쪽이 낫다. 에이전트 종류를
가리지 않아 Claude Code·Codex 가 한 번에 커버되고, 설정 파일(JSON)을 망가뜨릴
길이 없다.

```sh
diff <(herdr --skill) ~/.agents/skills/herdr/SKILL.md   # 무출력이면 최신
```

> GitHub 에서 받아오는 `npx skills add herdrdev/herdr` 는 쓰지 않는다. brew 로 깐
> 바이너리와 버전이 따로 놀아 실제로 어긋났었다. Node.js 의존도 사라진다.

**스킬은 `HERDR_ENV=1` 일 때만 동작한다.** 이 값은 herdr 가 관리하는 페인 안에서만
설정되므로, 에이전트는 herdr 페인 안에서 띄워야 한다. 밖에서 띄우면 스킬이
herdr 안이 아니라고 말하고 멈춘다.

```sh
echo $HERDR_ENV   # 1 이어야 한다
```

## 알아둘 것

**prefix 로 cmd 조합을 쓸 때 Ghostty가 먼저 가로챈다.**
`cmd+a`(select_all), `cmd+d`(new_split), `cmd+t`, `cmd+w` 는 Ghostty 바인딩이라
herdr 까지 키가 내려오지 않는다. `cmd+p` 는 Ghostty에 바인딩이 없어서 통과한다.
다른 키로 바꾸려면 먼저 확인할 것:

```sh
ghostty +show-config | grep 'keybind = super+'
```

**터미널은 `shift+space` 를 일반 `space` 와 구분하지 못한다.**
kitty keyboard protocol 이 필요한데 이 조합에서는 동작하지 않았다.
prefix 로 쓰면 스페이스를 칠 때마다 prefix 모드가 켜진다. 쓰지 말 것.

**뺏긴 바인딩은 반드시 빈 문자열로 비워야 한다.**
비우지 않으면 충돌로 config 파싱이 실패하고, herdr 가 조용히 기본값(`ctrl+b`)으로
돌아간다. 에러 없이 그냥 안 먹는 것처럼 보이므로 알아채기 어렵다.
바꾼 뒤에는 항상 확인할 것:

```sh
herdr config check
```

**Ghostty 설정 파일명이 `config` 가 아니라 `config.ghostty` 다.**
Ghostty 1.3.1 에서는 이 이름도 로드되는 것을 `ghostty +show-config` 로 확인했다.
업그레이드 후 설정이 안 먹으면 파일명을 `config` 로 바꿔볼 것.

**`prefix` 는 키를 하나만 받는다.** 교체이지 추가가 아니라서, 바꾸면 기존
`ctrl+b` 는 더 이상 동작하지 않는다. 배열(`["cmd+p", "ctrl+b"]`)도 받지 않는다.

## 되돌리기

```sh
herdr config reset-keys && herdr server reload-config   # 키 바인딩 초기화 (config 백업됨)
```

각 파일의 `.bak.<타임스탬프>` 백업을 되돌려도 된다.
