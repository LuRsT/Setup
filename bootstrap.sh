#!/bin/bash
# Bring an Arch machine to the state described by this repo: packages, symlinks,
# desktop settings. Converges rather than installs once, so it is safe to re-run.

set -euo pipefail

REPO_URL='https://github.com/LuRsT/Setup.git'
DEFAULT_REPO_DIR="$HOME/dev/Setup"
BACKUP_DIR="$HOME/.setup-backup/$(date +%Y%m%d-%H%M%S)"
PREREQ_PACKAGES=('git' 'ansible' 'stow' 'reflector')

# Linked wholesale rather than through stow: ~/.config is a single symlink into
# the repo, so whatever an app writes there lands in the repo and is filtered by
# .gitignore's allowlist.
LINKED_PATHS=('.config' 'bin' '.stowrc')

# Only DNS is checked; pacman reports anything worse well enough on its own.
NETWORK_TIMEOUT_SECONDS=5

# The mirrorlist an Arch ISO ships with is not ordered by speed, and a slow
# mirror makes the install phase crawl or time out outright. Neighbours are
# included alongside GB because the fastest mirror is often just across the
# channel, and a country with no mirrors at all would otherwise strand us.
MIRROR_COUNTRIES='GB,IE,NL,FR,DE'
MIRROR_COUNT=20

REPO_DIR=''
IS_CHECK=false

log() {
    echo "$1"
}

fail() {
    echo "bootstrap: $1" >&2
    exit 1
}

parse_arguments() {
    case "${1:-}" in
        '') return 0 ;;
        --check) IS_CHECK=true ;;
        *) fail "unknown argument (got $1); usage: bootstrap.sh [--check]" ;;
    esac
}

require_preflight() {
    if [ "$EUID" -eq 0 ]; then
        fail 'run as your own user, not root; individual steps escalate on their own'
    fi

    if ! command -v pacman >/dev/null; then
        fail 'this repo targets Arch, and pacman was not found'
    fi

    if ! timeout "$NETWORK_TIMEOUT_SECONDS" getent hosts archlinux.org >/dev/null; then
        fail 'cannot resolve archlinux.org, so package installation would fail'
    fi
}

# Prefers the clone this script was run from, so a checkout living somewhere
# other than the default is not cloned a second time.
resolve_repo_dir() {
    local script_dir

    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" 2>/dev/null && pwd)" || script_dir=''

    if [ -n "$script_dir" ] && [ -d "$script_dir/.git" ]; then
        REPO_DIR="$script_dir"
        return 0
    fi

    REPO_DIR="$DEFAULT_REPO_DIR"
}

install_prereqs() {
    local -a missing=()
    local package

    for package in "${PREREQ_PACKAGES[@]}"; do
        if ! pacman -Qq "$package" >/dev/null 2>&1; then
            missing+=("$package")
        fi
    done

    if [ "${#missing[@]}" -eq 0 ]; then
        log "ok       prereqs ${PREREQ_PACKAGES[*]}"
        return 0
    fi

    log "install  ${missing[*]}"

    if $IS_CHECK; then
        return 0
    fi

    sudo pacman -S --needed --noconfirm "${missing[@]}"
}

# Cloned over HTTPS: on a fresh machine there is no SSH key yet, and generating
# one stays a manual step.
sync_repo() {
    if [ -d "$REPO_DIR/.git" ]; then
        log "ok       $REPO_DIR"
        return 0
    fi

    log "clone    $REPO_URL -> $REPO_DIR"

    if $IS_CHECK; then
        return 0
    fi

    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_URL" "$REPO_DIR"
}

# Warmed up front so the password prompt lands here, rather than interrupting a
# long phase part way through.
require_sudo() {
    if sudo -n true 2>/dev/null; then
        return 0
    fi

    sudo -v
}

backup() {
    local target_path="$1"

    log "backup   $target_path -> $BACKUP_DIR/"

    if $IS_CHECK; then
        return 0
    fi

    mkdir -p "$BACKUP_DIR"
    mv "$target_path" "$BACKUP_DIR/"
}

# Three states: already correct (no-op), absent (link), occupied (back up, then
# link). Nothing is ever deleted.
link_to() {
    local source_path="$1"
    local target_path="$2"

    # Canonicalised because links here are a mix of absolute and relative forms,
    # which a raw readlink comparison would report as wrong and churn.
    if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" = "$(readlink -f "$source_path")" ]; then
        log "ok       $target_path"
        return 0
    fi

    # -L as well as -e, because a broken symlink fails -e yet still holds the name.
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        backup "$target_path"
    fi

    log "link     $target_path -> $source_path"

    if $IS_CHECK; then
        return 0
    fi

    ln -s "$source_path" "$target_path"
}

