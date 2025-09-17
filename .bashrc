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

__prompt_command_hooks=()

__prompt_command() {
  for __prompt_command_hook in __prompt_command_head __prompt_command_user_host_pwd_hook "${__prompt_command_hooks[@]}" __prompt_command_tail; do
    "${__prompt_command_hook}"
  done

  PS1="${__prompt_string}"
  unset __prompt_string __prompt_command_hook __prompt_string_head __prompt_string_tail
}

#
# head
#

__prompt_command_head() {
  [[ ${?} -eq 0 ]] && __prompt_string_tail='\$' || __prompt_string_tail='\[\033[01;31m\]\$\[\033[0m\]'
  __prompt_string_head='\[\033[0m\]'
}

#
# tail
#

__prompt_command_tail() {
  __prompt_string="${__prompt_string_head}[${__prompt_string})]${__prompt_string_tail} "
}

#
# user@host(pwd) with some colors
#

__prompt_command_user_host_pwd_hook() {
  local reset='\[\033[0m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]' yellow='\[\033[1;33m\]' blue='\[\033[1;34m\]'

  [[ ${UID} -eq 0 ]] && local user="${red}${USER}${reset}" || local user="${green}${USER}${reset}"
  local host="${blue}${HOSTNAME%%.*}${reset}"

  local pwd="${PWD}"
  [[ "${pwd}" = "${HOME}" || "${pwd}" = ${HOME}/* ]] && pwd="~${PWD#"${HOME}"}"
  [[ "${pwd}" = /home/* ]]                           && pwd="~${pwd#/home/}"
  pwd="${yellow}${pwd}${reset}"

  __prompt_string="${user}@${host}(${pwd}"    # hack: the missing ")" is added in the `tail`
}

#
# git
#

__prompt_command_git_hook() {
  [[ -n "${BASHRC_DISABLE_GIT}" ]] && return

  if [[ "${PWD}" != "${HOME}" ]]; then
    local dir="${PWD}" git_dir=
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -e "${dir}/.git" ]] && git_dir="${dir}/.git" && break
      dir="${dir%/*}"
    done

    if [[ -n "${git_dir}" ]]; then
      local reset='\[\033[0m\]' grey='\[\033[1;30m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]' yellow='\[\033[1;33m\]' blue='\[\033[1;34m\]'
      local branch='' extra='' status='' git=''

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
        branch="$(git --git-dir="${git_dir}" symbolic-ref HEAD 2>/dev/null)"
      else
        if ! branch="$(git --git-dir="${git_dir}" symbolic-ref HEAD 2>/dev/null)"; then
          if branch="$(git --git-dir="${git_dir}" describe --exact-match HEAD 2>/dev/null)"; then
            branch="${blue}${branch}"
          elif branch="$(git --git-dir="${git_dir}" describe --exact-match --tags HEAD 2>/dev/null)"; then
            branch="${blue}${branch}"
          elif [[ -f "${git_dir}/HEAD" ]]; then
            branch="${blue}$(cut -c1-8 "${git_dir}/HEAD")"
          else
            branch="${blue}$(git --git-dir="${git_dir}" rev-parse --short HEAD)"
          fi
        fi
      fi

      branch="${branch#refs/heads/}"
      if [[ -n ${branch} ]]; then
        status="$(git status --porcelain 2>/dev/null | head -1)"
        if [[ -n "${status}" ]]; then
          git="${reset}(${grey}git:${red}${branch}${reset}${extra})"
        else
          git="${reset}(${grey}git:${green}${branch}${reset}${extra})"
        fi
      fi

      __prompt_string="${__prompt_string}${git}"
    fi
  fi
}

[[ -z "${BASHRC_DISABLE_GIT}" ]] && __prompt_command_hooks+=('__prompt_command_git_hook')

#
# svn
#

__prompt_command_svn_hook() {
  [[ -n "${BASHRC_DISABLE_SVN}" ]] && return

  if [[ "${PWD}" != "${HOME}" ]]; then
    local dir="${PWD}" svn_dir=
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -e "${dir}/.svn" ]] && svn_dir="${dir}/.svn" && break
      dir="${dir%/*}"
    done

    if [[ -n ${svn_dir} ]]; then
      local reset='\[\033[0m\]' grey='\[\033[1;30m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]'
      local revision='' status='' svn=''

      revision="$(svn info 2>/dev/null | grep Revision: | cut -d' ' -f2)"
      if [[ -n ${revision} ]]; then
        status="$(svn status 2>/dev/null | head -1)"
        if [[ -n ${status} ]]; then
          svn="${reset}(${grey}svn:${red}r${revision}${reset})"
        else
          svn="${reset}(${grey}svn:${green}r${revision}${reset})"
        fi
      fi

      __prompt_string="${__prompt_string}${svn}"
    fi
  fi
}

[[ -z "${BASHRC_DISABLE_SVN}" ]] && __prompt_command_hooks+=('__prompt_command_svn_hook')

#
# mercurial
#

__prompt_command_hg_hook() {
  [[ -n "${BASHRC_DISABLE_HG}" ]] && return

  if [[ "${PWD}" != "${HOME}" ]]; then
    local dir="${PWD}" hg_dir=''
    while [[ "${dir}" != '/' && -n "${dir}" ]]; do
      [[ -e "${dir}/.hg" ]] && hg_dir="${dir}/.hg" && break
      dir="${dir%/*}"
    done

    if [[ -n ${hg_dir} ]]; then
      local reset='\[\033[0m\]' grey='\[\033[1;30m\]' red='\[\033[1;31m\]' green='\[\033[1;32m\]'
      local branch='' status='' hg=''

      branch="$(hg branch 2>/dev/null)"
      if [[ -n ${branch} ]]; then
        status="$(hg status 2>/dev/null | head -1)"
        if [[ -n ${status} ]]; then
          hg="${reset}(${grey}hg:${red}${branch}${reset})"
        else
          hg="${reset}(${grey}hg:${green}${branch}${reset})"
        fi
      fi

      __prompt_string="${__prompt_string}${hg}"
    fi
  fi
}

[[ -z "${BASHRC_DISABLE_HG}" ]] && __prompt_command_hooks+=('__prompt_command_hg_hook')

#
# envmgr
#

__prompt_command_envmgr_hook() {
  [[ -n ${BASHRC_DISABLE_ENVMGR} ]] && return

  local reset='\[\033[0m\]' grey='\[\033[1;30m\]' cyan='\[\033[0;36m\]'
  local envmgr=''

  if [[ -z ${BASHRC_DISABLE_ENVMGR_RUBY} && -n ${GEM_HOME} ]]; then
    local rb="${GEM_HOME##*/}"
    rb="${rb%@global}"
    envmgr="${envmgr}{${grey}rb:${cyan}${rb#ruby-}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_ERLANG} && -n ${ENVMGR_ERLANG_PREFIX} ]]; then
    envmgr="${envmgr}{${grey}erl:${cyan}${ENVMGR_ERLANG_PREFIX##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_ELIXIR} && -n ${MIX_HOME} ]]; then
    envmgr="${envmgr}{${grey}ex:${cyan}${MIX_HOME##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_GO} && -n ${ENVMGR_GO_PREFIX} ]]; then
    envmgr="${envmgr}{${grey}go:${cyan}${ENVMGR_GO_PREFIX##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_NODE} && -n ${ENVMGR_NODE_PREFIX} ]]; then
    envmgr="${envmgr}{${grey}node:${cyan}${ENVMGR_NODE_PREFIX##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_MUSL} && -n ${ENVMGR_MUSL_PREFIX} ]]; then
    envmgr="${envmgr}{${grey}musl:${cyan}${ENVMGR_MUSL_PREFIX##*/}${reset}}"
  fi

  if [[ -z ${BASHRC_DISABLE_ENVMGR_PYTHON} && -n ${VIRTUAL_ENV_PROMPT} ]]; then
    envmgr="${envmgr}{${grey}py:${cyan}${VIRTUAL_ENV_PROMPT}${reset}}"
  fi

  __prompt_string="${__prompt_string}${envmgr}"
}

[[ -z ${BASHRC_DISABLE_ENVMGR} ]] && __prompt_command_hooks+=('__prompt_command_envmgr_hook')

PS1='\u@\h:\w\$ '
PROMPT_COMMAND=__prompt_command

#
# icon name & window title
#

__xterm_window_title() {
  # user char
  [[ ${UID} -eq 0 ]] && local uchar='#' || local uchar='$'

  # hostname
  local host="${HOSTNAME%%.*}"

  # current directory
  local pwd="${PWD}"
  [[ "${pwd}" = "${HOME}" || "${pwd}" = ${HOME}/* ]] && pwd="~${PWD#"${HOME}"}"
  [[ "${pwd}" = /home/* ]]                           && pwd="~${pwd#/home/}"

  # set the icon name & window title
  if [[ ${BASH_COMMAND} = '__prompt_command' ]]; then
    echo -ne "\033]0;[${USER}@${host}:${pwd}]${uchar}\007"
  else
    local bash_command="${BASH_COMMAND//\\/\\\\}"
    echo -ne "\033]0;[${USER}@${host}:${pwd}]${uchar} ${bash_command}\007"
  fi
}

trap - DEBUG
trap __xterm_window_title DEBUG

#
# umask !@#$
#

umask 0022

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

# fix some other typos i make intensively
alias CD='cd'
alias cD='cd'
alias Cd='cd'
alias cd..='cd ..'
cd.(){ cd ."${*}" || return 1; }

# ruby/rails
alias b='bundle'
alias bundel='bundle'
alias bexec='bundle exec'
alias bruby='bundle exec ruby'
alias brake='bundle exec rake'
alias brcop='bundle exec rubocop'
alias bspec='bundle exec rspec'
alias r='bundle exec rails'
alias c='bundle exec rails console'
alias s='bundle exec rails server --binding=0.0.0.0'
alias g='bundle exec rails generate'

# some administrative ones
alias su='sudo su'
alias chown='sudo chown'

# ssh & scp
alias ssh-nokey='ssh -o PasswordAuthentication=yes -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no'
alias ssh-guest='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sshrc-guest='sshrc -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scp-guest='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# misc
alias screen='unset BASHRC; screen'
alias tmux='unset BASHRC; tmux'

# macosx
if [[ ${OSTYPE} = darwin* ]]; then
  alias htop='sudo htop'
  alias mtr='sudo mtr'
fi

#
# remove /usr/local/sbin, /usr/local/bin, /usr/sbin, /usr/bin, /sbin, /bin from path
#

PATH="${PATH/^\/usr\/local\/sbin:}"
PATH="${PATH/:\/usr\/local\/sbin}"
PATH="${PATH/^\/usr\/local\/bin:}"
PATH="${PATH/:\/usr\/local\/bin}"
PATH="${PATH/^\/usr\/sbin:}"
PATH="${PATH/:\/usr\/sbin}"
PATH="${PATH/^\/usr\/bin:}"
PATH="${PATH/:\/usr\/bin}"
PATH="${PATH/^\/sbin:}"
PATH="${PATH/:\/sbin}"
PATH="${PATH/^\/bin:}"
PATH="${PATH/:\/bin}"

#
# prepend /usr/local/sbin, /usr/local/bin, /usr/sbin, /usr/bin, /sbin, /bin, ~/bin, ~/.bin, ~/local/bin, ~/.local/bin to path
#

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"
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
export MYSQL_HISTFILE=/dev/null
export MYCLI_HISTFILE=/dev/null
export PGCLI_HISTFILE=/dev/null
export SQLITE_HISTORY=/dev/null

#
# disable history expansion
#

set +H

#
# set some other handy stuff
#

export EDITOR=vim
export VISUAL=vim

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
  elif [[ -f /opt/homebrew/etc/bash_completion ]]; then
    source /opt/homebrew/etc/bash_completion
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

[[ -z "${BASHRC_DISABLE_MOTD}" && -x "${HOME}/.motd" ]] && "${HOME}/.motd"
