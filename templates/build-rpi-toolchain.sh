#!/bin/bash

cd "{{toolsdir}}"

if [ ! -e "crosstool-ng" ]; then
  git clone --depth 1 https://github.com/crosstool-ng/crosstool-ng
fi

cd "crosstool-ng"

if [ ! -e config/comp_libs.in ]; then
  ./bootstrap
fi

./configure --enable-local
make -j4

if [ ! -e .config ]; then
  cat "/usr/local/etc/{{toolchain_prefix}}.config" > .config
  ./ct-ng oldconfig
fi

mkdir -p "{{tarballs_dir}}"
./ct-ng build

pushd "{{toolchains_dir}}" >/dev/null
tar cfj "{{homedir}}/toolchain_{{toolchain_prefix}}.tbz2" "{{toolchain_prefix}}"
popd >/dev/null
