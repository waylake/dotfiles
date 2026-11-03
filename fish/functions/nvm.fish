# bash nvm(~/.nvm)을 fish 에서 부르는 래퍼. PATH 동기화는 conf.d/nvm.fish 에 있다.
function nvm --description 'Node Version Manager (bash nvm via fish)'
    set -q NVM_DIR; or set -gx NVM_DIR $HOME/.nvm
    set -l binfile (command mktemp)
    bash -c 'source "$NVM_DIR/nvm.sh" --no-use; nvm "$@"; rc=$?; printf "%s" "$NVM_BIN" > "$0"; exit $rc' $binfile $argv
    set -l rc $status
    set -l bin (cat $binfile)
    command rm -f $binfile

    switch "$argv[1]"
        case use install
            # bash nvm 이 방금 고른 버전을 이 fish 세션 PATH 에 반영
            if test $rc -eq 0 -a -n "$bin" -a -d "$bin"
                if set -q __nvm_bin
                    set -l idx (contains -i -- $__nvm_bin $PATH); and set -e PATH[$idx]
                end
                set -gx PATH $bin $PATH
                set -g __nvm_bin $bin
            end
        case alias unalias uninstall deactivate
            __nvm_apply
    end
    return $rc
end
