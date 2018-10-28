#!/usr/bin/env sh
# setup script for my boxes
# so far all we support is debian
if grep -qi debian /etc/issue.net; then dist='debian'
# elif grep -qi foo /etc/issue.net; then dist='bar'
else dist='unknown'
fi
debian() {
  # list out some packages i want
  cli_pkgs="build-essential fail2ban tmux git zsh vim keychain"
  i3_pkgs="i3"
  xfc_pkgs="xfce4"
  gui_common="rxvt-unicode"
  # check for sudo
  has_sudo=$(type sudo >/dev/null 2>&1; echo $? )
  if  [ "$has_sudo" -eq "0" ] ; then
    echo "we have sudo already. yay!"
  else
    echo "we need to install sudo so enter root's pw"
    su -c "apt-get -qq update && apt-get -qq install sudo && usermod -a -G sudo $USER"
    # i'll probably always be jkl but doing $USER seemed like a good idea.
    echo "sudo installed; granted you sudo. now we can keep going!"
    #now keep going
  fi
  # do we want a gui?
  while true; do
    read -p "Install type: [0] cli only  [1] i3  [2] xfce " yesno
    case $yesno in
      1) want_gui="1"; break;;
      0) want_gui="0"; break;;
      2) want_gui="2"; break;;
      *) echo "you must give a number";;
    esac
  done
  # install some shit
  if [ $want_gui -eq "0" ]; then
    echo "wait a few..."
    sudo apt-get -qq install $cli_pkgs
  elif [ $want_gui -eq "2" ]; then
    echo "wait a few..."
    sudo apt-get -qq install $cli_pkgs $xfc_pkgs $gui_common
  elif [ $want_gui -eq "1" ]; then
    echo "wait a few..."
    sudo apt-get -qq install $cli_pkgs $i3_pkgs $gui_common
  else
    echo "oops, something is broken..."
  fi
  # last make ssh keys
  if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa
  else
    echo "i already see an rsa private key, skipping creation"
  fi
  # chsh
  echo "password prompt to change shell:"
  chsh -s /usr/bin/zsh
  # last thing: now git
  echo "here's your public ssh key:"
  cat ~/.ssh_id_rsa.pub
  while true; do
    read -p "when you've set it up in github, type y:" gityn
    case $gityn in
      [Yy]) break;;
         *) echo "type y when you're done";;
    esac
  done
  
  git init ~
  git remote add origin git@github.com:docjkl/dotfiles.git
  git fetch --all 
  git reset --hard FETCH_HEAD
  git submodule update --init --recursive

  echo "ready for use.\n\n"
}


unknown() {
  echo "i have no idea what kind of system this is"
}

# END

$dist


