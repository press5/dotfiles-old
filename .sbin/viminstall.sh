# set up my custom vim if it's not installed on the server already

# check for build folder
if [ ! -d ~/build ]; then
  mkdir ~/build;
fi

# make vim folder if it doesn't exist:
if [ ! -d ~/.vim/bundle ]; then
  mkdir -p ~/.vim/bundle;
fi

# check for git
type git >/dev/null 2>&1 || { echo >&2 "git not installed; exiting."; exit 1; }

# disable ssl verify
export GIT_SSL_NO_VERIFY=1
git clone https://github.com/vim/vim.git ~/build/vim
unset GIT_SSL_NO_VERIFY

# my custom version of vim
#export VIM="/home/jklitwin/.vim/share/vim/vim73"
#alias vim='/home/jklitwin/.vim/bin/jkl'

cd $HOME/build/vim

./configure --prefix=$HOME/bin/vim --enable-perlinterp=yes --enable-rubyinterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --enable-multibyte --with-vim-name=jkl --with-compiledby=jkl --with-features=huge

make && make install

make 

