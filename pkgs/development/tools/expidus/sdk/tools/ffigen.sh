#!@bash@/bin/sh

export PATH="@out@/bin:@dart@/bin:@flutter@/bin:$PATH"
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
    --flutter)
      export FLUTTER=true
      ;;
    *)
      echo "Unknown argument $i"
      exit 1
      ;;
  esac
done

temp=$(mktemp)
ffigen-config "$FILE" >$temp

cd $DIR
if [[ -z $FLUTTER ]]; then
  if ! [[ -e $DIR/pubspec.yaml ]]; then
    if ! dart pub global list | grep ffigen; then
      dart pub global activate ffigen
    fi

    dart pub global run ffigen --config $temp
  else
    dart run ffigen --config $temp
  fi
else
  if ! [[ -e $DIR/pubspec.yaml ]]; then
    if ! flutter pub global list | grep ffigen; then
      flutter pub global activate ffigen
    fi

    flutter pub global run ffigen --config $temp
  else
    flutter pub run ffigen --config $temp
  fi
fi

rm $temp
