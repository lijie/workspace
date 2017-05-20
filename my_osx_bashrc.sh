#!/bin/sh

alias ls='ls --color'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ag='ag -i'
alias ack='ack -i'
alias a='ag -i'

alias e="emacs"
alias eq="emacs -Q"
alias ex="open /Applications/Emacs.app"
alias ec="emacsclient"

TMP=`echo $PATH | grep ${HOME}/opt/bin`
if [ -z "$TMP" ]; then
    export PATH=${HOME}/opt/bin:$PATH
fi

source ~/.lijie/completion.bash
source ~/.lijie/key-bindings.bash

# 设置mackports到path
export PATH=/usr/local/go/bin:/opt/local/bin:$PATH
# 默认使用gnu coreutils
export PATH=/opt/local/libexec/gnubin/:$PATH