link_repo_paths() {
    local name

    for name in "${LINKED_PATHS[@]}"; do
        link_to "$REPO_DIR/$name" "$HOME/$name"
    done
}

# stow aborts on the whole package when a target exists as a real file, which a
# fresh Arch install guarantees (/etc/skel seeds ~/.bashrc). Links stow already
# owns are left alone: stow is idempotent over those. Assumes a flat package,
# which dotfiles/ is.
clear_stow_conflicts() {
    local package_dir="$REPO_DIR/dotfiles"
    local entry target_path

    shopt -s dotglob nullglob

    for entry in "$package_dir"/*; do
        target_path="$HOME/$(basename "$entry")"

        if [ -L "$target_path" ]; then
            continue
        fi

        if [ -e "$target_path" ]; then
            backup "$target_path"
        fi
    done

    shopt -u dotglob nullglob
}

# --dir and --target are passed explicitly rather than left to .stowrc, so the
# result does not depend on which directory this was invoked from.
stow_dotfiles() {
    local -a command=('stow' '--dir' "$REPO_DIR" '--target' "$HOME" 'dotfiles')

    if $IS_CHECK; then
        command+=('--no' '--verbose')
    fi

    log "stow     dotfiles"
    "${command[@]}"
}

# Ranked before the playbooks rather than inside them: ansible's pacman module
# uses whatever mirrorlist it finds, so this only helps if it lands first.
# A failure here is not fatal, since the existing mirrorlist still works; it is
# only slower, which is the very thing this is trying to fix.
rank_mirrors() {
    local mirrorlist='/etc/pacman.d/mirrorlist'
    local staged

    log "mirrors  $MIRROR_COUNT fastest https mirrors in $MIRROR_COUNTRIES"

    if $IS_CHECK; then
        return 0
    fi

    # Written to a temp file first, because --save truncates its target before
    # it has any results: an interrupted run against the real mirrorlist would
    # leave the machine with no mirrors, and so no way to install the packages
    # that would repair it.
    staged="$(mktemp)"

    if ! sudo reflector --country "$MIRROR_COUNTRIES" --protocol https \
        --latest "$MIRROR_COUNT" --sort rate --save "$staged"; then
        sudo rm -f "$staged"
        log 'warn     reflector failed, keeping the existing mirrorlist'
        return 0
    fi

    # An empty file is a successful exit with nothing to show for it, which
    # would be indistinguishable from a working mirrorlist until pacman ran.
    if [ ! -s "$staged" ]; then
        sudo rm -f "$staged"
        log 'warn     reflector found no mirrors, keeping the existing mirrorlist'
        return 0
    fi

    sudo cp "$mirrorlist" "$mirrorlist.bootstrap-backup"
    sudo install --mode 644 "$staged" "$mirrorlist"
    sudo rm -f "$staged"
}

# Run under sudo rather than leaning on ansible's become, whose sudo -n needs a
# warm timestamp this machine does not reliably keep. Safe because both playbooks
# touch only pacman and systemd, and neither reads the invoking user's identity
# or home; the one that did has been folded into this script.
run_playbook() {
    local playbook_name="$1"
    local -a command=('sudo' 'ansible-playbook' "$REPO_DIR/playbooks/$playbook_name")

    if $IS_CHECK; then
        command+=('--check')
    fi

    log "playbook $playbook_name"
    "${command[@]}"
}

apply_gnome_settings() {
    if ! command -v gsettings >/dev/null; then
        log "skip     gnome-settings.sh (gsettings not installed)"
        return 0
    fi

    log "settings gnome-settings.sh"

    if $IS_CHECK; then
        return 0
    fi

    "$REPO_DIR/gnome-settings.sh"
}

# Packages come before links so that a failure part way through leaves a machine
# a re-run converges, rather than configs pointing at absent programs.
main() {
    parse_arguments "$@"
    require_preflight
    resolve_repo_dir
    install_prereqs
    sync_repo
    require_sudo
    rank_mirrors
    run_playbook 'install-playbook.yml'
    link_repo_paths
    clear_stow_conflicts
    stow_dotfiles
    run_playbook 'desktop-playbook.yml'
    apply_gnome_settings
    log 'done'
}

main "$@"
