# Defined in /tmp/fish.NqscGF/fish_prompt.fish @ line 2
function fish_prompt
    set last_status $status

    set_color $fish_color_cwd

    if set -q VIRTUAL_ENV
        echo -n -s "(" (basename "$VIRTUAL_ENV") ")"
    end

    printf '%s ' (__fish_git_prompt)

    set_color normal

    printf '%s ' (prompt_pwd)

    set_color normal
end
