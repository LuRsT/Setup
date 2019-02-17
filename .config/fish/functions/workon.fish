# Defined in /tmp/fish.IpVZ7K/vev.fish @ line 1
function workon
	ls -d ~/.virtualenvs/* | xargs -l basename | fzf | read -l result; and . $HOME/.virtualenvs/$result/bin/activate.fish
end
