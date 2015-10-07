#!/bin/sh

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ag='ag -i'
alias ack='ack -i'
alias a='ag -i'

GOBINPATH=`dirname $0`/deps/go/bin

export PATH=~/opt/bin:$GOBINPATH:$PATH

