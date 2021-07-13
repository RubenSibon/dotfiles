function enable_on_dietpi {
  if [ -d "/boot/dietpi" ]; then
      export PATH=/usr/bin:/boot/dietpi:/bin:/usr/sbin:/sbin:$PATH

      if [ -f "/etc/bashrc.d/dietpi.bash" ]; then
          source /etc/bashrc.d/dietpi.bash
      fi
  fi
}
