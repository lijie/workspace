#!/bin/sh

# install develop tools in debian/ubuntu
TOOLS="emacs-nox gcc g++ gdb make cmake global screen git wget"
TOOLS_LINUX_ONLY="cgvg sudo systemtap"
TOOLS_TENCENT="git-svn subversion"
DEBIAN=`uname -a | grep -i debian`
if [ -n "$DEBIAN" ]; then
    sudo apt-get install -y $TOOLS $TOOLS_LINUX_ONLY $TOOLS_TENCENT
fi

DARWIN=`uname -a | grep -i darwin`
if [ -n "$DARWIN" ]; then
    sudo port install emacs cmake global screen git subversion wget
fi

cp emacs_config ~/.emacs
cp screenrc_config ~/.screenrc
cp gitconfig_config ~/.gitconfig

cp google-c-style.el ~/
cp markdown-mode.el ~/

# install deps
mkdir -p deps

# install go mode for emacs
cd deps

GOVER=1.5.1

# install Go
GOVERSION=`go version | grep $GOVER 2>/dev/null`
# install Go1.4.3
if [ -z "$GOVERSION" ]; then
    if [ ! -e go1.4.3.src.tar.gz ]; then
	wget https://storage.googleapis.com/golang/go1.4.3.src.tar.gz
    fi
    if [ ! -e go1.4.3.src.tar.gz ]; then
	echo "download go1.4.3.src.tar.gz failed"
	exit 1
    fi
    if [ ! -d go1.4.3 ]; then
	tar zxf go1.4.3.src.tar.gz
	mv go go1.4.3
    fi
    if [ ! -e go1.4.3/bin/go ]; then
	(cd go1.4.3/src/; ./make.bash)
    fi
fi
export GOROOT_BOOTSTRAP=`pwd`/go1.4.3
# install Go
if [ -z "$GOVERSION" ]; then
    if [ ! -e go${GOVER}.src.tar.gz ]; then
	wget https://storage.googleapis.com/golang/go${GOVER}.src.tar.gz
    fi
    if [ ! -e go${GOVER}.src.tar.gz ]; then
	echo "download go${GOVER}.src.tar.gz failed"
	exit 1
    fi
    if [ ! -d go${GOVER} ]; then
	tar zxf go${GOVER}.src.tar.gz
	mv go go${GOVER}
    fi
    ln -sf go${GOVER} go
    if [ ! -e go${GOVER}/bin/go ]; then
	(cd go${GOVER}/src/; ./make.bash)
    fi
fi
GOBINPATH=`pwd`/go/bin
export GO=${GOBINPATH}/go
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
    $GO get -u $GODEF
else
    $GO get $GODEF
fi

# install oracle tools
ORACLE=golang.org/x/tools/cmd/oracle
if [ -e src/$ORACLE ]; then
    $GO get -u $ORACLE
else
    $GO get $ORACLE
fi
       
# and last
echo "step1: Put $GOBINPATH to you PATH"
echo "step2: Copy deps/bin/godef, deps/bin/oracle to you Path"
