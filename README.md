# dotfiles

맥북에서 실제로 쓰는 터미널·에디터 설정. 바탕은 [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles)이고, 아래 "바꾼 점"만 다르다.

```
nvim/      Neovim 0.12+ (vim.pack). 개인 수정은 nvim/lua/craftzdog/plugins/local.lua
tmux/      tmux 3.2+, prefix Ctrl-t, tpm 플러그인
ghostty/   Ghostty (Solarized Dark - Vivid, PlemolJP)
lazygit/   lazygit (delta diff, C = commitizen 커밋)
czrc       commitizen 설정 (cz-git)
```

## 설치

저장소 폴더를 `~/.config` 아래에 링크한다. 저장소가 원본이라 설정을 고치면 바로 git 변경으로 잡힌다.

```sh
git clone https://github.com/waylake/dotfiles ~/dotfiles
for d in nvim tmux ghostty lazygit; do ln -sfn ~/dotfiles/$d ~/.config/$d; done
ln -sf ~/dotfiles/czrc ~/.czrc

# macOS lazygit 은 ~/Library/Application Support/lazygit 을 읽는다
mkdir -p ~/Library/Application\ Support/lazygit
ln -sf ~/.config/lazygit/config.yml ~/Library/Application\ Support/lazygit/config.yml

# tmux 플러그인
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
~/.config/tmux/plugins/tpm/bin/install_plugins
```

필요한 패키지(macOS):

```sh
brew install neovim tmux lazygit git-delta ripgrep fd tree-sitter-cli
brew install --cask ghostty font-plemol-jp-nf font-blex-mono-nerd-font
npm install -g commitizen cz-git
```

Neovim 플러그인은 처음 실행할 때 `nvim-pack-lock.json` 버전으로 설치된다. Mason 도구(LSP·포매터)도 처음 실행 때 자동 설치된다.

셸에서 `TERM` 을 덮어쓰지 않는다. Ghostty 가 `xterm-ghostty`, tmux 가 `tmux-256color` 를 지정해야 색이 맞다.

## craftzdog 원본과 바꾼 점

tmux
- `|` `-` `%` `"` 분할 뒤 `select-layout even-*` 을 빼서, 현재 pane 만 나눈다(원본은 창의 모든 pane 을 한 줄로 재배치).
- 활성/비활성 pane 글자색 차이(`window-style`, `window-active-style`)를 없앴다.
- `mouse on`.
- window 목록을 상태바 왼쪽에 둔다(`status-justify left`).

Neovim (`nvim/lua/craftzdog/plugins/local.lua`, `util.lua`, `lsp.lua`, `init.lua`)
- Copilot(copilot.lua, copilot-language-server) 제거.
- `sf`: oil 플로팅 대신 telescope-file-browser(dropdown, 미리보기 없음, normal 모드, 현재 버퍼 폴더). `h` 상위 폴더, `N` 새 파일, `/` 검색, `C-u`/`C-d` 10줄 이동.
- 커서 깜빡임 끔.

## 키 요약

tmux (prefix `Ctrl-t` 뒤)

| 키 | 동작 |
|---|---|
| `\|` `%` / `-` `"` | 좌우 / 위아래 분할 (지금 폴더) |
| `h` `j` `k` `l` / `H` `J` `K` `L` | pane 이동 / 크기 (tmux-pain-control) |
| `e` | 지금 pane 만 남기기 |
| `g` | lazygit 팝업 |
| `o` | 지금 폴더를 Finder 로 열기 |
| `r` | 설정 다시 읽기 |
| `Ctrl-Shift-←/→` (prefix 없이) | window 순서 바꾸기 |

Neovim

| 키 | 동작 |
|---|---|
| `sf` | 파일 브라우저 |
| `;f` / `;r` | 파일 찾기 / 텍스트 검색 (snacks picker) |
