# My Setup

My dotfiles and ~/bin

<img width="1740" height="1243" alt="2026-06-07-093413_1740x1243_scrot" src="https://github.com/user-attachments/assets/169b1907-7f81-4b1d-87dc-3fc64a9c6fd7" />

_Screenshot as of June 2026_

## How to set up

After you install the OS (Arch btw) from scratch:

``` sh
curl -fsSL https://raw.githubusercontent.com/LuRsT/Setup/master/bootstrap.sh | bash
```

Or, from a clone:

``` sh
git clone https://github.com/LuRsT/Setup.git ~/dev/Setup
~/dev/Setup/bootstrap.sh
```

`bootstrap.sh` installs the packages, links the dotfiles, and applies the GNOME
settings, which is everything that used to be a manual sequence of
`ansible-playbook` and `stow` commands.

## Keeping a machine up to date

The script converges on the state this repository describes rather than
installing once, so re-run it whenever the repository changes. Add a package to
`playbooks/install-playbook.yml`, run the script again, and only that package is
installed.

``` sh
./bootstrap.sh --check   # show what would change, touch nothing
./bootstrap.sh           # apply
```

Re-running on a machine that is already set up reports `ok` for every link and
leaves them alone. Where something does have to move out of the way, a real
`~/.bashrc` from a fresh install, say, it goes to `~/.setup-backup/<timestamp>/`
first. Nothing is ever deleted.

## What it deliberately leaves alone

SSH keys stay manual, so the bootstrap clones over HTTPS. Generate a key and
point the remote at SSH once the machine is up:

``` sh
ssh-keygen -t ed25519
git -C ~/dev/Setup remote set-url origin git@github.com:LuRsT/Setup.git
```

The openbox desktop isn't installed either, since GNOME is the one in use. See
the [playbooks README](playbooks/README.md) for that and for running the
playbooks individually.
