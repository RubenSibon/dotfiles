WORKDIR="${HOME}/.dotfiles/scripts"
GITDIR="${HOME}/.dotfiles/.gitrepo"
LAST_CHECKED_FILE="${WORKDIR}/.last_checked"
COOLDOWN_HOURS=72
NOW=$(date +%s)
LAST_CHECKED=$NOW

if [ -f $LAST_CHECKED_FILE ]; then
    LAST_CHECKED=`cat $LAST_CHECKED_FILE`
else
    echo $(date +%s) > $LAST_CHECKED_FILE 
fi

if [[ $LAST_CHECKED -lt `expr $NOW - $COOLDOWN_HOURS \* 60` ]]; then
    CHANGED=0
    
    echo $(date +%s) > $LAST_CHECKED_FILE
    
    # Fetch changes from remote and check if dotfiles branch is behind; set CHANGED to 1 if so.
    /usr/bin/git --git-dir=$GITDIR --work-tree=$HOME remote update && /usr/bin/git --git-dir=$GITDIR --work-tree=$HOME status -uno | grep -q 'Your branch is behind' && CHANGED=1
    
    if [ $CHANGED = 1 ]; then
        echo "Your dotfiles need to be updated."
        
        read -p "Do you wish to update the dotfiles (y/N)? " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]
            echo "Starting update..."
            
            $WORKDIR/update.zsh
        else
            echo "Not updating dotfiles at this time."
        fi
    else
        echo "Dotfiles are up-to-date."
    fi
fi
