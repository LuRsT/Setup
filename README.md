# My Setup

My dotfiles and ~/bin

<img width="1740" height="1243" alt="2026-06-07-093413_1740x1243_scrot" src="https://github.com/user-attachments/assets/169b1907-7f81-4b1d-87dc-3fc64a9c6fd7" />

_Screenshot as of June 2026_

## How to set up

After you install the OS (Arch btw) from scratch:

``` sh
sudo pacman -S git ansible
mkdir dev && cd dev
git clone https://github.com/LuRsT/Setup.git
```

Then read and follow the steps in [Playbooks README](playbooks/README.md) to install the packages.

Finally, `stow` the dotfiles folder.

``` sh
stow dotfiles
```
