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

prompt_command_hooks=()

prompt_command() {
  for __prompt_command_hook in prompt_command_head prompt_command_user_host_pwd_hook "${prompt_command_hooks[@]}" prompt_command_tail; do
    "${__prompt_command_hook}"
  done

  PS1="${__prompt_string}"
  unset __prompt_string __prompt_command_hook __prompt_string_head __prompt_string_tail
}

#
# head
#

prompt_command_head() {
  [[ ${?} -eq 0 ]] && __prompt_string_tail='\$' || __prompt_string_tail='\[\033[01;31m\]\$\[\033[0m\]'
  __prompt_string_head='\[\033[0m\]'
}

#
# tail
#

prompt_command_tail() {
  __prompt_string="${__prompt_string_head}[${__prompt_string})]${__prompt_string_tail} "
}

#
# user@host(pwd) with some colors
#

prompt_command_user_host_pwd_hook() {
  local reset='\[\033[0m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]' yellow='\[\033[1;33m\]' blue='\[\033[1;34m\]'

  [[ ${UID} -eq 0 ]] && local user="${red}${USER}${reset}" || local user="${green}${USER}${reset}"
  local host="${blue}${HOSTNAME%%.*}${reset}"

  local pwd="${PWD}"
  [[ "${pwd}" = ${HOME} || "${pwd}" = ${HOME}/* ]]  && pwd='~'"${PWD#${HOME}}"
  [[ "${pwd}" = /home/* ]]                          && pwd='~'"${pwd#/home/}"
  [[ "${pwd}" = /Users/* ]]                         && pwd='~'"${pwd#/Users/}"
  pwd="${yellow}${pwd}${reset}"

  __prompt_string="${user}@${host}(${pwd}"    # hack: the missing ")" is added in the `tail`
}

#
# git
#

prompt_command_git_hook() {
  [[ -n ${BASHRC_DISABLE_GIT} ]] && return

  if [[ "${PWD}" != "${HOME}" ]]; then
    local dir="${PWD}" git_dir=
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -z ${git_dir} && -e "${dir}/.git" ]] && git_dir="${dir}/.git" && break
      dir="${dir%/*}"
    done

    if [[ -n ${git_dir} ]]; then
      local reset='\[\033[0m\]' grey='\[\033[1;30m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]' yellow='\[\033[1;33m\]' blue='\[\033[1;34m\]'
      local branch= extra=

      if [[ -d "${git_dir}/rebase-apply" ]]; then
        if [[ -f "${git_dir}/rebase-apply/rebasing" ]]; then
          extra="|${yellow}rebase${reset}"
        elif [[ -f "${git_dir}/rebase-apply/applying" ]]; then
          extra="|${yellow}am${reset}"
        else
          extra="|${yellow}am/rebase${reset}"
        fi
        branch="$(< "${git_dir}/rebase-apply/head-name")"
      elif [[ -f "${git_dir}/rebase-merge/interactive" ]]; then
        extra="|${yellow}rebase-i${reset}"
        branch="$(< "${git_dir}/rebase-merge/head-name")"
      elif [[ -d "${git_dir}/rebase-merge" ]]; then
        extra="|${yellow}rebase-m${reset}"
        branch="$(< "${git_dir}/rebase-merge/head-name")"
      elif [[ -f "${git_dir}/MERGE_HEAD" ]]; then
        extra="|${yellow}merge${reset}"
        branch=`git --git-dir="${git_dir}" symbolic-ref HEAD 2>/dev/null`
      else
        if ! branch=`git --git-dir="${git_dir}" symbolic-ref HEAD 2>/dev/null`; then
          if branch=`git --git-dir="${git_dir}" describe --exact-match HEAD 2>/dev/null`; then
            branch="${blue}${branch}"
          elif branch=`git --git-dir="${git_dir}" describe --tags HEAD 2>/dev/null`; then
            branch="${blue}${branch}"
          else
            branch="${blue}`cut -c1-8 "${git_dir}/HEAD"`"
          fi
        fi
      fi

      branch="${branch#refs/heads/}"
      if [[ -n ${branch} ]]; then
        local status=`git status --porcelain 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          local git="${reset}(${grey}git:${red}${branch}${reset}${extra})"
        else
          local git="${reset}(${grey}git:${green}${branch}${reset}${extra})"
        fi
      fi

      __prompt_string="${__prompt_string}${git}"
    fi
  fi
}

[[ -z ${BASHRC_DISABLE_GIT} ]] && prompt_command_hooks+=('prompt_command_git_hook')

#
# svn
#

prompt_command_svn_hook() {
  [[ -n ${BASHRC_DISABLE_SVN} ]] && return

  if [[ "${PWD}" != "${HOME}" ]]; then
    local dir="${PWD}" svn_dir=
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -z ${svn_dir} && -e "${dir}/.svn" ]] && svn_dir="${dir}/.svn" && break
      dir="${dir%/*}"
    done

    if [[ -n ${svn_dir} ]]; then
      local reset='\[\033[0m\]' grey='\[\033[1;30m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]'

      local revision=`svn info 2>/dev/null | grep Revision: | cut -d' ' -f2`
      if [[ -n ${revision} ]]; then
        local status=`svn status 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          local svn="${reset}(${grey}svn:${red}r${revision}${reset})"
        else
          local svn="${reset}(${grey}svn:${green}r${revision}${reset})"
        fi
      fi

      __prompt_string="${__prompt_string}${svn}"
    fi
  fi
}

[[ -z ${BASHRC_DISABLE_SVN} ]] && prompt_command_hooks+=('prompt_command_svn_hook')

#
# mercurial
#

prompt_command_hg_hook() {
  [[ -n ${BASHRC_DISABLE_HG} ]] && return

  if [[ "${PWD}" != "${HOME}" ]]; then
    local dir="${PWD}" hg_dir=
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -z ${hg_dir} && -e "${dir}/.hg"  ]] && hg_dir="${dir}/.hg" && break
      dir="${dir%/*}"
    done

    if [[ -n ${hg_dir} ]]; then
      local reset='\[\033[0m\]' grey='\[\033[1;30m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]'

      local branch=`hg branch 2>/dev/null`
      if [[ -n ${branch} ]]; then
        local status=`hg status 2>/dev/null | head -1`
        if [[ -n ${status} ]]; then
          local hg="${reset}(${grey}hg:${red}${branch}${reset})"
        else
          local hg="${reset}(${grey}hg:${green}${branch}${reset})"
        fi
      fi

      __prompt_string="${__prompt_string}${hg}"
    fi
  fi
}

[[ -z ${BASHRC_DISABLE_HG} ]] && prompt_command_hooks+=('prompt_command_hg_hook')

#
# envmgr
#

prompt_command_envmgr_hook() {
  [[ -n ${BASHRC_DISABLE_ENVMGR} ]] && return

  local reset='\[\033[0m\]' grey='\[\033[1;30m\]' cyan='\[\033[0;36m\]'
  local env=

  if [[ -z ${BASHRC_DISABLE_ENVMGR_RUBY} && -n ${GEM_HOME} && ${GEM_HOME} != *@global ]]; then
    local rb="${GEM_HOME##*/}"
    env="${env}{${grey}rb:${cyan}${rb#ruby-}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_ERLANG} && -n ${ENVMGR_ERLANG_PREFIX} ]]; then
    env="${env}{${grey}erl:${cyan}${ENVMGR_ERLANG_PREFIX##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_ELIXIR} && -n ${MIX_HOME} ]]; then
    env="${env}{${grey}ex:${cyan}${MIX_HOME##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_GO} && -n ${ENVMGR_GO_PREFIX} ]]; then
    env="${env}{${grey}go:${cyan}${ENVMGR_GO_PREFIX##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_NODE} && -n ${NPM_CONFIG_PREFIX} ]]; then
    env="${env}{${grey}node:${cyan}${NPM_CONFIG_PREFIX##*/}${reset}}"
  fi

  __prompt_string="${__prompt_string}${env}"
}

[[ -z ${BASHRC_DISABLE_ENVMGR} ]] && prompt_command_hooks+=('prompt_command_envmgr_hook')

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
    local bash_command="${BASH_COMMAND//\\/\\\\}"
    echo -ne "\033]1;${host_icon_name}${bash_command%% *}\007"
    echo -ne "\033]2;${USER}@${host_window_title}:${pwd} > ${bash_command}\007"
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
  alias ls='ls -AFG'
elif [[ ${OSTYPE} = openbsd* ]]; then
  # on openbsd `colorls' is a different tool
  if type -p colorls >/dev/null; then
    export LSCOLORS='gxBxhxDxfxhxhxhxhxcxcx'
    alias ls='colorls -AFG'
  else
    alias ls='ls -AF'
  fi
elif [[ ${OSTYPE} = netbsd* ]]; then
  # on netbsd `colorls' is generally crippled, but still better than nothing
  if type -p colorls >/dev/null; then
    export LSCOLORS='6x5x2x3x1x464301060203'
    alias ls='colorls -AFG'
  else
    alias ls='ls -AF'
  fi
else
  # assume we have gnu coreutils
  alias ls='ls -AF --color=auto'
fi

export QUOTING_STYLE='literal'

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

# ssh & scp
alias ssh-guest='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sshrc-guest='sshrc -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scp-guest='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# misc
alias screen='unset BASHRC; screen'

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

if [[ -z "${BASH_COMPLETION_VERSINFO}" ]]; then
  if [[ -f /usr/local/etc/bash_completion ]]; then
    source /usr/local/etc/bash_completion
  elif [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
    source /usr/local/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

#
# local completions
#

if [[ -n "${BASH_COMPLETION_VERSINFO}" ]]; then
  if [[ -d "${HOME}/.bash_completion.d" ]]; then
    shopt -s nullglob
    for file in "${HOME}/.bash_completion.d"/*; do
      source "${file}"
    done
    shopt -u nullglob
  fi
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
