# ~/.bashrc - bash interactive session config

# load rvm stuff
[[ -s "${HOME}/.rvm/scripts/rvm" ]]			&& source "${HOME}/.rvm/scripts/rvm"
[[ -r "${HOME}/.rvm/scripts/completion" ]]	&& source "${HOME}/.rvm/scripts/completion"

# is this an interactive session?
[ -z "$PS1" ] && return


#
# PS1 made the nice way
#
prompt_command() {
	## colors
	local reset='\[\033[00m\]'
	local grey='\[\033[01;30m\]'
	local red='\[\033[01;31m\]'
	local green='\[\033[01;32m\]'
	local yellow='\[\033[01;33m\]'
	local blue='\[\033[01;34m\]'
	local pink='\[\033[01;35m\]'
	local cyan='\[\033[01;36m\]'

	## nifty current directory
	local pwd=${PWD/$HOME/\~}
	pwd=${pwd/\/home\//\~}

	## git status
	local git=
	local svn=
	local dir=${PWD}

	if [[ ${dir} != ${HOME} ]]; then
		while [[ ! -d ${dir}/.git && ${dir} != '/' && -n ${dir} ]]; do
			dir=${dir%/*}
		done

		if [[ -n ${dir} && -z ${BASHRC_DISABLE_GIT} ]]; then
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

		if [[ -z ${git} && -z ${BASHRC_DISABLE_SVN} ]]; then
			dir=${PWD}
			while [[ ! -d ${dir}/.svn && ${dir} != '/' && -n ${dir} ]]; do
				dir=${dir%/*}
			done

			if [[ -n ${dir} ]]; then
				local revision=`svn info 2>/dev/null|grep Revision:|awk '{ print $2 }'`
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
	fi

	PS1="${reset}[${green}${USER}${reset}@${blue}darkstar${reset}(${yellow}${pwd}${git}${svn}${reset})]\\$ "
}

PS1="\u@\h:\w\\$ "
PROMPT_COMMAND=prompt_command


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
alias cd..='cd ..'

## rails!
alias r='rails'
alias brake='bundle exec rake'

## some administrative ones
alias su='sudo su'
alias chown='sudo chown'

#
# for macosx - remove /usr/local/bin and /usr/local/sbin from path
#
PATH=${PATH/\/usr\/local\/bin:}
PATH=${PATH/\/usr\/local\/sbin:}

#
# add /usr/local/bin, /usr/local/sbin, ~/bin, ~/.bin and ~/.local/bin to path
#
[[ ! $PATH =~ "/usr/local/bin" ]]	&& PATH="/usr/local/bin:${PATH}"
[[ ! $PATH =~ "/usr/local/sbin" ]]	&& PATH="/usr/local/sbin:${PATH}"
[[ -d "${HOME}/bin" ]]				&& PATH="${HOME}/bin:${PATH}"
[[ -d "${HOME}/.bin" ]]				&& PATH="${HOME}/.bin:${PATH}"
[[ -d "${HOME}/.local/bin" ]]		&& PATH="${HOME}/.local/bin:${PATH}"

# Homebrew paths here
[[ -d "/usr/local/share/python" ]]	&& PATH="/usr/local/share/python:${PATH}"

# MacPorts paths here
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
if [[ -f `brew --prefix`/etc/bash_completion ]]; then
	. `brew --prefix`/etc/bash_completion
fi


#
# Git completion
#
if [[ -f ${HOME}/.git-completion.bash ]]; then
	. ${HOME}/.git-completion.bash
fi
