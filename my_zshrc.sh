source /usr/share/autojump/autojump.sh

alias e="emacs"
alias eq="emacs -Q"
alias ec="emacsclient"

GOBINPATH=$1/deps/go/bin

source ~/.lijie/completion.zsh
source ~/.lijie/key-bindings.zsh

TMP=`echo $PATH | grep ${HOME}/opt/bin`
if [ -z "$TMP" ]; then
    export PATH=${HOME}/opt/bin:$PATH
fi

TMP=`echo $PATH | grep $GOBINPATH`
if [ -z "$TMP" ]; then
    export PATH=$GOBINPATH:$PATH
fi
