WORK_DIR="${HOME}/.dotfiles/scripts"
LAST_CHECKED_FILE="${WORK_DIR}/.last_checked"
NOW=$(date +%s)
LAST_CHECKED=$NOW

if [ -f $LAST_CHECKED_FILE ]; then
    LAST_CHECKED=`cat $LAST_CHECKED_FILE`
else
    echo $(date +%s) > $LAST_CHECKED_FILE 
fi

if [[ $LAST_CHECKED -lt `expr $NOW - 72 \* 60` ]]; then
    CHANGED=0

    echo $(date +%s) > $LAST_CHECKED_FILE
    
    /usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME remote update && /usr/bin/git --git-dir=$HOME/.dotfiles/.gitrepo --work-tree=$HOME status -uno | grep -q 'Your branch is behind' && CHANGED=1
    
    if [ $CHANGED = 1 ]; then
        $WORK_DIR/update.zsh
    else
        echo "Dotfiles are up-to-date."
    fi
fi
