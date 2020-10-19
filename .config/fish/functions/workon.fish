# Defined in /tmp/fish.IpVZ7K/vev.fish @ line 1
function workon
	/usr/bin/ls -d ~/.virtualenvs/* | xargs -l basename | fzf --reverse --height 30% | read -l result; and . $HOME/.virtualenvs/$result/bin/activate.fish
end
