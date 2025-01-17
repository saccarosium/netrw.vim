#!/usr/bin/env bash

set -eu

msg_ok() { printf '\e[32m✔\e[0m %s\n' "$1"; }
msg_err() { printf '\e[31m✘\e[0m %s\n' "$1" >&2; }
panic() { msg_err "Panic: $1" && exit 1; }
check_executable() { type "$1" || panic "$1 not found in PATH or not executable."; }

# Ensure that the user has a bash that supports -A
[[ ${BASH_VERSINFO[0]} -ge 4 ]] ||
    panic "script requires bash 4+ (you have ${BASH_VERSION})."

readonly SCRIPT_PWD=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)
readonly VIM_SRC_DIR="$SCRIPT_PWD/.repos/vim"

update_vim_source() {
    check_executable git

    if [[ ! -d $VIM_SRC_DIR ]]; then
        echo "Cloning Vim into: $VIM_SRC_DIR"
        git clone https://github.com/vim/vim.git "$VIM_SRC_DIR"
    else
        if [[ ! -d ".git" && "$(git rev-parse --show-toplevel)" != "$VIM_SRC_DIR" ]]; then
            panic "$VIM_SRC_DIR does not appear to be a git repository."
        fi
        echo "Updating Vim sources: $VIM_SRC_DIR"
        if git pull --ff; then
            msg_ok "Updated Vim sources."
        else
            msg_err "Could not update Vim sources; ignoring error."
        fi
    fi
}

update_source_files() {
    local files
    files=(
        'autoload/netrw.vim'
        'autoload/netrwSettings.vim'
        'autoload/netrw_gitignore.vim'
        'syntax/netrw.vim'
        'plugin/netrwPlugin.vim'
        'doc/netrw.txt'
    )

    for file in "${files[@]}"; do
        cp -f "$SCRIPT_PWD/$file" "$VIM_SRC_DIR/runtime/pack/dist/opt/netrw/$file"
    done

    msg_ok "Updated Source files."
}

main() {
    update_vim_source
    update_source_files
}

main
