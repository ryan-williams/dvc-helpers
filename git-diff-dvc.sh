#!/usr/bin/env bash

set -eo pipefail

err() {
  echo "$*" >&2
}

script_name="$(basename "$0")"
usage() {
  err "$script_name:"
  err
  err '  # Invoked by `git diff`:'
  err "  $script_name <repo relpath> <old version tmpfile> <old hexsha> <old filemode> <new version tmpfile> <new hexsha> <new filemode>"
  err
  err '  # Invoked by e.g. `git diff --no-index --ext-diff`:'
  err "  $script_name <old version tmpfile> <new version tmpfile>"
  err
  err 'Pass opts via the $GIT_DIFF_DVC_OPTS env var:'
  err
  err '- `-c`: `--color=always`'
  err '- `-C`: `--color=never`'
  err '- `-v`: verbose/debug mode'
  err
  err 'The "opts var" itself ("GIT_DIFF_DVC_OPTS" by default) can also be customized, by setting `$GIT_DIFF_DVC_OPTS_VAR`, e.g.:'
  err
  err '  export GIT_DIFF_DVC_OPTS_VAR=GIT_DVC  # This can be done once, e.g. in your .bashrc'
  err '  GIT_DVC="-cv" git diff                # Shorter var name can then be used to configure diffs (in this case: force colorize, enable debug logging)'
  exit 1
}

color=()
verbose=
parse() {
  while getopts "cCv" opt; do
    case "$opt" in
      c) color=(--color=always) ;;
      C) color=(--color=never) ;;
      v) verbose=1 ;;
      \?) usage ;;
    esac
  done
}

OPTS_VAR="${GIT_DIFF_DVC_OPTS_VAR:-GIT_DIFF_DVC_OPTS}"
OPTS="${!OPTS_VAR}"
if [ -n "$OPTS" ]; then
  IFS=' ' read -ra opts <<< "$OPTS"
  parse "${opts[@]}"
fi

if [ -n "$verbose" ]; then
  echo "$script_name ($#):"
  for arg in "$@"; do
    echo "  $arg"
  done
  echo
  set -x
fi

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
  usage
fi

tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

reldir="$(dirname "$relpath")"
name="$(basename "$relpath")"

# We want to diff `$path0` and `$path1`, which are paths to blobs in the repo's local DVC cache (`.dvc/cache/files/md5/…`).
# Since they're not directly tracked by Git, we have to diff them using the `git diff --no-index` flag (we have to use
# `git diff`, as opposed to just `diff`, because we still want to inherit Git configs/attributes (especially: custom
# diff drivers).
#
# Diff drivers are matched based on glob patterns in `.gitattributes`, so the paths we pass to `git diff --no-index`
# should mimic the "relpath" of the original file in the repo (e.g. `test.parquet`, the file DVC is tracking). We
# achieve that by creating a hard link to the blob in a temporary directory, with a path that matches the file's path in
# the Git worktree.
#
# Finally, `git diff --no-index` will display the paths we pass to it, so it's nicer to `cd` into the tmpdir "root", and
# then perform the `git diff` on relative paths `a/<relpath>` and `b/<relpath>` (where `<relpath>` is the path to the
# DVC-tracked file in the Git worktree). The prefixes are necessary to avoid the two links being at the same location,
# and "a/" and "b/" match Git's defaults.

orig_dir="$PWD"
cd "$tmpdir"

init_tmppath() {
  # Create a hard link to a local DVC cache path, in a temporary directory, with basename matching the file's path in
  # the Git worktree. This helps `git diff` apply further custom diff logic (based on path / extension in the Git
  # worktree), which it can't do if we just diff two paths like `.dvc/cache/files/md5/<MD5>`,
  local path="$1"
  local prefix="$2"
  if [ "$path" == /dev/null ]; then
    echo /dev/null
  else
    local dir="$tmpdir/$prefix/$reldir"
    mkdir -p "$dir"
    local tmppath="$dir/$name"
    ln "$orig_dir/$path" "$tmppath"
    echo "$prefix/$relpath"
  fi
}

prefix0=a
prefix1=b
relpath0=$(init_tmppath "$path0" $prefix0)
relpath1=$(init_tmppath "$path1" $prefix1)

# We essentially want to run:
#
# ```bash
# GIT_DIR="$orig_dir/.git" GIT_WORK_TREE="$orig_dir" git diff --no-index --ext-diff "$relpath0" "$relpath1"
# ```
#
# - `$GIT_DIR` picks up configs from the original repo.
# - `$GIT_WORK_TREE` should pick up `.gitattributes` (in the root of the Git repo, not contained in `.git` / `$GIT_DIR`).
#
# However, on Ubuntu, something about setting the latter results in the correct diff driver not being selected (even though e.g. `git check-attr diff $relpath1` will detect it, with the env vars above set). On MacOS it seems to work as expected.
#
# As a workaround, we manually ask `check-attr diff` for each file's "type", and write them to `.gitattributes` in the current directory (`$tmpdir`).
#
# TODO: would creating `$tmpdir` in the Git worktree make this unnecessary?

export GIT_DIR="$orig_dir/.git"

get_attr_type() {
    if [ -z "$1" ]; then return 0; fi
    if [ "$1" == /dev/null ]; then return 0; fi
    # if [ "${1:0:1}" == "/" ]; then return 0; fi
    type="$(GIT_WORK_TREE="$orig_dir" git check-attr diff "$1" | sed -E 's/.*: diff: (.*)/\1/')"
    if [ "$type" != "unset" ] && [ "$type" != "unspecified" ]; then
	echo "$1 diff=$type" >> .gitattributes
    fi
}

get_attr_type "$relpath0"
get_attr_type "$relpath1"

set +e
git diff "${color[@]}" --no-index --ext-diff "$relpath0" "$relpath1"
exit 0
