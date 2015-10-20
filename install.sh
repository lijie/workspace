#!/bin/sh

#
# Debian:
# Need install sudo first
#

# $1 git url
# $2 loacl path
gitget()
{
    echo "git clone or update:", $1
    if [ -e $2 ]; then
	(cd $2; git pull)
    else
	git clone $1
    fi
}

# $1 url
# $2 local path
wgetit()
{
    echo "wget:" $1
    if [ ! -e $2 ]; then
	wget $1
    fi
}

# $1 url
goget()
{
    if [ -e src/$1 ]; then
	$GO get -u $1
    else
	$GO get $1
    fi
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
TOOLS="emacs-nox gcc g++ gdb make cmake screen git wget systemtap subversion git-svn python2.7-minimal ack-grep silversearcher-ag clang libclang-dev libclang-3.5-dev bear libncurses5-dev"

DEBIAN=`uname -a | grep -i debian`
if [ -n "$DEBIAN" ]; then
    sudo apt-get install -y $TOOLS
fi

DARWIN=`uname -a | grep -i darwin`
if [ -n "$DARWIN" ]; then
    sudo port install emacs cmake screen git subversion wget the_silver_searcher
    unset LINUX
fi

cp emacs_config ~/.emacs
cp screenrc_config ~/.screenrc
cp gitconfig_config ~/.gitconfig

# 下面用wget获取最新的
# cp google-c-style.el $LIJIEPATH
cp markdown-mode.el $LIJIEPATH

SETBASHRC=`cat ~/.bashrc | grep my_bashrc`
if [ -z "$SETBASHRC" ]; then
    echo "source" $PWD/my_bashrc.sh $PWD >> ~/.bashrc
fi

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

# cpplint.py for google c++ coding style
if [ ! -e cpplint.py ]; then
    wget http://google-styleguide.googlecode.com/svn/trunk/cpplint/cpplint.py
fi
cp cpplint.py $LIJIEPATH
if [ ! -e google-c-style.el ]; then
    wget http://google-styleguide.googlecode.com/svn/trunk/google-c-style.el
fi
cp google-c-style.el $LIJIEPATH

# install linux perf tools
if [ -n "$LINUX" ]; then
    gitget https://github.com/brendangregg/perf-tools perf-tools
fi

# debian默认的global版本实在太老了
# 自己编译一个较新的
wgetit http://tamacom.com/global/global-6.5.1.tar.gz global-6.5.1.tar.gz
if [ ! -e global-6.5.1 ]; then
    tar zxf global-6.5.1.tar.gz
fi

(cd global-6.5.1; ./configure --prefix=$PREFIX; make; make install)

# rust-lang
# wgetit https://static.rust-lang.org/dist/rust-1.3.0-x86_64-unknown-linux-gnu.tar.gz rust-1.3.0-x86_64-unknown-linux-gnu.tar.gz
