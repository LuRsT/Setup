# Packages, via Ansible

`bootstrap.sh` in the repository root runs these in order and is the normal way
to apply them. Run one directly when you want only that part:

``` sh
sudo ansible-playbook install-playbook.yml   # packages, microcode, and GPU drivers
sudo ansible-playbook desktop-playbook.yml   # GNOME and GDM
```

The openbox desktop is not part of the bootstrap. Install it by hand if you want
it back:

``` sh
sudo ansible-playbook desktop-old-playbook.yml
```

Linking the dotfiles used to live here as `playbook.yml`. It now lives in
`bootstrap.sh`, which backs up whatever it has to move rather than failing on an
existing `~/.config`.

## Manual GNOME settings

To switch windows in the same workspace only, go to Settings > Keyboard
Shortcuts > Switch windows and set it to Alt+Tab. The rest is applied by
`gnome-settings.sh`, which the bootstrap runs for you.
