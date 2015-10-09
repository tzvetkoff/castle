# ~/.bashrc - bash interactive session config

#
# is this an interactive session?
#

[[ -z "${PS1}" ]] && return

#
# prompt string made the nice way
#

prompt_command() {
  # hostname
  local host=${HOSTNAME%%.*}

  # colors
  local reset='\[\033[00m\]'
  local grey='\[\033[01;30m\]'
  local red='\[\033[01;31m\]'
  local green='\[\033[01;32m\]'
  local yellow='\[\033[01;33m\]'
  local blue='\[\033[01;34m\]'
  local pink='\[\033[01;35m\]'
  local cyan='\[\033[00;36m\]'

  # nifty current directory
  local pwd=${PWD/$HOME/\~}
  if [[ $pwd = /home/* ]]; then
    pwd=\~${pwd#/home/}
  fi

  # git/svn status, ruby rvm gemset, python virtualenv
  local git=
  local svn=
  local rgs=
  local pve=
  local dir=${PWD}

  if [[ ${dir} != ${HOME} ]]; then
    if [[ -z ${BASHRC_DISABLE_GIT} ]]; then
      while [[ ! -e ${dir}/.git && ${dir} != '/' && -n ${dir} ]]; do
        dir=${dir%/*}
      done

      if [[ -n ${dir} ]]; then
        local branch=`git symbolic-ref HEAD 2>/dev/null`
        branch=${branch#refs/heads/}
        if [[ -n ${branch} ]]; then
          local status=`git status --porcelain 2>/dev/null`
          if [[ -n ${status} ]]; then
            git="${reset}(${grey}git:${red}${branch}${reset})"
          else
            git="${reset}(${grey}git:${green}${branch}${reset})"
          fi
        fi
      fi
    fi

    if [[ -z ${git} && -z ${BASHRC_DISABLE_SVN} ]]; then
      dir=${PWD}
      while [[ ! -d ${dir}/.svn && ${dir} != '/' && -n ${dir} ]]; do
        dir=${dir%/*}
      done

      if [[ -n ${dir} ]]; then
        local revision=`svn info 2>/dev/null|grep Revision:|cut -d' ' -f2`
        if [[ -n ${revision} ]]; then
          #svn="${reset}(${grey}svn:${blue}r${revision}${reset})"
          local status=`svn status 2>/dev/null|head -1`
          if [[ -n ${status} ]]; then
            svn="${reset}(${grey}svn:${red}r${revision}${reset})"
          else
            svn="${reset}(${grey}svn:${green}r${revision}${reset})"
          fi
        fi
      fi
    fi

    if [[ -z ${BASHRC_DISABLE_RVM_GEMSET} && -n ${GEM_HOME} && ${GEM_HOME} = *${rvm_gemset_separator:-'@'}* ]]; then
      rgs="${reset}{${grey}rb:${cyan}${GEM_HOME##*@}${reset}}"
    fi

    if [[ -z ${BASHRC_DISABLE_VIRTUALENV} && -n ${VIRTUAL_ENV} ]]; then
      pve="${reset}{${grey}py:${cyan}${VIRTUAL_ENV##*/}${reset}}"
    fi
  fi

  PS1="${reset}[${green}${USER}${reset}@${blue}${host}${reset}(${yellow}${pwd}${git}${svn}${rgs}${pve}${reset})]\\$ "
}

PS1="\u@\h:\w\\$ "
PROMPT_COMMAND=prompt_command

#
# aliases
#

# ls
if [[ ${OSTYPE} = darwin* && ${OSTYPE} != 'darwin9' ]]; then
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

# rails
alias r='rails'
alias rc='rails console'
alias c='rails console'
alias rs='rails server'
alias s='rails server'
alias rg='rails generate'
alias g='rails generate'
alias bundel='bundle'
alias be='bundle exec'
alias br='bundle exec rake'
alias xxl='bundle exec rake db:drop db:create db:migrate db:seed'

# git
alias push='git push'
alias pull='git pull'
alias pop='git pull'
alias gdiff='git diff --ignore-all-space'

# some administrative ones
alias su='sudo su'
alias chown='sudo chown'

# macosx
if [[ ${OSTYPE} = darwin* ]]; then
  alias htop='sudo htop'
fi

#
# remove /usr/local/bin and /usr/local/sbin from path
#

PATH=${PATH/\/usr\/local\/bin:}
PATH=${PATH/:\/usr\/local\/bin}
PATH=${PATH/\/usr\/local\/sbin:}
PATH=${PATH/:\/usr\/local\/sbin}

#
# prepend /usr/local/bin, /usr/local/sbin, ~/bin, ~/.bin and ~/.local/bin to path
#

[[ ! $PATH =~ "/usr/local/bin" ]]   && PATH="/usr/local/bin:${PATH}"
[[ ! $PATH =~ "/usr/local/sbin" ]]  && PATH="/usr/local/sbin:${PATH}"
[[ -d "${HOME}/bin" ]]              && PATH="${HOME}/bin:${PATH}"
[[ -d "${HOME}/.bin" ]]             && PATH="${HOME}/.bin:${PATH}"
[[ -d "${HOME}/.local/bin" ]]       && PATH="${HOME}/.local/bin:${PATH}"

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
# A bit nicer python
#

export PYTHONSTARTUP="${HOME}/.pythonrc"

#
# bash completion
#

if [[ -x /usr/local/bin/brew && -f `brew --prefix`/etc/bash_completion ]]; then
  . `brew --prefix`/etc/bash_completion
elif [[ -f /usr/local/share/bash-completion/bash_completion ]]; then
  . /usr/local/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  . /etc/bash_completion
fi

#
# rvm
#

[[ -s "${HOME}/.rvm/scripts/rvm" ]]         && . "${HOME}/.rvm/scripts/rvm"
[[ -r "${HOME}/.rvm/scripts/completion" ]]  && . "${HOME}/.rvm/scripts/completion"

#
# bashrc.d & bashrc.extra
#

if [[ -d "${HOME}/.bashrc.d" ]]; then
  shopt -s nullglob
  for file in ${HOME}/.bashrc.d/*; do
    . "${file}"
  done
  shopt -u nullglob
fi

[[ -r "${HOME}/.bashrc.extra" ]] && . "${HOME}/.bashrc.extra"

#
# show message-of-the-day if script is installed
#

[[ -z ${BASHRC_DISABLE_MOTD} && -n `type -p motd` ]] && motd
