#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# add scripts to path

if [ -d "$HOME/.scripts" ] ; then
    # set scripts path
    SCRIPTSPATH="$HOME/.scripts"
    # include scripts in the path
    export PATH="$PATH:$SCRIPTSPATH"
fi

eval "$(starship init bash)"
