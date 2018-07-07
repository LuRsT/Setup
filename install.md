# My dev env

pacman -S neovim
    \ git
    \ python
    \ openssh
    \ zsh
    \ tmux
    \ viewnior
    \ ctags
    \ ansible
    \ imagemagick     # for lock screen
    \ python-virtualenvwrapper
    \ python-neovim

# OS

pacman -S xclip
    \ pkg-config
    \ grub
    \ intel-ucode
    \ sudo
    \ sway
    \ thintkfan
    \ tlp
    \ tp_smapi
    \ x86_energy_perf_policy
    \ acpi_call
    \ ttf-liberation
    \ cryptsetup
    \ wpa_supplicant
    \ acpi
    \ xorg-fonts-misc           # Needed?
    \ wireless_tools            # Not sure
    \ mplayer youtube-dl        # for uplay script
    \ networkmanager            # for network, could be replaced with netctl

# ST

pacman -S cmake \
    fontconfig \
    freetype2 \
    gcc \
    libxext \
    ncurses \
    libxft \
    make \


# Extra

pacman -S screenfetch cmatrix
pacman -S mirage
pacman -S firefox
pacman -S openssh
pacman -S ranger
pacman -S rofi
pacman -S tumbler   # For thumbnails in thunar
pacman -S pmount
pacman -S gvfs-smb  # For samba share
pacman -S powertop

