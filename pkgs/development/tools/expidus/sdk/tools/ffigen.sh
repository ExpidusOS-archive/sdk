#!@bash@/bin/sh

export PATH="@out@/bin:$PATH:@dart@/bin"
set -e

export FILE="./ffigen.yaml"
export DIR=$(pwd)

for i in "$@"; do
  case $i in
    --directory=*)
      export DIR="${i#*=}"
      ;;
    --file=*)
      export FILE="${i#*=}"
      ;;
    *)
      echo "Unknown argument $i"
      exit 1
      ;;
  esac
done

temp=$(mktemp)
ffigen-config "$FILE" >$temp

if ! [[ -e $DIR/pubspec.yaml ]]; then
  if ! dart pub global list | grep ffigen; then
    dart pub global activate ffigen
  fi

  dart pub -C $DIR global run ffigen --config $temp
else
  dart run ffigen --config $temp --directory $DIR
fi

rm $temp
