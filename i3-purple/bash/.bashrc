#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# add scripts to path
SCRIPTSPATH="$HOME/.scripts"

if [ -d "$SCRIPTSPATH" ]; then
    export PATH="$PATH:$SCRIPTSPATH"
fi

# add local user home bin to path
LOCAL_USER_BIN="$HOME/.local/bin"

if [ -d "$LOCAL_USER_BIN" ]; then
    export PATH="$PATH:$LOCAL_USER_BIN"
fi

# virtualenvwrapper
source /home/beard/.local/bin/virtualenvwrapper.sh

# starship prompt
eval "$(starship init bash)"
