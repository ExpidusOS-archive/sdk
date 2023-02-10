#!@bash@/bin/sh

export PATH="@out@/bin:@dart@/bin:$PATH"
set -e

if ! [[ -z "@flutter@" ]]; then
  export PATH="@flutter@/bin:$PATH"
fi

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

ffigen-config "$FILE" "$COMPILER_OPTS" >"$DIR/.ffigen.yaml"

export ffigenExtra=("--config" "$DIR/.ffigen.yaml" "--verbose" "$VERBOSE")
echo "Running ffigen with ${ffigenExtra[@]}"

cd $DIR
if [[ -z $FLUTTER ]]; then
  if ! [[ -e $DIR/pubspec.yaml ]]; then
    if ! dart pub global list | grep ffigen; then
      dart pub global activate ffigen
    fi

    dart pub global run ffigen ${ffigenExtra[@]}
  else
    dart run ffigen ${ffigenExtra[@]}
  fi
else
  if ! [[ -e $DIR/pubspec.yaml ]]; then
    if ! flutter pub global list | grep ffigen; then
      flutter pub global activate ffigen
    fi

    flutter pub global run ffigen ${ffigenExtra[@]}
  else
    flutter pub run ffigen ${ffigenExtra[@]}
  fi
fi

rm "$DIR/.ffigen.yaml"
