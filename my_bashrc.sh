#!/bin/sh

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ag='ag -i'
alias ack='ack -i'
alias a='ag -i'

alias e="emacs"
alias eq="emacs -Q"

alias gx="global -x"
alias gr="global -r"
alias gf="global -f"
alias gg="global -g"

GOBINPATH=$1/deps/go/bin

source ~/.lijie/completion.bash
source ~/.lijie/key-bindings.bash

TMP=`echo $PATH | grep ${HOME}/opt/bin`
if [ -z "$TMP" ]; then
    export PATH=${HOME}/opt/bin:$PATH
fi

TMP=`echo $PATH | grep $GOBINPATH`
if [ -z "$TMP" ]; then
    export PATH=$GOBINPATH:$PATH
fi

