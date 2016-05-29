#!/bin/bash

#
# Debian:
# Need install sudo first
#

if [ "$1" == "offline" ]; then
    OFFLINE=1
fi

# $1 git url
# $2 loacl path
gitget()
{
    echo "git clone or update:" $1
    [ "$OFFLINE" == "1" ] && return
    [ -e $2 ] && (cd $2; git pull) || git clone $1
}

# $1 url
# $2 local path
wgetit()
{
    echo "wget:" $1
    [ "$OFFLINE" == "1" ] && return
    [ ! -e $2 ] && wget --timeout=5 $1
}

# $1 url
goget()
{
    [ "$OFFLINE" == "1" ] && return
    [ -e src/$1 ] && $GO get -u $1 || $GO get $1
}

aptget()
{
    [ "$OFFLINE" == "1" ] && return
    sudo apt-get install -y $*
}

portinstall()
{
    [ "$OFFLINE" == "1" ] && return
    sudo port install $*
}

# 用来存放七七八八的各种配置文件
LIJIEPATH=${HOME}/.lijie
mkdir -p $LIJIEPATH

PREFIX=${HOME}/opt
mkdir -p $PREFIX/bin

PWD=`pwd`

LINUX=1

# install develop tools in debian/ubuntu

# subversion
# 腾讯内部需要使用svn,其它场合只使用git

# python
# google cpplin.py 需要python

# ack-grep & silversearcher-ag
# grep的替代工具, 用于代码搜索, ag是ack的加速版本, 实测速度确实更快
# 另外还有 the_platinum_seacher, 这是ag的golang版本
# 除了提供跟ag相似的性能以外, 因为有go的跨平台优势, 在windows上效果会更好.
# the_platinum_seacher 地址:
# https://github.com/monochromegane/the_platinum_searcher

# irony-mode 似乎不支持libclang3.6, 所以3.5还是必须安装的
TOOLS="emacs-nox gcc g++ gdb make cmake screen git wget systemtap subversion git-svn python2.7-minimal ack-grep silversearcher-ag clang libclang-dev libclang-3.5-dev bear libncurses5-dev distcc ccache"

DEBIAN=`uname -a | grep -i debian`
if [ -n "$DEBIAN" ]; then
    aptget $TOOLS
    cp screenrc_config ~/.screenrc

    SETBASHRC=`cat ~/.bashrc | grep my_bashrc`
    [ -z "$SETBASHRC" ] && echo "source" $PWD/my_bashrc.sh $PWD >> ~/.bashrc
fi

DARWIN=`uname -a | grep -i darwin`
if [ -n "$DARWIN" ]; then
    sudo port install emacs cmake screen git subversion wget the_silver_searcher Bear distcc ccache coreutils bash
    unset LINUX
    cp screenrc_osx_config ~/.screenrc

    sed -i '' '/my_bashrc/d' ~/.bashrc
    SETBASHRC=`cat ~/.bashrc | grep my_osx_bashrc`
    [ -z "$SETBASHRC" ] && echo "source" $PWD/my_osx_bashrc.sh $PWD >> ~/.bashrc
fi

cp emacs_config ~/.emacs

cp gitconfig_config ~/.gitconfig

# 下面用wget获取最新的
# cp google-c-style.el $LIJIEPATH
cp markdown-mode.el $LIJIEPATH

# install deps
mkdir -p deps

cd deps

GOVER=1.6

# install Go
GOVERSION=`go version | grep $GOVER | grep -v beta 2>/dev/null`
# install Go1.4.3
if [ -z "$GOVERSION" ]; then
    if [ ! -e go1.4.3.src.tar.gz ]; then
	wgetit https://storage.googleapis.com/golang/go1.4.3.src.tar.gz go1.4.3.src.tar.gz
    fi
    if [ ! -e go1.4.3.src.tar.gz ]; then
	echo "download go1.4.3.src.tar.gz failed"
	exit 1
    fi
    if [ ! -d go1.4.3 ]; then
	tar zxf go1.4.3.src.tar.gz
	mv go go1.4.3
    fi
    [ ! -e go1.4.3/bin/go ] && (cd go1.4.3/src/; ./make.bash)
fi
export GOROOT_BOOTSTRAP=`pwd`/go1.4.3
# install Go
if [ -z "$GOVERSION" ]; then
    if [ ! -e go${GOVER}.src.tar.gz ]; then
	wgetit https://storage.googleapis.com/golang/go${GOVER}.src.tar.gz go${GOVER}.src.tar.gz
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
    [ ! -e go${GOVER}/bin/go ] && (cd go${GOVER}/src/; ./make.bash)
