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
    echo "It seems that the dotfiles repo has not been checked for updates in the last ${COOLDOWN_HOURS} hours."
    read -k 1 "DO_CHECK?Do you want to check for dotfile updates? [y/N] "
    echo
fi

echo $NOW > $LAST_CHECKED_FILE

if [[ $DO_CHECK =~ ^[Yy]$ ]]; then
    CHANGED=0
    
    echo "Checking for updates..."
    
    # Fetch changes from remote and check if dotfiles branch is behind; set CHANGED to 1 if so.
    /usr/bin/git --git-dir=$GITDIR --work-tree=$HOME remote update && /usr/bin/git --git-dir=$GITDIR --work-tree=$HOME status -uno | grep -q 'Your branch is behind' && CHANGED=1
    
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
else
    echo "Not asking again to update dotfiles for 72 hours."
fi
