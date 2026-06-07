# My Setup

My dotfiles and ~/bin

<img width="1740" height="1243" alt="2026-06-07-093413_1740x1243_scrot" src="https://github.com/user-attachments/assets/169b1907-7f81-4b1d-87dc-3fc64a9c6fd7" />

_Screenshot as of June 2026_

## How to set up

This is usually done after I install my OS clean. I install `git` and `ansible`, `git clone` this repo.

``` sh
sudo pacman -S git ansible
mkdir dev && cd dev
git clone https://github.com/LuRsT/Setup.git
```

Then go inside the `playbooks/` directory to run the ansible playbooks and then `stow` the dotfiles folder.

``` sh
cd Setup/playbooks
ansible-playbook install-playbook.yml
ansible-playbook playbook.yml
cd ..
stow dotfiles
```

For updating, doing a `git pull` on this repo should be enough, unless there's new dotfiles, then you need to `stow` them again.
