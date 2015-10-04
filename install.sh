#!/bin/sh

#
# Debian:
# Need install sudo first
#

# 用来存放七七八八的各种配置文件
LIJIEPATH=~/.lijie
mkdir -p $LIJIEPATH

# install develop tools in debian/ubuntu
TOOLS="emacs-nox gcc g++ gdb make cmake global screen git wget systemtap subversion git-svn python2.7-minimal"
DEBIAN=`uname -a | grep -i debian`
if [ -n "$DEBIAN" ]; then
    sudo apt-get install -y $TOOLS
fi

DARWIN=`uname -a | grep -i darwin`
if [ -n "$DARWIN" ]; then
    sudo port install emacs make cmake global screen git subversion wget
fi

cp emacs_config ~/.emacs
cp screenrc_config ~/.screenrc
cp gitconfig_config ~/.gitconfig

# 下面用wget获取最新的
# cp google-c-style.el $LIJIEPATH
cp markdown-mode.el $LIJIEPATH

# install deps
mkdir -p deps

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

# install go mode for emacs
if [ -e go-mode.el ]; then
    (cd go-mode.el; git pull)
else
    git clone https://github.com/dominikh/go-mode.el
fi
cp go-mode.el/go-mode.el $LIJIEPATH
cp go-mode.el/go-mode-autoloads.el $LIJIEPATH

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

sudo cp bin/godef /usr/local/bin
sudo cp bin/oracle /usr/local/bin

# install helm
if [ -e helm ]; then
    (cd helm; git pull)
else
    git clone https://github.com/emacs-helm/helm.git helm
fi
if [ -e async ]; then
    (cd async; git pull)
else
    git clone https://github.com/jwiegley/emacs-async.git async
fi
(cd helm; make)

HELMDIR=`pwd`/helm
ASYNCDIR=`pwd`/async
sed -i "s+replace_path_to_helm+${HELMDIR}+g" ~/.emacs
sed -i "s+replace_path_to_async+${ASYNCDIR}+g" ~/.emacs

# install helm-gtags
if [ -e emacs-helm-gtags ]; then
    (cd emacs-helm-gtags; git pull)
else
    git clone https://github.com/syohex/emacs-helm-gtags
fi
cp emacs-helm-gtags/helm-gtags.el $LIJIEPATH/helm-gtags.el

# install golden-ratio
if [ -e golden-ratio.el ]; then
    (cd golden-ratio.el; git pull)
else
    git clone https://github.com/roman/golden-ratio.el
fi
cp golden-ratio.el/golden-ratio.el $LIJIEPATH/

# cpplint.py for google c++ coding style
wget http://google-styleguide.googlecode.com/svn/trunk/cpplint/cpplint.py
cp cpplint.py $LIJIEPATH
wget http://google-styleguide.googlecode.com/svn/trunk/google-c-style.el
cp google-c-style.el $LIJIEPATH

# and last
echo "Put $GOBINPATH to you PATH"
