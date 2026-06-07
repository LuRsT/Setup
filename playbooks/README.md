# Setup dotfiles and packages using Ansible

```sh
ansible-playbook install-playbook.yml`
ansible-playbook playbook.yml`
# if you want gnome desktop
ansible-playbook desktop-playbook.yml
# for openbox
ansible-playbook desktop-old-playbook.yml
```

## Manual Gnome settings

### Alt+tab ( to switch windows in the same workspace only):

In settings > keyboard shortcuts > switch windows -> set to alt-tab

### For the rest:

```sh
$ ../gnome-settings.sh
```
