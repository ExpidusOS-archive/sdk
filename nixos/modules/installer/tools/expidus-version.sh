#! @runtimeShell@
# shellcheck shell=bash

case "$1" in
  -h|--help)
    echo "Like nixos-version but for ExpidusOS."
    ;;
  --hash|--revision)
    if ! [[ @revision@ =~ [0-9a-f]+$ ]]; then
      echo "$0: Expidus Channel commit hash is unknown"
      exit 1
    fi
    echo "@revision@"
    ;;
  --json)
    cat <<EOF
@json@
EOF
    ;;
  *)
    echo "@version@ (@codeName@)"
    ;;
esac
