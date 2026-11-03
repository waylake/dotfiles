function fzf_cd --description 'fzf 로 git 저장소·폴더를 골라 cd (Ctrl-F)'
    if not type -q fzf
        echo 'fzf_cd: fzf 가 없다' >&2
        commandline -f repaint
        return 1
    end

    # 프로젝트가 모여 있는 폴더. 머신마다 바꾸려면: set -g FZF_CD_ROOTS ~/work ~/src
    set -q FZF_CD_ROOTS; or set -l FZF_CD_ROOTS ~/github ~/src ~/code ~/projects

    set -l pick (begin
        echo ~/.config
        for root in $FZF_CD_ROOTS
            test -d $root; or continue
            find $root -maxdepth 4 -type d -name .git -prune 2>/dev/null | string replace -r '/\.git$' ''
        end
        find . -mindepth 1 -maxdepth 1 -type d -not -name '.*' 2>/dev/null | string replace -r '^\.' $PWD
    end | awk '!seen[$0]++' | fzf --height 40% --reverse)

    if test -n "$pick"
        builtin cd $pick
    end
    commandline -f repaint
end
