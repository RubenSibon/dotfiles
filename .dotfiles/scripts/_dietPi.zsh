# Make DietPi play nice with zsh as it depends on bash
if [ -d "/boot/dietpi" ]; then
    export PATH=/usr/bin:/boot/dietpi:/bin:/usr/sbin:/sbin:$PATH

    if [ -f "/etc/bashrc.d/dietpi.bash" ]; then
        source /etc/bashrc.d/dietpi.bash
    fi
fi
