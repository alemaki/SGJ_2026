#!/bin/sh
printf '\033c\033]0;%s\a' SGJ_2026
base_path="$(dirname "$(realpath "$0")")"
"$base_path/SGJ_2026.x86_64" "$@"
