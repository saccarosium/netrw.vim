#!/usr/bin/env bash

set -eu

msg_ok() { printf '\e[32m✔\e[0m %s\n' "$1"; }
msg_err() { printf '\e[31m✘\e[0m %s\n' "$1" >&2; }
panic() { msg_err "Panic: $1" && exit 1; }
ensure_executable() { type "$1" &>/dev/null || panic "$1 must be installed to execute this script."; }

# Ensure that the user has a bash that supports -A
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || panic "script requires bash 4+ (you have ${BASH_VERSION})."

readonly SCRIPT_PWD=$(dirname "${BASH_SOURCE[0]}")
readonly CWD=$(cd "$SCRIPT_PWD"/.. &>/dev/null && pwd)
readonly VIM_SRC_DIR="$CWD/.repos/vim"

update_vim_source() {
    if [[ ! -d $VIM_SRC_DIR ]]; then
        echo "Cloning Vim into: $VIM_SRC_DIR"
        git clone https://github.com/vim/vim.git "$VIM_SRC_DIR"
    else
        if [[ ! -d ".git" && "$(git rev-parse --show-toplevel)" != "$VIM_SRC_DIR" ]]; then
            panic "$VIM_SRC_DIR does not appear to be a git repository."
        fi
        echo "Updating Vim sources: $VIM_SRC_DIR"
        if git -C "$VIM_SRC_DIR" pull --ff origin master &>/dev/null; then
            msg_ok "Updated Vim sources."
        else
            msg_err "Could not update Vim sources; ignoring error."
        fi
    fi
}

generate_branch_name() {
    local version
    version=$(perl -ne 'print "$1\n" if /let g:loaded_netrw = "v(\d+)"/' autoload/netrw.vim)
    echo "netrw-v$((version + 1))"
}

ensure_correct_branch() {
    local branch branch_name status
    branch=$(git -C "$VIM_SRC_DIR" branch --show-current)

    [[ $branch != 'master' ]] && return 0

    status=$(git -C "$VIM_SRC_DIR" status -s)

    if [[ -n $status ]]; then
        msg_err "$VIM_SRC_DIR master branch is dirty. Stashing..."
        git -C "$VIM_SRC_DIR" stash || panic "Failed to stash changes"
    fi

    branch_name=$(generate_branch_name)

    git -C "$VIM_SRC_DIR" checkout "$branch_name" 2>/dev/null ||
        git -C "$VIM_SRC_DIR" checkout -b "$branch_name"

    msg_ok "$VIM_SRC_DIR points to the right branch"
}

update_source_files() {
    local files
    files=(
        'autoload/netrw.vim'
        'autoload/netrw/fs.vim'
        'autoload/netrw/msg.vim'
        'autoload/netrw/os.vim'
        'autoload/netrwSettings.vim'
        'autoload/netrw_gitignore.vim'
        'syntax/netrw.vim'
        'plugin/netrwPlugin.vim'
        'doc/netrw.txt'
    )

    for file in "${files[@]}"; do
        cp -f "$CWD/$file" "$VIM_SRC_DIR/runtime/pack/dist/opt/netrw/$file"
    done

    msg_ok "Updated $VIM_SRC_DIR source files."
}

main() {
    ensure_executable git
    ensure_executable perl

    update_vim_source
    ensure_correct_branch
    update_source_files
}

main
