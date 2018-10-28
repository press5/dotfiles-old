# jkl's theme 
# based off agnoster's theme - https://gist.github.com/3712874
# a powerline-inspired theem for zsh
#
# for this to function properly you either need to be using my repo
# or be using a powerline patched font from the repo here: 
# [https://github.com/Lokaltog/powerline-fonts]
#
# in addition, i (like agnoster) recommend the solarized dark theme 
# (https://github.com/altercation/solarized/) in your favorite terminal,
# if you're on OS X, using Iterm2 [http://www.iterm2.com/] over Terminal.app
# it has significantly better color fidelity.
#
# the aim of this theme is to only show you *relevant* information. it will 
# only show git information when in a git working directory. it also looks
# everything from the current user and hostname to whether the last call 
# exited with an error to whether background jobs are running in the shell,
# and will all be displayed automatically when appropriate.

###############################################################################

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  # if we're on a sshfs mount just ignore this entire function
  if [[ -n ${ITERM_SESSION_ID+1}  ]]; then
    echo -n 
    elif [[ `echo $PWD` == *sdf* ]]; then 
    echo -n 
    elif [[ -n ${VSCODE_PID} ]]; then
    echo -n
    else 
  if [[ `stat -f -L -c %T $PWD` == *fuseblk* ]]; then return; fi
  fi
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment red black
    else
      prompt_segment green black
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '^'
    zstyle ':vcs_info:git:*' unstagedstr '!'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
# if we're in 'master', don't show the name of the repo, just show the icon.
# if we're not in 'master' then we should care & show the repo name
    if $(git symbolic-ref HEAD | grep -i master >/dev/null 2>&1); then
      echo -n "${ref/refs\/heads\/master/}${vcs_info_msg_0_%% }${mode}"
    else
      echo -n "${ref/refs\/heads\// }${vcs_info_msg_0_%% }${mode}"
    fi
  fi
}

prompt_hg() {
  local rev status
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green black
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment red black
        st='±'
      elif `hg st | grep -q "^(M|A)"`; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green black
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Dir: current working directory
prompt_dir() {

# set up ellipsis of long paths, if i really want to know my 
# full path i can 'cd' i'm a big girl
  set ellipsis
# %4(c:...:)%3c will show ellipses if %c is  at least 4 path elements
# long, nothing if less, followed by the last 3 elements of %c.
  prompt_segment blue black '%4(c:.../:)%3c'
# WAS: prompt_segment blue black '%~'
}

prompt_lba() {

if [[ -f /tmp/.lba ]]; then 
  prompt_segment yellow black 'ß'
fi

}



# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue black "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⎇"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
#if [[ `stat -f -L -c %T $PWD` == *fuseblk* ]]; then

build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_lba
  prompt_git
  prompt_dir
  prompt_hg
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
