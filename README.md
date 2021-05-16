# My Setup

My dotfiles and ~/bin

Screenshot as of May 2021

![2021-05-15-110759_1483x918_scrot](https://user-images.githubusercontent.com/263583/118356582-78539500-b565-11eb-9dbd-98830dadb1f9.png)

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
