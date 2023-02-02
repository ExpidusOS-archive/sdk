#!@bash@/bin/sh

export PATH="@yq@/bin:$PATH"

file="$1"

if [[ -z "$file" ]]; then
  file="./ffigen.yaml"
fi

set -e

temp=$(mktemp)
cp $file $temp

for includePath in @includePaths@; do
  yq -i ".[\"compiler-opts\"] += [\"-I $includePath\"]" $temp
done

for llvmPath in @llvmPaths@; do
  yq -i ".[\"llvm-path\"] += [\"$llvmPath\"]" $temp
done

cat $temp
rm $temp
