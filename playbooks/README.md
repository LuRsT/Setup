# Setup my dotfiles using Ansible

How to use this:
- Install `ansible`
- Install `git`
- Clone this repo
- Copy private key to `~/.ssh/`
- Run: `ansible-playbook install-playbook.yml`
- Run: `ansible-playbook playbook.yml`
- If you want gnome: `ansible-playbook desktop-playbook.yml`

## Manual Gnome settings

- Alt+tab ( to switch windows in the same workspace only)

In settings > keyboard shortcuts > switch windows -> setto alt-tab

Run the script:

```sh
$ ./gnome-settings.sh
```
