#!/bin/sh

cp emacs_config ~/.emacs
cp screenrc_config ~/.screenrc
cp gitconfig_config ~/.gitconfig

cp google-c-style.el ~/
cp markdown-mode.el ~/

# install deps
mkdir -p deps

# install go mode for emacs
cd deps

export GOPATH=`pwd`

if [ -e go-mode.el ]; then
    (cd go-mode.el; git pull)
else
    git clone https://github.com/dominikh/go-mode.el
fi
cp go-mode.el/go-mode.el ~/
cp go-mode.el/go-mode-autoloads.el ~/

# install godef
GODEF=github.com/rogpeppe/godef
if [ -e src/$GODEF ]; then
    go get -u $GODEF
else
    go get $GODEF
fi

# install oracle tools
ORACLE=golang.org/x/tools/cmd/oracle
if [ -e src/$ORACLE ]; then
    go get -u $ORACLE
else
    go get $ORACLE
fi
       
