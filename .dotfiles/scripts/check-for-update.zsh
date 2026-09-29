# Sourced by ~/.zshrc. The anonymous function keeps its variables out of the shell.
() {
    # Only ask in a terminal; editors and other tools also start zsh, without one
    [[ -t 0 ]] || return

    local gitdir=~/.dotfiles/.gitrepo
    local last_checked_file=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/last-checked
    local cooldown_hours=72
    local now=$(date +%s)
    local last_checked=0 do_check=n reply changed=0

    [[ -r $last_checked_file ]] && last_checked=$(<$last_checked_file)
    [[ $last_checked == <-> ]] || last_checked=0

    (( last_checked < now - cooldown_hours * 60 * 60 )) || return

    mkdir -p ${last_checked_file:h} && print $now > $last_checked_file
    echo "It seems that the dotfiles repo has not been checked for updates in the last ${cooldown_hours} hours."
    read -k 1 "do_check?Do you want to check for dotfile updates? [y/N] "
    echo

    [[ $do_check == [Yy] ]] || return

    echo "Checking for updates..."

    # Fetch the remote's default branch; set changed to 1 if it has commits that HEAD lacks.
    # (A bare clone has no remote-tracking branch, so `git status` cannot tell.)
    git --git-dir=$gitdir fetch --quiet origin HEAD &&
        (( $(git --git-dir=$gitdir rev-list --count HEAD..FETCH_HEAD) > 0 )) && changed=1

    if (( changed )); then
        echo "Your dotfiles need to be updated."
        read -k 1 "reply?Do you wish to update the dotfiles? [y/N] "
        echo

        if [[ $reply == [Yy] ]]; then
            echo "Starting update..."
            ~/.dotfiles/scripts/update.zsh
        else
            echo "Not updating dotfiles at this time."
        fi
    else
        echo "Dotfiles are up-to-date."
    fi
}
