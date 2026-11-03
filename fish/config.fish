# waylake dotfiles — fish (3.5+)
#
# 이 파일은 링크하지 않는다. 각 머신의 ~/.config/fish/config.fish 에 한 줄만 넣는다:
#   source ~/dotfiles/fish/config.fish
# 키·토큰, 그 머신에만 필요한 PATH 같은 건 그 한 줄 아래, 머신 파일에 둔다.

set -l here (path dirname (path resolve (status filename)))

# 이 저장소의 functions/ 는 ~/.config/fish/functions 처럼 자동 로드하고, conf.d/ 는 시작할 때 읽는다
contains -- $here/functions $fish_function_path; or set -p fish_function_path $here/functions
for f in $here/conf.d/*.fish
    source $f
end

# ── PATH: 없는 디렉터리는 건너뛰므로 어느 머신에서나 같은 목록을 쓴다 ──
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
end
fish_add_path -g ~/.local/bin ~/bin ~/go/bin ~/.cargo/bin

if type -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end

status is-interactive; or return

# ── 여기부터는 대화형 셸에서만 ──
set -g fish_greeting ""

# abbr 은 스페이스를 치면 전체 명령으로 펼쳐져서, 실제 명령이 눈에 보인다(기억하기 좋다)
abbr -a g git
abbr -a c claude
abbr -a claude-yolo 'claude --dangerously-skip-permissions'

# ls: macOS(BSD)와 Linux(GNU)는 색 옵션이 다르다
switch (uname)
    case Darwin
        alias ls 'ls -pG'
    case '*'
        alias ls 'ls -p --color=auto'
end
alias la 'ls -A'
alias ll 'ls -l'
alias lla 'ls -lA'
if type -q eza
    alias ll 'eza -l -g --icons'
    alias lla 'eza -l -g --icons -a'
end

# z <폴더> / zi: 자주 가는 폴더로 점프 (zoxide 가 있을 때만)
if type -q zoxide
    zoxide init fish | source
end
