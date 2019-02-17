# Defined in /tmp/fish.5Avej8/fish_right_prompt.fish @ line 2
function fish_right_prompt --description 'Write out the right prompt'
	echo -n -s " [" (date '+%H:%M:%S') "]"
end
