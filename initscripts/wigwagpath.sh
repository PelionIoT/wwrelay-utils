export HAVEGLOBAL="yes"
export PS1='\h:\w\$ '
umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
color_prompt=yes
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\
\[\033[00m\]\$ '
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi


export PATH="/wigwag/system/bin:$PATH"
export LD_LIBRARY_PATH="/wigwag/system/lib:$LD_LIBRARY_PATH"
export BASHLIBS="/wigwag/system/lib/bash/:$BASHLIBS"