xport HAVEGLOBAL="yes"
export PS1='\h:\w\$ '
umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
 export LS_OPTIONS='--color=auto'
 eval `dircolors`
 alias ls='ls $LS_OPTIONS'
 alias ll='ls $LS_OPTIONS -l'
 alias l='ls $LS_OPTIONS -lA'

export PATH="/wigwag/system/bin:$PATH"
export LD_LIBRARY_PATH="/wigwag/system/lib:$LD_LIBRARY_PATH"
export BASHLIBS="/wigwag/system/lib/bash/:$BASHLIBS"