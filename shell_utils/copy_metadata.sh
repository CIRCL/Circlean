#!/bin/bash
# Filename: cp-metadata

myecho=echo
src_path="$1"
dst_path="$2"

find "$src_path" |
  while read src_file; do
    dst_file="$dst_path${src_file#$src_path}"
    $myecho chmod --reference="$src_file" "$dst_file"
    $myecho chown --reference="$src_file" "$dst_file"
    $myecho touch --reference="$src_file" "$dst_file"
  done
