#!@bash@/bin/sh

export PATH="@out@/bin:@dart@/bin:@flutter@/bin:$PATH"
set -e

export FILE="./ffigen.yaml"
export DIR=$(pwd)
export COMPILER_OPTS=""
export VERBOSE="info"

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
    --compiler-opts=*)
      export COMPILER_OPTS="${i#*=}"
      ;;
    --verbose=*)
      export VERBOSE="${i#*=}"
      ;;
    *)
      echo "Unknown argument $i"
      exit 1
      ;;
  esac
done

temp=$(mktemp)
ffigen-config "$FILE" >$temp

export ffigenExtra="--config $temp --verbose $VERBOSE"

if ! [[ -z "$COMPILER_OPTS" ]]; then
  ffigenExtra="$ffigenExtra --compiler-opts $COMPILER_OPTS"
fi

cd $DIR
if [[ -z $FLUTTER ]]; then
  if ! [[ -e $DIR/pubspec.yaml ]]; then
    if ! dart pub global list | grep ffigen; then
      dart pub global activate ffigen
    fi

    dart pub global run ffigen $ffigenExtra
  else
    dart run ffigen $ffigenExtra
  fi
else
  if ! [[ -e $DIR/pubspec.yaml ]]; then
    if ! flutter pub global list | grep ffigen; then
      flutter pub global activate ffigen
    fi

    flutter pub global run ffigen $ffigenExtra
  else
    flutter pub run ffigen $ffigenExtra
  fi
fi

rm $temp
