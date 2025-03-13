#!/bin/sh

# shellcheck disable=SC3043

set -e

FILES='autoload/netrw.vim autoload/netrwSettings.vim plugin/netrwPlugin.vim'

panic() {
    printf "%s\n" "$1"
    exit 1
}

help() {
    cat <<EOF
Usage: release.sh [bump]

Flags:
--help  Get help

Commands:
bump    Bump version
EOF
}

get_next_netrw_version() {
    local version
    version=$(perl -ne 'print "$1\n" if /let g:loaded_netrw = "v(\d+)"/' autoload/netrw.vim)
    echo "v$((version + 1))"
}

is_valid_version() {
    local curr_version
    curr_version=$(perl -ne 'print "$1\n" if /let g:loaded_netrw = "v(\d+)"/' autoload/netrw.vim)

    if git show-ref -q release: netrw "v$curr_version"; then
        return 0
    else
        return 1
    fi
}

make_commit() {
    [ -z "$1" ] &&
        panic 'You need to pass a version to make a commit'

    local version="$1"
    for file in $FILES; do
        git add "$file"
    done

    git commit -m "release: netrw $version"
}

cmd_bump() {
    local version
    version=$(get_next_netrw_version)

    is_valid_version ||
        panic "Hold on! you are trying to realease $version"

    for file in $FILES; do
        filename=$(basename "$file" | sed 's/.vim$//')
        varname="let g:loaded_$filename"
        sed -i "s/^$varname = \".*\"/$varname = \"$version\"/" "$file"
    done

    make_commit "$version"
}

case "$1" in
bump) cmd_bump ;;
*) help ;;
esac
