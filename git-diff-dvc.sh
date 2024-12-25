#!/usr/bin/env bash

set -eo pipefail

err() {
  echo "$*" >&2
}
# echo "git-diff-dvc.sh ($#):"
# for arg in "$@"; do
#   echo "  $arg"
# done
# echo

if [ "$#" -eq 7 ]; then
  dvc_path="$1"; shift  # repo dvc_path
  if ! [[ $dvc_path =~ .dvc$ ]]; then
      err "Error: repo dvc_path $dvc_path must end in .dvc"
      exit 1
  fi
  relpath="${dvc_path%.dvc}"
  if [ "$1" == /dev/null ]; then
    md0=
    path0=/dev/null; shift
  else
    md0="$(dvc_to_md5 "$1")"; shift
    path0="$(dvc_mdf_cache_path -r "$md0")"
  fi
  hex0="$1"; shift  # old hexsha
  mode0="$1"; shift  # old filemode
  if [ "$1" == /dev/null ]; then
    md1=
    path1=/dev/null; shift
  else
    md1="$(dvc_to_md5 "$1")"; shift
    path1="$(dvc_mdf_cache_path -r "$md1")"
  fi
  hex1="$1"; shift  # new hexsha
  mode1="$1"; shift  # old filemode

  echo "$relpath"
  echo "--- $path0 $hex0"
  echo "+++ $path1 $hex1"

  if [[ $md1 = *.dir ]] || [[ $md0 = *.dir ]]; then
    set +e
    cmd=(jq 'map({ "key": .relpath, "value": .md5 }) | from_entries')
    if [ "$path0" == /dev/null ]; then
      obj0='{}'
    else
      obj0="$("${cmd[@]}" "$path0")"
    fi
    if [ "$path1" == /dev/null ]; then
      obj1='{}'
    else
      obj1="$("${cmd[@]}" "$path1")"
    fi
    diff --color=always <(echo "$obj0") <(echo "$obj1")
    (echo "$obj0"; echo "$obj1") | \
    jq -rs '
      .[0] as $first | .[1] as $second |
      (($first | keys) + ($second | keys) | unique) as $allkeys |
      $allkeys | map({ key: ., value: [$first[.] // "null", $second[.] // "null"] })[] |
      select(.value[0] != .value[1]) |
      [ .key, .value[0], .value[1] ] | join(" ")
    ' | while read -r rel m0 m1; do
      rel="$relpath/$rel"
#      err "rel $rel, m0 $m0, m1 $m1"
      if [ "$m0" == null ]; then
        f0=/dev/null
      else
        f0="$(dvc_mdf_cache_path -r "$m0")"
      fi
      if [ "$m1" == null ]; then
        f1=/dev/null
      else
        f1="$(dvc_mdf_cache_path -r "$m1")"
      fi
#      echo "Recursing: $0 $rel $f0 $f1"
      echo
      echo "$rel"
      echo "--- $f0 $m0"
      echo "+++ $f1 $m1"
      "$0" "$rel" "$f0" "$f1"
      echo
    done
    exit 0
  fi
elif [ $# -eq 3 ]; then
  relpath="$1"; shift
  path0="$1"; shift
  path1="$1"; shift
else
  err "Usage: $0 <repo dvc_path> <old version tmpfile> <old hexsha> <old filemode> <new version tmpfile> <new hexsha> <new filemode>"
  exit 1
fi

tmpdir=$(mktemp -d)
cleanup() {
  # err "Cleaning up $tmpdir"
  rm -rf "$tmpdir"
}
trap cleanup EXIT

reldir="$(dirname "$relpath")"
name="$(basename "$relpath")"

init_tmppath() {
  # Create a hard link to a local DVC cache path, in a temporary directory, with basename matching the file's path in
  # the Git worktree. This helps `git diff` apply further custom diff logic (based on path / extension in the Git
  # worktree), which it can't do if we just diff two paths like `.dvc/cache/files/md5/<MD5>`,
  local path="$1"
  local idx="$2"
  if [ "$path" == /dev/null ]; then
    echo /dev/null
  else
    local dir="$tmpdir/$idx/$reldir"
    mkdir -p "$dir"
    local tmppath="$dir/$name"
    ln "$PWD/$path" "$tmppath"
    echo "$tmppath"
  fi
}

tmppath0=$(init_tmppath "$path0" 0)
tmppath1=$(init_tmppath "$path1" 1)
cmd=(git diff --no-index --ext-diff "$tmppath0" "$tmppath1")
# err "git-diff-dvc.sh running ${cmd[*]}"
set +e
"${cmd[@]}"
exit 0
