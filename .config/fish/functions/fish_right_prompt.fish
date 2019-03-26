# Defined in /tmp/fish.WsPgJN/fish_right_prompt.fish @ line 2
function fish_right_prompt --description 'Write out the right prompt'
    #printf '[%s]' (date '+%H:%M:%S')

    if set -q VIRTUAL_ENV
        echo -n -s "(" (basename "$VIRTUAL_ENV") ")"
    end

    printf '%s' (__fish_git_prompt)

    set_color normal
end
