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
# the prompt string
#

prompt_command() {
  # colors
  local reset='\[\033[00m\]'
  local grey='\[\033[01;30m\]'
  local red='\[\033[01;31m\]'
  local green='\[\033[01;32m\]'
  local yellow='\[\033[01;33m\]'
  local blue='\[\033[01;34m\]'
  local pink='\[\033[01;35m\]'
  local cyan='\[\033[00;36m\]'

  # hostname (without domain)
  local host=${HOSTNAME%%.*}

  # colorized user
  local user="${green}${USER}"
  [[ ${UID} = 0 ]] && user="${red}${USER}"

  # nifty current directory
  local pwd="${PWD}"
  [[ "${pwd}" = ${HOME} || "${pwd}" = ${HOME}/* ]]  && pwd='~'"${PWD#${HOME}}"
  [[ "${pwd}" = /home/* ]]                          && pwd="~${pwd#/home/}"
  [[ "${pwd}" = /Users/* ]]                         && pwd="~${pwd#/Users/}"

  # git/svn/mercurial status, ruby rvm gemset, python virtualenv variables
  local git_dir= git=
  local svn_dir= svn=
  local hg_dir= hg=
  local rgs=
  local pve=

  # avoid tree scans on home directory and add an option to disable them (mainly for slow disks and/or large repos)
  if [[ ( -z ${BASHRC_DISABLE_GIT} || -z ${BASHRC_DISABLE_SVN} || -z ${BASHRC_DISABLE_HG} ) && "${dir}" != "${HOME}" ]]; then
    # search for first .git/.svn/.hg in the tree
    local dir="${PWD}"
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -z ${BASHRC_DISABLE_GIT} && -z ${git_dir} && -e "${dir}/.git" ]] && git_dir="${dir}/.git" && break
      [[ -z ${BASHRC_DISABLE_SVN} && -z ${svn_dir} && -e "${dir}/.svn" ]] && svn_dir="${dir}/.svn" && break
      [[ -z ${BASHRC_DISABLE_HG}  && -z ${hg_dir}  && -e "${dir}/.hg"  ]] && hg_dir="${dir}/.hg"   && break
      dir="${dir%/*}"
    done

    # git
    if [[ -z ${BASHRC_DISABLE_GIT} && -n ${git_dir} ]]; then
      local branch=`git --git-dir="${git_dir}" symbolic-ref HEAD 2>/dev/null`
      branch="${branch#refs/heads/}"
      if [[ -n ${branch} ]]; then
        local status=`git status --porcelain 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          git="${reset}(${grey}git:${red}${branch}${reset})"
        else
          git="${reset}(${grey}git:${green}${branch}${reset})"
        fi
      fi
    fi

    # svn
    if [[ -z ${BASHRC_DISABLE_SVN} && -n ${svn_dir} ]]; then
      local revision=`svn info 2>/dev/null | grep Revision: | cut -d' ' -f2`
      if [[ -n ${revision} ]]; then
        local status=`svn status 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          svn="${reset}(${grey}svn:${red}r${revision}${reset})"
        else
          svn="${reset}(${grey}svn:${green}r${revision}${reset})"
        fi
      fi
    fi

    # mercurial
    if [[ -z ${BASHRC_DISABLE_HG} && -n ${hg_dir} ]]; then
      local branch=`hg branch 2>/dev/null`
      if [[ -n ${branch} ]]; then
        local status=`hg status 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          hg="${reset}(${grey}hg:${red}${branch}${reset})"
        else
          hg="${reset}(${grey}hg:${green}${branch}${reset})"
        fi
      fi
    fi
  fi

  # rvm environment
  if [[ -z ${BASHRC_DISABLE_RVM_GEMSET} && -n ${GEM_HOME} && ${GEM_HOME} = *${rvm_gemset_separator:-'@'}* ]]; then
    rgs="${reset}{${grey}rb:${cyan}${GEM_HOME##*@}${reset}}"
  fi

  # python virtualenv
  if [[ -z ${BASHRC_DISABLE_PYTHON_VIRTUALENV} && -n ${VIRTUAL_ENV} ]]; then
    pve="${reset}{${grey}py:${cyan}${VIRTUAL_ENV##*/}${reset}}"
  fi

  # finally, set the variable
  PS1="${reset}[${green}${user}${reset}@${blue}${host}${reset}(${yellow}${pwd}${git}${svn}${hg}${rgs}${pve}${reset})]\\$ "
}

PS1='\u@\h:\w\$ '
PROMPT_COMMAND=prompt_command

#
# umask !@#$
#

umask 0022

#
# aliases (and some function overrides)
#

# ls
if [[ ${OSTYPE} = darwin* || ${OSTYPE} = freebsd* ]]; then
  export CLICOLOR=1
  export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
  alias ls='ls -ACF'
  alias lo='ls -hAlFO'
else
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

# rename is lame, perl's one in ~/.bin is better and more dangerous
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
alias xxl='bundle exec rake db:drop db:create db:migrate db:seed'

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
# remove /usr/local/sbin and /usr/local/bin from path
#

PATH="${PATH/\/usr\/local\/sbin:}"
PATH="${PATH/:\/usr\/local\/sbin}"
PATH="${PATH/\/usr\/local\/bin:}"
PATH="${PATH/:\/usr\/local\/bin}"

#
# prepend /usr/local/sbin, /usr/local/bin, ~/bin, ~/.bin and ~/.local/bin to path
#

[[ ! "${PATH}" = */usr/local/sbin* ]] && PATH="/usr/local/sbin:${PATH}"
[[ ! "${PATH}" = */usr/local/bin* ]]  && PATH="/usr/local/bin:${PATH}"
[[ -d "${HOME}/bin" ]]                && PATH="${HOME}/bin:${PATH}"
[[ -d "${HOME}/.bin" ]]               && PATH="${HOME}/.bin:${PATH}"
[[ -d "${HOME}/.local/bin" ]]         && PATH="${HOME}/.local/bin:${PATH}"

export PATH

#
# disable some common history files (i hate'em)
#

export HISTFILE=/dev/null
export LESSHSTFILE=/dev/null

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
# rvm
#

[[ -s "${HOME}/.rvm/scripts/rvm" ]]         && source "${HOME}/.rvm/scripts/rvm"
[[ -r "${HOME}/.rvm/scripts/completion" ]]  && source "${HOME}/.rvm/scripts/completion"

#
# bashrc.d & bashrc.extra
#

if [[ -d "${HOME}/.bashrc.d" ]]; then
  shopt -s nullglob
  for file in "${HOME}/.bashrc.d"/*; do
    source "${file}"
  done
  shopt -u nullglob
fi

[[ -r "${HOME}/.bashrc.extra" ]] && source "${HOME}/.bashrc.extra"

#
# show message-of-the-day (not really)
#

[[ -z ${BASHRC_DISABLE_MOTD} ]] && type -p motd >/dev/null && motd
