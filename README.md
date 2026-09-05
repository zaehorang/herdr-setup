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

## 하는 일

| 단계 | 내용 | 대상 |
| --- | --- | --- |
| `[1]` 설치 | `brew install herdr`, `brew install --cask ghostty` | — |
| `[2]` 키 바인딩 | herdr prefix 및 생성/제거 바인딩 | `~/.config/herdr/config.toml` |
| `[3]` Ghostty 설정 | 폰트·테마·스플릿/탭 키바인딩 | `~/.config/ghostty/config.ghostty` |
| `[4]` 셸 | `alias hd="herdr"` | `~/.zshrc` |

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
