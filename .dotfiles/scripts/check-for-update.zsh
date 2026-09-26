# Only ask in a terminal; editors and other tools also start zsh, without one
[[ -t 0 ]] || return

WORKDIR="${HOME}/.dotfiles/scripts"
GITDIR="${HOME}/.dotfiles/.gitrepo"
LAST_CHECKED_FILE="${WORKDIR}/.last_checked"
COOLDOWN_HOURS=72
DO_CHECK=0
NOW=$(date +%s)
LAST_CHECKED=0

if [ -f $LAST_CHECKED_FILE ]; then
    LAST_CHECKED=`cat $LAST_CHECKED_FILE`
fi

if [[ $LAST_CHECKED -lt `expr $NOW - $COOLDOWN_HOURS \* 60 \* 60` ]]; then
    echo $NOW > $LAST_CHECKED_FILE
    echo "It seems that the dotfiles repo has not been checked for updates in the last ${COOLDOWN_HOURS} hours."
    read -k 1 "DO_CHECK?Do you want to check for dotfile updates? [y/N] "
    echo
fi

if [[ $DO_CHECK =~ ^[Yy]$ ]]; then
    CHANGED=0
    
    echo "Checking for updates..."
    
    # Fetch the remote's default branch; set CHANGED to 1 if it has commits that HEAD lacks.
    # (A bare clone has no remote-tracking branch, so `git status` cannot tell.)
    git --git-dir=$GITDIR fetch --quiet origin HEAD &&
        [[ $(git --git-dir=$GITDIR rev-list --count HEAD..FETCH_HEAD) -gt 0 ]] && CHANGED=1
    
    if [ $CHANGED = 1 ]; then
        echo "Your dotfiles need to be updated."
        read -k 1 "REPLY?Do you wish to update the dotfiles? [y/N] "
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Starting update..."
            
            $WORKDIR/update.zsh
        else
            echo "Not updating dotfiles at this time."
        fi
    else
        echo "Dotfiles are up-to-date."
    fi
fi
