# bash nvm(~/.nvm)으로 설치한 Node 를 fish 에서 쓴다. nvm 이 없는 머신에서는 아무것도 하지 않는다.
# 기본은 ~/.nvm/alias/default, .nvmrc 가 있는 폴더(상위 탐색)에서는 그 버전으로 PATH 를 바꾼다.
set -q NVM_DIR; or set -gx NVM_DIR $HOME/.nvm
test -s $NVM_DIR/nvm.sh; or return

function __nvm_resolve --argument-names spec
    set -l versions (path basename $NVM_DIR/versions/node/v* 2>/dev/null | sort -V)
    test (count $versions) -gt 0; or return 1
    set spec (string trim -- $spec)
    # 이름 alias 를 따라간다(default -> 24 등). lts/* 와 node 는 "설치된 최신"
    for i in 1 2 3
        test -f $NVM_DIR/alias/$spec; or break
        set spec (string trim -- (cat $NVM_DIR/alias/$spec))
    end
    switch $spec
        case '' node stable 'lts/*'
            echo $versions[-1]
            return 0
    end
    set spec (string replace -r '^v' '' -- $spec)
    for v in $versions[-1..1]
        if test "$v" = "v$spec"; or string match -q -- "v$spec.*" $v
            echo $v
            return 0
        end
    end
    return 1
end

function __nvm_find_nvmrc
    set -l dir $PWD
    while test -n "$dir"
        test -f $dir/.nvmrc; and echo $dir/.nvmrc; and return 0
        test "$dir" = /; and return 1
        set dir (path dirname $dir)
    end
    return 1
end

function __nvm_apply --on-variable PWD
    set -l spec default
    set -l rc (__nvm_find_nvmrc); and set spec (head -n1 $rc)
    set -l ver (__nvm_resolve $spec); or set ver (__nvm_resolve default); or return
    set -l bin $NVM_DIR/versions/node/$ver/bin
    test "$__nvm_bin" = "$bin"; and return
    if set -q __nvm_bin
        set -l idx (contains -i -- $__nvm_bin $PATH); and set -e PATH[$idx]
    end
    set -gx PATH $bin $PATH
    set -g __nvm_bin $bin
end

__nvm_apply
