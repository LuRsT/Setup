# Defined in /tmp/fish.KwsijA/fish_right_prompt.fish @ line 2
function fish_right_prompt --description 'Write out the right prompt'
	printf '%s ' (__fish_git_prompt)
    printf '[%s]' (date '+%H:%M:%S')
    set_color normal
end
