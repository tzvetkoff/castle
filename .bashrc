#!/bin/bash
# ~/.bashrc - bash interactive session config

#
# is this an interactive session?
#

[[ -z "${PS1}" ]] && return

#
# prevent bashrc from loading twice
#

[[ -n "${BASHRC}" ]] && return
export BASHRC="${BASH_SOURCE[0]}"

#
# bashrc.prepend
#

[[ -r "${HOME}/.bashrc.prepend" ]] && source "${HOME}/.bashrc.prepend"

#
# the prompt string
#

prompt_command() {
  # last command exit status
  [[ ${?} -eq 0 ]] && local exc='\$' || local exc='\[\033[01;31m\]\$\[\033[0m\]'

  # colors
  local reset='\[\033[0m\]'
  local grey='\[\033[1;30m\]'
  local red='\[\033[1;31m\]'
  local green='\[\033[1;32m\]'
  local yellow='\[\033[1;33m\]'
  local blue='\[\033[1;34m\]'
  local cyan='\[\033[0;36m\]'

  # hostname & user
  local host="${blue}${HOSTNAME%%.*}${reset}"
  [[ ${UID} -eq 0 ]] && local user="${red}${USER}${reset}" || local user="${green}${USER}${reset}"

  # current directory
  local pwd="${PWD}"
  [[ "${pwd}" = ${HOME} || "${pwd}" = ${HOME}/* ]]  && pwd='~'"${PWD#${HOME}}"
  [[ "${pwd}" = /home/* ]]                          && pwd='~'"${pwd#/home/}"
  [[ "${pwd}" = /Users/* ]]                         && pwd='~'"${pwd#/Users/}"
  pwd="${yellow}${pwd}${reset}"

  # scm statuses, programming language environments
  local scm= env=

  # avoid tree scans on home directory & add an option to disable them (mainly for slow disks &| large repos)
  if [[ -z ${BASHRC_DISABLE_SCM} && "${dir}" != "${HOME}" ]]; then
    # search for first .git/.svn/.hg in the tree
    local dir="${PWD}" git_dir= svn_dir= hg_dir=
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -z ${BASHRC_DISABLE_SCM_GIT} && -z ${git_dir} && -e "${dir}/.git" ]] && git_dir="${dir}/.git" && break
      [[ -z ${BASHRC_DISABLE_SCM_SVN} && -z ${svn_dir} && -e "${dir}/.svn" ]] && svn_dir="${dir}/.svn" && break
      [[ -z ${BASHRC_DISABLE_SCM_HG}  && -z ${hg_dir}  && -e "${dir}/.hg"  ]] && hg_dir="${dir}/.hg"   && break
      dir="${dir%/*}"
    done

    # git
    if [[ -n ${git_dir} ]]; then
      local branch=`git --git-dir="${git_dir}" symbolic-ref HEAD 2>/dev/null`
      branch="${branch#refs/heads/}"
      if [[ -n ${branch} ]]; then
        local status=`git status --porcelain 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          scm="${scm}${reset}(${grey}git:${red}${branch}${reset})"
        else
          scm="${scm}${reset}(${grey}git:${green}${branch}${reset})"
        fi
      fi
    fi

    # svn
    if [[ -n ${svn_dir} ]]; then
      local revision=`svn info 2>/dev/null | grep Revision: | cut -d' ' -f2`
      if [[ -n ${revision} ]]; then
        local status=`svn status 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          scm="${scm}${reset}(${grey}svn:${red}r${revision}${reset})"
        else
          scm="${scm}${reset}(${grey}svn:${green}r${revision}${reset})"
        fi
      fi
    fi

    # mercurial
    if [[ -n ${hg_dir} ]]; then
      local branch=`hg branch 2>/dev/null`
      if [[ -n ${branch} ]]; then
        local status=`hg status 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          scm="${scm}${reset}(${grey}hg:${red}${branch}${reset})"
        else
          scm="${scm}${reset}(${grey}hg:${green}${branch}${reset})"
        fi
      fi
    fi
  fi

  # environments
  if [[ -z ${BASHRC_DISABLE_ENVMGR} ]]; then
    # ruby
    if [[ -z ${BASHRC_DISABLE_ENVMGR_RUBY} && -n ${GEM_HOME} && ${GEM_HOME} != *@global ]]; then
      local rb="${GEM_HOME##*/}"
      env="${env}{${grey}rb:${cyan}${rb#ruby-}${reset}}"
    fi
    # erlang
    if [[ -z ${BASHRC_DISABLE_ENVMGR_ERLANG} && -n ${ERLANG_PREFIX} ]]; then
      env="${env}{${grey}erl:${cyan}${ERLANG_PREFIX##*/}${reset}}"
    fi
    # elixir
    if [[ -z ${BASHRC_DISABLE_ENVMGR_ELIXIR} && -n ${ELIXIR_PREFIX} ]]; then
      env="${env}{${grey}ex:${cyan}${ELIXIR_PREFIX##*/}${reset}}"
    fi
  fi

  # finally, set the variable
  PS1="${reset}[${user}@${host}(${pwd}${scm}${env})]${exc} "
}

PS1='\u@\h:\w\$ '
PROMPT_COMMAND=prompt_command

#
# icon name & window title
#

icon_name_and_window_title() {
  # hostname
  ${BASHRC_SSH} && local host_icon_name="${HOSTNAME%%.*}:" || local host_icon_name=
  local host_window_title="${HOSTNAME%%.*}"

  # current directory
  local pwd="${PWD}"
  [[ "${pwd}" = ${HOME} || "${pwd}" = ${HOME}/* ]]  && pwd='~'"${PWD#${HOME}}"
  [[ "${pwd}" = /home/* ]]                          && pwd='~'"${pwd#/home/}"
  [[ "${pwd}" = /Users/* ]]                         && pwd='~'"${pwd#/Users/}"

  # set the icon name & window title
  if [[ ${BASH_COMMAND} = prompt_command ]]; then
    echo -ne "\033]1;${host_icon_name}bash\007"
    echo -ne "\033]2;${USER}@${host_window_title}:${pwd}\007"
  else
    echo -ne "\033]1;${host_icon_name}${BASH_COMMAND%% *}\007"
    echo -ne "\033]2;${USER}@${host_window_title}:${pwd} > $BASH_COMMAND\007"
  fi
}

trap icon_name_and_window_title DEBUG

#
# umask !@#$
#

umask 0022

#
# detect ssh session
#

BASHRC_SSH='false'
if [[ -n ${SSH_CLIENT} || -n ${SSH_TTY} ]]; then
  BASHRC_SSH='true'
elif [[ -z ${BASHRC_DISABLE_SSH} ]]; then
  pid=$$
  while [[ -n ${pid} && ${pid} -ne 1 ]]; do
    pid_cmd="`ps -oppid= -ocomm= -p${pid}`"
    pid="${pid_cmd%% *}"
    cmd="${pid_cmd#* }"
    if [[ ${cmd} = *sshd ]]; then
      BASHRC_SSH='true'
      break
    fi
  done
fi
unset pid_cmd pid cmd
export BASHRC_SSH

#
# aliases (and some function overrides)
#

# ls
if [[ ${OSTYPE} = darwin* || ${OSTYPE} = freebsd* ]]; then
  # freebsd & osx both have color support in `ls'
  export LSCOLORS='gxBxhxDxfxhxhxhxhxcxcx'
  alias ls='ls -ACFG'
elif [[ ${OSTYPE} = openbsd* ]]; then
  # on openbsd `colorls' is a different tool
  if type -p colorls >/dev/null; then
    export LSCOLORS='gxBxhxDxfxhxhxhxhxcxcx'
    alias ls='colorls -ACFG'
  else
    alias ls='ls -ACF'
  fi
elif [[ ${OSTYPE} = netbsd* ]]; then
  # on netbsd `colorls' is generally crippled, but still better than nothing
  if type -p colorls >/dev/null; then
    export LSCOLORS='6x5x2x3x1x464301060203'
    alias ls='colorls -ACFG'
  else
    alias ls='ls -ACF'
  fi
else
  # assume we have gnu coreutils
  alias ls='ls -ACF --color=auto'
fi

alias ll='ls -hAlF'
alias li='ls -hAlFi'

# dooh!
alias sl='ls'
alias ks='ls'
alias LS='ls'

# other useful/useless aliases
alias rm='rm -rf'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias dirsize='du -csh'

# rename is lame, ~/.bin/prename is better & more dangerous
alias rename='prename'

# i hate the .viminfo
alias vim='vim -i NONE'

# fix some other typos i make intensively
alias CD='cd'
alias cD='cd'
alias Cd='cd'
alias cd..='cd ..'
cd.(){ cd ."${@}"; }

# rails
alias c='r console'
alias s='r server --binding=0.0.0.0'
alias g='r generate'
alias bundel='bundle'
alias bruby='bundle exec ruby'
alias brake='bundle exec rake'
alias brails='bundle exec r'

# some administrative ones
alias su='sudo su'
alias chown='sudo chown'

# ssh
alias ssh-guest='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sshrc-guest='sshrc -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# macosx
if [[ ${OSTYPE} = darwin* ]]; then
  alias htop='sudo htop'
  alias mtr='sudo mtr'
fi

#
# remove /usr/local/sbin & /usr/local/bin from path
#

PATH="${PATH/\/usr\/local\/sbin:}"
PATH="${PATH/:\/usr\/local\/sbin}"
PATH="${PATH/\/usr\/local\/bin:}"
PATH="${PATH/:\/usr\/local\/bin}"

#
# prepend /usr/local/sbin, /usr/local/bin, ~/bin, ~/.bin, ~/local/bin, ~/.local/bin to path
#

[[ ! "${PATH}" = */usr/local/sbin* ]] && PATH="/usr/local/sbin:${PATH}"
[[ ! "${PATH}" = */usr/local/bin* ]]  && PATH="/usr/local/bin:${PATH}"
[[ -d "${HOME}/bin" ]]                && PATH="${HOME}/bin:${PATH}"
[[ -d "${HOME}/.bin" ]]               && PATH="${HOME}/.bin:${PATH}"
[[ -d "${HOME}/local/bin" ]]          && PATH="${HOME}/local/bin:${PATH}"
[[ -d "${HOME}/.local/bin" ]]         && PATH="${HOME}/.local/bin:${PATH}"

export PATH

#
# disable some common history files (i hate'em)
#

export HISTFILE=/dev/null
export LESSHISTFILE=/dev/null

#
# disable history expansion
#

set +H

#
# set some other handy stuff
#

export SVN_EDITOR=vim
export EDITOR=vim

#
# nicer python
#

export PYTHONSTARTUP="${HOME}/.pythonrc"

#
# bash completion
#

if [[ -f /usr/local/etc/bash_completion ]]; then
  source /usr/local/etc/bash_completion
elif [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
  source /usr/local/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

#
# envmgr
#

[[ -r "${HOME}/.envmgr/init" ]]       && source "${HOME}/.envmgr/init"
[[ -r "${HOME}/.envmgr/completion" ]] && source "${HOME}/.envmgr/completion"

#
# bashrc.d
#

if [[ -d "${HOME}/.bashrc.d" ]]; then
  shopt -s nullglob
  for file in "${HOME}/.bashrc.d"/*; do
    source "${file}"
  done
  shopt -u nullglob
fi

#
# bashrc.append
#

[[ -r "${HOME}/.bashrc.append" ]] && source "${HOME}/.bashrc.append"

#
# show message-of-the-day (not really)
#

[[ -z ${BASHRC_DISABLE_MOTD} ]] && type -p motd >/dev/null && motd