fi
GOBINPATH=`pwd`/go/bin
export GO=${GOBINPATH}/go
export PATH=$GOBINPATH:$PATH

export GOPATH=`pwd`

# install go mode for emacs
gitget https://github.com/dominikh/go-mode.el go-mode.el
cp go-mode.el/go-mode.el $LIJIEPATH
cp go-mode.el/go-mode-autoloads.el $LIJIEPATH

# install godef
goget github.com/rogpeppe/godef

# install oracle tools
goget golang.org/x/tools/cmd/oracle

goget github.com/nsf/gocode
cp src/github.com/nsf/gocode/emacs-company/*.el $LIJIEPATH

cp bin/godef $PREFIX/bin
cp bin/oracle $PREFIX/bin
cp bin/gocode $PREFIX/bin

# install helm
gitget "https://github.com/emacs-helm/helm.git helm" helm
gitget "https://github.com/jwiegley/emacs-async.git async" async
(cd helm; make)

HELMDIR=`pwd`/helm
ASYNCDIR=`pwd`/async
if [ -n "$DARWIN" ]; then
    sed -i '' "s:replace_path_to_helm:${HELMDIR}:g" ~/.emacs
    sed -i '' "s:replace_path_to_async:${ASYNCDIR}:g" ~/.emacs
else
    sed -i "s+replace_path_to_helm+${HELMDIR}+g" ~/.emacs
    sed -i "s+replace_path_to_async+${ASYNCDIR}+g" ~/.emacs
fi

# for emacs
# 插件加载的太多会拖慢emacs的启动速度
# 不过还好电脑速度越来越快...

# install helm-gtags
gitget https://github.com/syohex/emacs-helm-gtags emacs-helm-gtags
cp emacs-helm-gtags/helm-gtags.el $LIJIEPATH/helm-gtags.el

# install golden-ratio
gitget https://github.com/roman/golden-ratio.el golden-ratio.el
cp golden-ratio.el/golden-ratio.el $LIJIEPATH/

# elisp warpper for ag
gitget https://github.com/syohex/emacs-helm-ag emacs-helm-ag
cp emacs-helm-ag/helm-ag.el $LIJIEPATH/

# company-mode
gitget https://github.com/company-mode/company-mode company-mode
cp company-mode/company*.el $LIJIEPATH/

# irony-mode
gitget https://github.com/Sarcasm/irony-mode irony-mode
cp irony-mode/irony*.el $LIJIEPATH/

# install irony-mode server
cmake -DCMAKE_INSTALL_PREFIX=~/.emacs.d/irony/ irony-mode/server && cmake --build . --use-stderr --config Release --target install

# company-irony
gitget https://github.com/Sarcasm/company-irony company-irony
cp company-irony/*.el $LIJIEPATH/

# swiper
# gitget https://github.com/abo-abo/swiper swiper

# helm-swoop
# 它的功能跟swiper应该是重合的, 二者选其一就好
# 如果整合helm, 那就用这个吧
gitget https://github.com/ShingoFukuyama/helm-swoop helm-swoop
cp helm-swoop/helm-swoop.el $LIJIEPATH/

# multiple-cursors
# 不知道是干啥用的....
gitget https://github.com/magnars/multiple-cursors.el multiple-cursors.el

# cpplint.py for google c++ coding style
if [ ! -e cpplint.py ]; then
    wget --timeout=5 https://raw.githubusercontent.com/google/styleguide/gh-pages/cpplint/cpplint.py
fi
cp cpplint.py $LIJIEPATH
if [ ! -e google-c-style.el ]; then
    wget --timeout=5 https://raw.githubusercontent.com/google/styleguide/gh-pages/google-c-style.el
fi
cp google-c-style.el $LIJIEPATH

# install linux perf tools
[ -n "$LINUX" ] && gitget https://github.com/brendangregg/perf-tools perf-tools

# debian默认的global版本实在太老了
# 自己编译一个较新的
wgetit ftp://ftp.gnu.org/pub/gnu/global/global-6.5.1.tar.gz global-6.5.1.tar.gz
[ ! -e global-6.5.1 ] && tar zxf global-6.5.1.tar.gz

(cd global-6.5.1; ./configure --prefix=$PREFIX; make; make install)

# rust-lang
# wgetit https://static.rust-lang.org/dist/rust-1.3.0-x86_64-unknown-linux-gnu.tar.gz rust-1.3.0-x86_64-unknown-linux-gnu.tar.gz
