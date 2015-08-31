#!/bin/sh

# install develop tools in debian/ubuntu
TOOLS="emacs-nox gcc gdb make cmake global screen git"
TOOLS_LINUX_ONLY="cgvg"
DEBIAN=`uname -a | grep -i debian`
if [ -n "$DEBIAN" ]; then
    sudo apt-get install -y $TOOLS $TOOLS_LINUX_ONLY
fi

# TODO: install develop tools in Darwin by using MacPorts

cp emacs_config ~/.emacs
cp screenrc_config ~/.screenrc
cp gitconfig_config ~/.gitconfig

cp google-c-style.el ~/
cp markdown-mode.el ~/

# install deps
mkdir -p deps

# install go mode for emacs
cd deps

# install Go
GOVERSION=`go version 2>/dev/null`
# install Go1.4.2
if [ -z "$GOVERSION" ]; then
    if [ ! -e go1.4.2.src.tar.gz ]; then
	wget https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
    fi
    if [ ! -d go1.4.2 ]; then
	tar zxf go1.4.2.src.tar.gz
	mv go go1.4.2
    fi
    if [ ! -e go1.4.2/bin/go ]; then
	(cd go1.4.2/src/; ./make.bash)
    fi
fi
export GOROOT_BOOTSTRAP=`pwd`/go1.4.2
# install Go1.5
if [ -z "$GOVERSION" ]; then
    if [ ! -e go1.5.src.tar.gz ]; then
	wget https://storage.googleapis.com/golang/go1.5.src.tar.gz
    fi
    if [ ! -d go1.5 ]; then
	tar zxf go1.5.src.tar.gz
	mv go go1.5
    fi
    if [ ! -e go1.5/bin/go ]; then
	(cd go1.5/src/; ./make.bash)
    fi
fi
GOBINPATH=`pwd`/go1.5/bin
export PATH=$GOBINPATH:$PATH

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
       
# and last
echo "step1: Put $GOBINPATH to you PATH"
echo "step2: Copy deps/bin/godef, deps/bin/oracle to you Path"
