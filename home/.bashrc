# ~/.bashrc - bash interactive session config

# load rvm stuff
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"

# is this an interactive session?
[ -z "$PS1" ] && return


#
# prompt string
#
## common colors
reset='\[\033[00m\]'
red='\[\033[01;31m\]'
green='\[\033[01;32m\]'
yellow='\[\033[01;33m\]'
blue='\[\033[01;34m\]'
pink='\[\033[01;35m\]'
cyan="\[\033[01;36m\]"

## make it fancy
where_am_i() {
    t=${PWD/$HOME/\~}
    t=${t/\/home\//\~}
    echo $t
}

#PS1="${reset}[${red}\u${reset}@${blue}\h${reset}(${pink}\`where_am_i\`${reset})]\\$ "
#PS1="${reset}[${green}\u${reset}@${green}\h${reset}(${yellow}\`where_am_i\`${reset})]\\$ "
PS1="${green}\u${reset}@${blue}darkstar${reset}:${yellow}\`where_am_i\`${reset}\\$ "
#PS1="${reset}[${cyan}\u${reset}@${red}darkstar${reset}(${yellow}\`where_am_i\`${reset})]\\$ "


#
# ls colors
#
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx


#
# aliases
#
## ls aliases
alias ls='ls -ACFG'
alias ll='ls -hAlFG'
alias li='ls -hAlFiG'

## dooh!
alias sl='ls'
alias ks='ls'
alias LS='ls'

## other useful/useless aliases
alias rm='rm -rf'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias dirsize='du -csh'

## util-linux-ng's rename is lame, perl's one is way better
alias rename='prename'

## i hate the .viminfo
alias vim='vim -i NONE'

## fix some other typos i make intensively
alias CD='cd'
alias cd.='source /usr/local/bin/cd.'
alias cd..='cd ..'

## some administrative ones
alias su='sudo su'
alias chown='sudo chown'
alias port='sudo port'

#
# for macosx - remove /usr/local/bin and /usr/local/sbin from path
#
PATH=${PATH/\/usr\/local\/bin:}
PATH=${PATH/\/usr\/local\/sbin:}

#
# add /usr/local/bin, /usr/local/sbin, ~/bin and ~/.local/bin to path
#
[[ ! $PATH =~ "/usr/local/bin" ]]	&& PATH="/usr/local/bin:${PATH}"
[[ ! $PATH =~ "/usr/local/sbin" ]]	&& PATH="/usr/local/sbin:${PATH}"
[[ -d "${HOME}/bin" ]]				&& PATH="${HOME}/bin:${PATH}"
[[ -d "${HOME}/.local/bin" ]]		&& PATH="${HOME}/.local/bin:${PATH}"

# MacOSX paths too
[[ -d "/opt/local/bin" ]]			&& PATH="/opt/local/bin:${PATH}"
[[ -d "/opt/local/sbin" ]]			&& PATH="/opt/local/sbin:${PATH}"

export PATH


#
# disable some common history files (i hate'em)
#
export HISTFILE=/dev/null
export LESSHSTFILE=/dev/null


#
# set some other handy stuff
#
export SVN_EDITOR=vim


#
# show message-of-the-day if script is installed
#
[[ ! -z `type -p motd` ]] && motd


#
# Set vim as default editor
#
export EDITOR=vim


#
# Bash completion
#
if [ -f `brew --prefix`/etc/bash_completion ]; then
	. `brew --prefix`/etc/bash_completion
fi
