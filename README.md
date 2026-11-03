# dotfiles

새 환경에서 바로 쓰는 **fish + tmux** 설정. macOS·Linux 공통이고, 없는 도구는 알아서 건너뛴다.

```
fish/
  config.fish                 # PATH·abbr·alias (머신 파일에서 source)
  conf.d/nvm.fish             # ~/.nvm 이 있으면 .nvmrc 따라 Node 전환
  functions/
    fish_user_key_bindings.fish
    fzf_cd.fish               # Ctrl-F 폴더 점프
    nvm.fish                  # fish 에서 bash nvm 명령 쓰기
tmux/
  tmux.conf                   # 설정 전부 (한 파일)
```

## 새 머신에서

```sh
git clone https://github.com/waylake/dotfiles ~/dotfiles

mkdir -p ~/.config/fish ~/.config/tmux
echo 'source ~/dotfiles/fish/config.fish'    >> ~/.config/fish/config.fish
echo 'source-file ~/dotfiles/tmux/tmux.conf' >> ~/.config/tmux/tmux.conf

chsh -s "$(command -v fish)"   # 로그인 셸을 fish 로 (목록에 없으면 /etc/shells 에 먼저 추가)
```

링크 대신 **한 줄 source** 를 쓰는 이유: 머신 파일(`~/.config/...`)이 그 머신 전용 설정 자리가 된다.
키·토큰·그 머신에만 있는 PATH 는 그 한 줄 **아래**에 적고, 이 저장소에는 절대 넣지 않는다(공개 저장소).

```fish
# ~/.config/fish/config.fish 예
source ~/dotfiles/fish/config.fish
set -gx OPENAI_API_KEY ...
fish_add_path -g ~/.local/share/pnpm
```

업데이트는 `git -C ~/dotfiles pull` 후 새 셸을 열거나 tmux 에서 `prefix r`.

### 필요한 것 / 있으면 좋은 것

| | 용도 | macOS | Ubuntu |
|---|---|---|---|
| fish 3.5+ | 셸 | `brew install fish` | `sudo add-apt-repository ppa:fish-shell/release-4 && sudo apt install fish` (기본 apt 는 3.3이라 낮다) |
| tmux 3.2+ | 터미널 분할 | `brew install tmux` | `sudo apt install tmux` |
| fzf | Ctrl-F 폴더 점프 | `brew install fzf` | `sudo apt install fzf` |
| zoxide | `z 폴더이름` 점프 | `brew install zoxide` | `sudo apt install zoxide` |
| eza | 예쁜 `ll` | `brew install eza` | `sudo apt install eza` (24.04+) |
| lazygit | `prefix g` 팝업 | `brew install lazygit` | GitHub 릴리스 |

맨 위 두 개만 있으면 된다. 나머지는 없으면 그 기능만 꺼진다.

## tmux 키

prefix = **Ctrl-t** (기본 Ctrl-b 아님). 아래는 전부 prefix 를 누른 뒤 누르는 키다.

| 키 | 동작 |
|---|---|
| `c` | 새 창 (지금 폴더에서) |
| `\|` / `-` | 좌우 / 위아래 분할 (지금 폴더에서). `%` `"` 도 같음 |
| `h` `j` `k` `l` | 패널 이동 (prefix 한 번 후 연속 입력 가능) |
| `H` `J` `K` `L` | 패널 크기 조절 |
| `z` | 지금 패널 확대 / 원래대로 (tmux 기본) |
| `e` | 지금 패널만 남기고 나머지 닫기 |
| `x` / `&` | 패널 닫기 / 창 닫기 (tmux 기본) |
| `<` / `>` | 창 순서 바꾸기 (prefix 없이 `Ctrl-Shift-←/→` 도 됨) |
| `0`–`9`, `n` / `p`, `w` | 창 이동, 다음 / 이전, 목록에서 고르기 (tmux 기본) |
| `[` | 복사 모드: `v` 선택 시작, `Ctrl-v` 사각 선택, `y` 복사 |
| `g` | lazygit 팝업 |
| `y` | 이 폴더의 Claude Code 팝업. 팝업 안에서 `prefix d` 로 닫아도 세션은 남는다 |
| `r` | 설정 다시 읽기 |
| `d` | tmux 에서 빠져나오기(detach). 다시 붙기: `tmux a` |
| `Ctrl-t` | 안쪽 tmux(ssh 너머)나 프로그램에 Ctrl-t 보내기 |

- 마우스 켜짐: 클릭으로 패널 선택, 드래그로 크기 조절, 휠 스크롤.
- 복사한 내용은 OSC 52 로 **바깥 터미널의 클립보드**에 들어간다. 맥에서 ssh 로 서버 tmux 를 써도 맥에서 바로 붙여넣기 된다.
- prefix 를 누르면 오른쪽 아래에 `PREFIX` 가 뜬다.

## fish

| 입력 | 동작 |
|---|---|
| `Ctrl-F` | fzf 로 프로젝트(git 저장소)·하위 폴더를 골라 이동. 찾는 위치: `~/github ~/src ~/code ~/projects` (바꾸려면 `set -g FZF_CD_ROOTS ...`) |
| `Ctrl-L` / `→` | 회색 자동완성 제안 받기 (Ctrl-L 은 한 글자, → 는 전체) |
| `Ctrl-D` | 글자 지우기 (셸이 닫히지 않는다) |
| `Ctrl-R` | 명령 기록 검색 (fish 기본) |
| `Alt-↑` / `Alt-←` | 이전 인자 넣기 / 이전 폴더로 (fish 기본) |
| `z 이름`, `zi` | 자주 가는 폴더로 점프 (zoxide 있을 때) |

축약(스페이스 치면 펼쳐짐): `g` → `git`, `c` → `claude`, `claude-yolo` → `claude --dangerously-skip-permissions`.
목록 보기: `abbr`. 추가하려면 머신 파일에 `abbr -a 이름 '명령'`.

`nvm`: `~/.nvm` 이 있으면 fish 에서도 `nvm install 24`, `nvm use 22` 가 되고, `.nvmrc` 가 있는 폴더에 들어가면 그 버전으로 바뀐다.

## 참고

- 2022년 nvim 설정은 `legacy-nvim-2022` 태그에 남아 있다.
- 처음 바탕은 [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public). prefix·색 등을 거기서 가져왔다.
