function fish_user_key_bindings
    # Ctrl-F: fzf 로 프로젝트 폴더를 골라 cd
    bind \cf fzf_cd
    # Ctrl-L: 자동완성 제안을 한 글자씩 받기 (vim 의 l)
    bind \cl forward-char
    # Ctrl-D: 셸을 닫지(EOF) 않고 글자 하나 지우기
    bind \cd delete-char
end
