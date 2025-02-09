#!/bin/sh -e

TESTENV="$PWD/.testenv"
PLUGINS="$TESTENV/plugins"

rm -rf "$TESTENV/dummy"
mkdir -p "$TESTENV/dummy"

if [ ! -e "$PLUGINS/vader.vim" ]; then
    git clone --depth=1 https://github.com/junegunn/vader.vim "$PLUGINS/vader.vim"
else
    (cd "$PLUGINS/vader.vim" && git pull)
fi

case "$1" in
    vim)
        vim -Nu tests/vimrc '+Vader! tests/*'
        ;;
    nvim)
        nvim --headless -u tests/vimrc '+Vader! tests/*'
        ;;
    *)
        echo "Usage: test.sh [vim | nvim]"
        exit 1
        ;;
esac

if [ "$?" -eq 0 ]; then
    echo "==> Success $1 <=="
else
    echo "==> Failed $1 <=="
fi
