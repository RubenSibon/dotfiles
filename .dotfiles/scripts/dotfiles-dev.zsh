#!/usr/bin/env zsh

# Runs a program (default: zsh) in a sandbox whose home directory is the clone
# in ~/.dotfiles-src. Editors and agents started this way work on the dotfiles
# without access to the real home directory, its keys and its tokens.
# See "Developing the dotfiles" in the README.

src=${DOTFILES_SRC:-$HOME/.dotfiles-src}
runtime=${XDG_RUNTIME_DIR:-/run/user/$UID}

if [[ ! -d $src/.git ]]; then
    echo "No clone in $src. See 'Developing the dotfiles' in ~/.dotfiles/README.md."
    exit 1
fi
if ! command -v bwrap > /dev/null; then
    echo "bubblewrap is missing. See 'Required packages' in ~/.dotfiles/README.md."
    exit 1
fi

args=(
    # No access to other processes or to the session's D-Bus; the network stays,
    # because agents and plugin managers need it
    --unshare-all --share-net --die-with-parent
    --dev /dev --proc /proc --tmpfs /tmp
    # The clone is the home directory. Its .git is read-only: hooks and settings
    # in there would run outside the sandbox, at the next git command in the clone.
    --bind $src $HOME --ro-bind $src/.git $HOME/.git --chdir $HOME
    --perms 0700 --dir $runtime
)

# The system, read-only: /nix and /run on NixOS, /usr and its links elsewhere
for dir in /etc /usr /bin /sbin /lib /lib32 /lib64 /nix /run/current-system \
    /run/opengl-driver /run/systemd/resolve /sys; do
    args+=(--ro-bind-try $dir $dir)
done

# Wayland only: an X11 socket would let the sandbox read every window and key press
[[ -n $WAYLAND_DISPLAY ]] && args+=(--ro-bind $runtime/$WAYLAND_DISPLAY $runtime/$WAYLAND_DISPLAY)

# An empty environment plus what a program needs to start: tokens and agent
# sockets that the calling shell exports stay outside. Agents log in once inside
# the sandbox and keep their credentials in the clone's ignored home directory.
args+=(--clearenv --setenv XDG_RUNTIME_DIR $runtime)
for name in HOME USER LOGNAME PATH TERM COLORTERM LANG WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP; do
    [[ -v $name ]] && args+=(--setenv $name ${(P)name})
done

# Where the kernel still lets a program type into its terminal (TIOCSTI), detach
# from the terminal: the sandbox could otherwise leave commands for the calling
# shell. This costs job control inside the sandbox.
[[ $(< /proc/sys/dev/tty/legacy_tiocsti) == 0 ]] 2> /dev/null || args+=(--new-session)

(( $# )) || set -- zsh

# The editors hand their window to another process and return within a second.
# bubblewrap's init is the program itself, and the kernel kills a PID namespace
# as soon as its init exits, so the window died a second after it was asked for:
# the terminal showed the editor's startup warnings and nothing else. Their own
# foreground flags keep the init alive for as long as the window is open.
case ${1:t} in
    codium|code) set -- "$1" --wait "${@:2}" ;;
    zeditor|zed) set -- "$1" --foreground "${@:2}" ;;
esac

# The GPU goes in only where a window needs it: Zed does not start without one,
# while a shell, Neovim or an agent has no use for the device, whose driver is
# kernel attack surface. DOTFILES_DEV_GPU=1 adds it for anything else; without
# it, Electron falls back to software rendering.
if [[ ${1:t} == (codium|code|zeditor|zed) || -n $DOTFILES_DEV_GPU ]]; then
    args+=(--dev-bind-try /dev/dri /dev/dri)
fi

# Through zsh: /etc/zshenv and ~/.zshenv rebuild the environment that was cleared above
exec bwrap $args -- zsh -c 'exec "$@"' zsh "$@"
