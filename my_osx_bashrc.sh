#!/bin/sh

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ag='ag -i'
alias ack='ack -i'
alias a='ag -i'

alias e="emacs"
alias eq="emacs -Q"

GOBINPATH=$1/deps/go/bin

TMP=`echo $PATH | grep ${HOME}/opt/bin`
if [ -z "$TMP" ]; then
    export PATH=${HOME}/opt/bin:$PATH
fi

TMP=`echo $PATH | grep $GOBINPATH`
if [ -z "$TMP" ]; then
    export PATH=$GOBINPATH:$PATH
fi

# 设置mackports到path
export PATH=/opt/local/bin:$PATH
# 默认使用gnu coreutils
export PATH=/opt/local/libexec/gnubin/:$PATH
